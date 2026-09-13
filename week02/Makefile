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



clean:
	rm -rf $(FASTA_DIR) $(GFF_DIR) $(GTF_DIR)
