# Combine Salmon transcript counts; run from the week12 project directory.
# Example: pixi run Rscript transcript/src/combined_transcript_count_shorter.r
library(dplyr)
library(tibble)

# Paths and sample order source.
GENE_MATRIX <- "gene_count_matrix.csv"                 # Defines sample order.
COUNTS_DIR <- "transcript/counts"                      # Salmon quant.sf folders.
OUTPUT_FILE <- "transcript_count_matrix_shorter.csv"  # Combined count matrix.

# Read sample columns in the same order as the gene matrix.
cat(sprintf("# Reading sample order from: %s\n", GENE_MATRIX))
COLUMNS <- names(read.csv(GENE_MATRIX, nrows = 0, check.names = FALSE))
SAMPLES <- COLUMNS[!COLUMNS %in% c("Geneid", "gene name")]

# Read per-sample estimated transcript counts.
cat(sprintf("# Reading Salmon counts from: %s\n", COUNTS_DIR))
COUNTS <- lapply(SAMPLES, function(SAMPLE) {
  QUANT <- read.delim(file.path(COUNTS_DIR, SAMPLE, "quant.sf"))
  TABLE <- tibble(Transcript = QUANT$Name, Count = QUANT$NumReads)
  names(TABLE)[2] <- SAMPLE
  TABLE
})
MATRIX <- Reduce(function(X, Y) full_join(X, Y, by = "Transcript"), COUNTS) |>
  mutate(across(all_of(SAMPLES), ~ coalesce(.x, 0)))

# Add common gene names using version-free Ensembl transcript IDs.
cat("# Looking up gene names with biomaRt...\n")
MART <- biomaRt::useEnsembl(
  biomart = "genes",
  dataset = "hsapiens_gene_ensembl",
  host = "https://e115.ensembl.org"
)
ANNOTATIONS <- biomaRt::getBM(
  attributes = c("ensembl_transcript_id", "external_gene_name"),
  filters = "ensembl_transcript_id",
  values = unique(sub("\\.[0-9]+$", "", MATRIX$Transcript)),
  mart = MART
)
GENE_NAMES <- ANNOTATIONS$external_gene_name[
  match(sub("\\.[0-9]+$", "", MATRIX$Transcript),
        ANNOTATIONS$ensembl_transcript_id)
]
GENE_NAMES[!is.na(GENE_NAMES) & !nzchar(GENE_NAMES)] <- NA_character_
MATRIX <- mutate(MATRIX, `gene name` = GENE_NAMES, .after = Transcript)

# Save the transcript-by-sample matrix in the project root.
cat(sprintf("# Saving count matrix to: %s\n", OUTPUT_FILE))
write.csv(MATRIX, OUTPUT_FILE, row.names = FALSE)
cat(sprintf("# Combined %d transcripts across %d samples.\n",
            nrow(MATRIX), length(SAMPLES)))
