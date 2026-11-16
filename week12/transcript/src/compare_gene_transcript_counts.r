# Compare featureCounts gene counts with summed tximport transcript counts.
# Run from the week12 project directory:
# pixi run Rscript transcript/src/compare_gene_transcript_counts.r
library(dplyr)

# Input matrices and comparison output.
GENE_MATRIX_FILE <- "gene_count_matrix.csv"              # featureCounts matrix.
TRANSCRIPT_MATRIX_FILE <- "transcript_count_all.csv"    # tximport counts by gene.
OUTPUT_FILE <- "gene_transcript_count_comparison.csv"   # Comparison table.

# Load both matrices and verify their sample columns match in name and order.
cat(sprintf("# Reading gene counts from: %s\n", GENE_MATRIX_FILE))
GENE_MATRIX <- read.csv(GENE_MATRIX_FILE, check.names = FALSE)
TRANSCRIPT_MATRIX <- read.csv(TRANSCRIPT_MATRIX_FILE, check.names = FALSE)
SAMPLES <- setdiff(names(GENE_MATRIX), c("Geneid", "gene name"))
TRANSCRIPT_SAMPLES <- setdiff(names(TRANSCRIPT_MATRIX), "gene name")
if (!identical(SAMPLES, TRANSCRIPT_SAMPLES)) {
  stop("Gene and transcript matrices do not have the same sample columns in the same order.")
}

# Keep named genes and combine any duplicate symbols before comparison.
GENE_COUNTS <- GENE_MATRIX |>
  filter(!is.na(`gene name`), `gene name` != "") |>
  group_by(`gene name`) |>
  summarise(across(all_of(SAMPLES), sum), .groups = "drop") |>
  rename_with(~ paste0(.x, "_gene"), all_of(SAMPLES))
TRANSCRIPT_COUNTS <- TRANSCRIPT_MATRIX |>
  rename_with(~ paste0(.x, "_transcript"), all_of(SAMPLES))
COMPARISON <- left_join(GENE_COUNTS, TRANSCRIPT_COUNTS, by = "gene name")

# Calculate gene-matrix minus transcript-derived counts for each sample.
for (SAMPLE in SAMPLES) {
  COMPARISON[[paste0(SAMPLE, "_difference")]] <-
    COMPARISON[[paste0(SAMPLE, "_gene")]] -
    COMPARISON[[paste0(SAMPLE, "_transcript")]]
}

# Save sample counts and per-sample differences for each named gene.
cat(sprintf("# Saving comparison to: %s\n", OUTPUT_FILE))
write.csv(COMPARISON, OUTPUT_FILE, row.names = FALSE)
cat(sprintf("# Compared %d named genes across %d samples.\n",
            nrow(COMPARISON), length(SAMPLES)))
