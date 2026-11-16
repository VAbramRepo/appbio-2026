script_arg <- grep("^--file=", commandArgs(), value = TRUE)
if (length(script_arg) != 1) {
  stop("Run this script with Rscript so its location can be determined.")
}

script_path <- normalizePath(sub("^--file=", "", script_arg))
gene_dir <- dirname(dirname(script_path))
project_dir <- dirname(gene_dir)
counts_dir <- file.path(gene_dir, "counts")
count_files <- sort(list.files(counts_dir, pattern = "\\.txt$", full.names = TRUE))

if (length(count_files) == 0) {
  stop("No .txt count files found in ", counts_dir)
}

sample_names <- sub("\\.txt$", "", basename(count_files))
if (anyDuplicated(sample_names)) {
  stop("Count filenames must have unique sample names.")
}

read_counts <- function(path) {
  counts <- read.delim(
    path,
    comment.char = "#",
    check.names = FALSE,
    stringsAsFactors = FALSE
  )

  if (!"Geneid" %in% names(counts) || ncol(counts) < 7) {
    stop("Unexpected featureCounts format in ", path)
  }
  if (anyDuplicated(counts$Geneid)) {
    stop("Duplicate Geneid values found in ", path)
  }

  data.frame(
    Geneid = counts$Geneid,
    Count = counts[[ncol(counts)]],
    stringsAsFactors = FALSE
  )
}

sample_counts <- lapply(count_files, read_counts)
gene_ids <- sample_counts[[1]]$Geneid
count_matrix <- data.frame(Geneid = gene_ids, stringsAsFactors = FALSE)

for (i in seq_along(sample_counts)) {
  sample_genes <- sample_counts[[i]]$Geneid
  if (!setequal(gene_ids, sample_genes)) {
    stop("Gene IDs do not match across count files: ", count_files[[i]])
  }
  count_matrix[[sample_names[[i]]]] <-
    sample_counts[[i]]$Count[match(gene_ids, sample_genes)]
}

# Add common gene names from Ensembl, removing version suffixes for lookup.
message("Looking up common gene names with biomaRt")
mart <- biomaRt::useEnsembl(
  biomart = "genes",
  dataset = "hsapiens_gene_ensembl",
  host = "https://e115.ensembl.org"
)
annotations <- biomaRt::getBM(
  attributes = c("ensembl_gene_id", "external_gene_name"),
  filters = "ensembl_gene_id",
  values = unique(sub("\\.[0-9]+$", "", gene_ids)),
  mart = mart
)
gene_names <- annotations$external_gene_name[
  match(sub("\\.[0-9]+$", "", gene_ids), annotations$ensembl_gene_id)
]
gene_names[!is.na(gene_names) & !nzchar(gene_names)] <- NA_character_
count_matrix[["gene name"]] <- gene_names
count_matrix <- count_matrix[c("Geneid", "gene name", sample_names)]

# Save the matrix with Ensembl IDs, common names, and per-sample counts.
output_file <- file.path(project_dir, "gene_count_matrix.csv")
write.csv(count_matrix, output_file, row.names = FALSE)
message("Wrote ", output_file)
