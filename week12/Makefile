# List the available Make targets and their purposes.
help: 
	@echo "Available targets:"
	@echo "  gene: Combine gene counts"
	@echo "  transcript: Combine transcript counts"
	@echo "  transcript_shorter: Combine transcript counts (shorter version)"
	@echo "  count_transcripts: Sum transcript counts by gene name"
	@echo "  compare: Compare gene and transcript count matrices"

# Build the gene-level count matrix from the featureCounts files.
gene:
	Rscript gene/src/combined_gene_count.r

# Combine the Salmon quantifications using the full transcript-count script.
transcript:
	Rscript transcript/src/combined_transcript_count.r

# Combine the Salmon quantifications using the shorter transcript-count script.
transcript_shorter:
	Rscript transcript/src/combined_transcript_count_shorter.r

# Sum transcript counts that share a gene name.
count_transcripts:
	Rscript transcript/src/count_transcripts.r

# Create the comparison table from named gene and transcript counts. This subtracts transcript counts from gene counts for each sample.
compare: 
	Rscript transcript/src/compare_gene_transcript_counts.r
# Print the mean of each of the six sample-difference columns.
	Rscript -e 'x <- read.csv("gene_transcript_count_comparison.csv", check.names=FALSE); columns <- names(x)[(ncol(x)-5):ncol(x)]; averages <- colMeans(x[columns], na.rm=TRUE); cat("Average of the last six columns:\\n"); print(averages)'

# Mark target names that do not correspond to files as always runnable.
.PHONY: help gene transcript transcript_shorter count_transcripts compare
