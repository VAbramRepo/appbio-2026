.PHONY: download-genome clean igv-index igv

ACCESSION ?= GCF_031877795.1
FASTA_DIR ?= FASTA
GFF_DIR ?= GFF
GTF_DIR ?= GTF
ARCHIVE ?= $(FASTA_DIR)/$(ACCESSION).zip
GENOME_PREFIX ?= Tawny_Owl_genome
IGV_BIN ?= cmd.exe
IGV_ARGS ?= /c start "" "C:/Program Files/IGV_2.19.8/igv.bat"

# Download a reference genome from NCBI using the Datasets CLI.
# Example: make download-genome
# Or: make download-genome ACCESSION=GCF_031877795.1

download-genome:
	@command -v datasets >/dev/null 2>&1 || { \
		echo "Error: 'datasets' CLI is not installed."; \
		echo "Install it from: https://www.ncbi.nlm.nih.gov/datasets/docs/v2/download-and-install/"; \
		exit 1; \
	}
	mkdir -p $(FASTA_DIR) $(GFF_DIR) $(GTF_DIR)
	datasets download genome accession $(ACCESSION) --include genome,gff3,gtf --filename $(ARCHIVE)
	@tmp_dir=$$(mktemp -d); \
	python3 -c 'import sys, zipfile; from pathlib import Path; tmp_dir = Path(sys.argv[1]); archive = Path(sys.argv[2]); zipfile.ZipFile(archive).extractall(tmp_dir)' "$$tmp_dir" "$(ARCHIVE)"; \
	f=$$(find "$$tmp_dir" -type f \( -iname "*.fna" -o -iname "*.fa" -o -iname "*.fasta" \) | head -n 1); \
	if [ -z "$$f" ]; then \
		echo "Error: no FASTA file found after download."; \
		rm -rf "$$tmp_dir"; \
		exit 1; \
	fi; \
	ext="$${f##*.}"; \
	cp "$$f" "$(FASTA_DIR)/$(GENOME_PREFIX).$$ext"; \
	gff=$$(find "$$tmp_dir" -type f \( -iname "*.gff" -o -iname "*.gff3" \) | head -n 1); \
	if [ -n "$$gff" ]; then \
		cp "$$gff" "$(GFF_DIR)/$(GENOME_PREFIX).gff"; \
		echo "GFF saved to $(GFF_DIR)/$(GENOME_PREFIX).gff"; \
	else \
		echo "No GFF file found in the downloaded dataset."; \
	fi; \
	gtf=$$(find "$$tmp_dir" -type f -iname "*.gtf" | head -n 1); \
	if [ -n "$$gtf" ]; then \
		cp "$$gtf" "$(GTF_DIR)/$(GENOME_PREFIX).gtf"; \
		echo "GTF saved to $(GTF_DIR)/$(GENOME_PREFIX).gtf"; \
	else \
		echo "No GTF file found in the downloaded dataset."; \
	fi; \
	rm -rf "$$tmp_dir" "$(ARCHIVE)"; \
	echo "FASTA saved to $(FASTA_DIR)/$(GENOME_PREFIX).$$ext"


igv-index:
	@command -v samtools >/dev/null 2>&1 || { echo "Error: 'samtools' CLI is not installed."; exit 1; }
	@command -v bgzip >/dev/null 2>&1 || { echo "Error: 'bgzip' CLI is not installed."; exit 1; }
	@command -v tabix >/dev/null 2>&1 || { echo "Error: 'tabix' CLI is not installed."; exit 1; }
	@set -e; \
	fasta=$$(find "$(FASTA_DIR)" -maxdepth 1 -type f \( -iname "*.fna" -o -iname "*.fa" -o -iname "*.fasta" \) | head -n 1); \
	gff="$(GFF_DIR)/$(GENOME_PREFIX).gff"; \
	gff_gz="$(GFF_DIR)/$(GENOME_PREFIX).gff.gz"; \
	if [ -z "$$fasta" ]; then echo "Error: no FASTA file found in $(FASTA_DIR)."; exit 1; fi; \
	if [ ! -f "$$gff" ] && [ ! -f "$$gff_gz" ]; then echo "Error: no GFF file found in $(GFF_DIR)."; exit 1; fi; \
	samtools faidx "$$fasta"; \
	if [ ! -f "$$gff_gz" ]; then bgzip -c "$$gff" > "$$gff_gz"; fi; \
	tabix -f -p gff "$$gff_gz"; \
	echo "IGV indexes created: $$fasta.fai and $$gff_gz.tbi"



clean:
	rm -rf $(FASTA_DIR) $(GFF_DIR) $(GTF_DIR)
