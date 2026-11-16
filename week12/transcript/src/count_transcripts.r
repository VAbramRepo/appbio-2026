# Sum transcript counts by gene name; run from the week12 project directory.
# Example: pixi run Rscript transcript/src/count_transcripts.r
library(dplyr)

# Input matrix and gene-level output.
INPUT_FILE <- "transcript_count_matrix.csv" # Transcript counts with names.
OUTPUT_FILE <- "transcript_count_all.csv"            # Counts summed by gene.

# Read the matrix and identify sample columns.
cat(sprintf("# Reading transcript counts from: %s\n", INPUT_FILE))
TRANSCRIPTS <- read.csv(INPUT_FILE, check.names = FALSE)
SAMPLES <- setdiff(names(TRANSCRIPTS), c("Transcript", "gene name"))

# Sum sample counts across transcripts with each non-empty gene name.
GENES <- TRANSCRIPTS |>
  filter(!is.na(`gene name`), `gene name` != "") |>
  group_by(`gene name`) |>
  summarise(across(all_of(SAMPLES), sum), .groups = "drop")

# Write the summed gene-by-sample matrix in the project root.
cat(sprintf("# Saving gene-level transcript counts to: %s\n", OUTPUT_FILE))
write.csv(GENES, OUTPUT_FILE, row.names = FALSE)
cat(sprintf("# Summed transcript counts for %d genes across %d samples.\n",
            nrow(GENES), length(SAMPLES)))
