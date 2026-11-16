# Combine Salmon quant.sf files into a transcript-by-sample count matrix.
# Run from the week12 project directory with:
# Rscript transcript/src/combined_transcript_count.r

# Root-level gene matrix provides the required sample column order.
GENE_MATRIX_FILE <- "gene_count_matrix.csv"
# Salmon quantification files are stored in one subfolder per sample.
TRANSCRIPT_COUNTS_DIR <- "transcript/counts"
# Save the combined transcript matrix in the week12 project directory.
OUTPUT_FILE <- "transcript_count_matrix.csv"

# Read sample names from the gene matrix, excluding its gene annotation columns.
cat(sprintf("# Reading sample order from: %s\n", GENE_MATRIX_FILE))
GENE_MATRIX <- read.csv(GENE_MATRIX_FILE, check.names = FALSE)
SAMPLE_NAMES <- setdiff(names(GENE_MATRIX), c("Geneid", "gene name"))

if (length(SAMPLE_NAMES) == 0) {
  stop(sprintf("No sample columns found in '%s'.", GENE_MATRIX_FILE))
}

# Read each sample's Salmon file and keep its transcript ID and estimated counts.
cat(sprintf(
  "# Reading Salmon quant.sf files from: %s\n",
  TRANSCRIPT_COUNTS_DIR
))
COUNTS_BY_SAMPLE <- lapply(SAMPLE_NAMES, function(sample_name) {
  count_file <- file.path(TRANSCRIPT_COUNTS_DIR, sample_name, "quant.sf")
  if (!file.exists(count_file)) {
    stop(sprintf("Salmon quantification file not found: %s", count_file))
  }

  quantification <- read.delim(
    count_file,
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
  if (!all(c("Name", "NumReads") %in% names(quantification))) {
    stop(sprintf("File '%s' is missing Name or NumReads columns.", count_file))
  }
  if (anyDuplicated(quantification$Name)) {
    stop(sprintf("File '%s' contains duplicate transcript IDs.", count_file))
  }
  if (!is.numeric(quantification$NumReads) || anyNA(quantification$NumReads)) {
    stop(sprintf("File '%s' contains invalid NumReads values.", count_file))
  }

  data.frame(
    Transcript = quantification$Name,
    Count = quantification$NumReads,
    stringsAsFactors = FALSE
  )
})

# Use all transcript IDs found in any sample; missing values remain zero.
TRANSCRIPT_IDS <- unique(unlist(lapply(COUNTS_BY_SAMPLE, `[[`, "Transcript")))
COUNT_MATRIX <- matrix(
  0,
  nrow = length(TRANSCRIPT_IDS),
  ncol = length(SAMPLE_NAMES),
  dimnames = list(TRANSCRIPT_IDS, SAMPLE_NAMES)
)

# Fill matrix columns in the same order as the gene count matrix.
for (i in seq_along(COUNTS_BY_SAMPLE)) {
  sample_counts <- COUNTS_BY_SAMPLE[[i]]
  COUNT_MATRIX[match(sample_counts$Transcript, TRANSCRIPT_IDS), i] <-
    sample_counts$Count
}

# Look up common gene names using version-free Ensembl transcript IDs.
cat("# Looking up gene names with biomaRt...\n")
ENSEMBL_MART <- biomaRt::useEnsembl(
  biomart = "genes",
  dataset = "hsapiens_gene_ensembl",
  host = "https://e115.ensembl.org"
)
TRANSCRIPT_ANNOTATIONS <- biomaRt::getBM(
  attributes = c("ensembl_transcript_id", "external_gene_name"),
  filters = "ensembl_transcript_id",
  values = unique(sub("\\.[0-9]+$", "", TRANSCRIPT_IDS)),
  mart = ENSEMBL_MART
)
GENE_NAMES <- TRANSCRIPT_ANNOTATIONS$external_gene_name[
  match(sub("\\.[0-9]+$", "", TRANSCRIPT_IDS),
        TRANSCRIPT_ANNOTATIONS$ensembl_transcript_id)
]
GENE_NAMES[!is.na(GENE_NAMES) & !nzchar(GENE_NAMES)] <- NA_character_

# Write transcript IDs, gene names, and estimated counts for each sample.
cat(sprintf("# Saving combined transcript count matrix to: %s\n", OUTPUT_FILE))
write.csv(
  data.frame(
    Transcript = TRANSCRIPT_IDS,
    `gene name` = GENE_NAMES,
    COUNT_MATRIX,
    check.names = FALSE
  ),
  file = OUTPUT_FILE,
  row.names = FALSE
)
cat(sprintf(
  "# Combined %d transcripts across %d samples.\n",
  nrow(COUNT_MATRIX),
  ncol(COUNT_MATRIX)
))
