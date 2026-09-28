
#Defines reference genome
GENOME_NAME := $(shell whiptail --inputbox "Enter genome name" 8 60 3>&1 1>&2 2>&3)

#Defines downloaded fasta path
GENOME_FASTA= fasta/$(GENOME_NAME).fasta

#Asks for and uses genome url from NCBI
REF_GENOME_URL := $(shell whiptail --inputbox "Enter reference genome url" 8 60 3>&1 1>&2 2>&3)

#The shell commands will run every time you run the makefile, unfortunately. They do allow easy input and alteration of the target run, file name, and number of reads, though

#Whiptail asks for and saves a valid SRR number
SRR:= $(shell whiptail --inputbox "Enter the SRR accession" 8 60 3>&1 1>&2 2>&3)

#The inputted SRR can be added onto the end of this url
SRR_URL= https://www.ncbi.nlm.nih.gov/sra/?term=$(SRR)

#This shell command asks for a name for the generated fastq files
SAMPLE_NAME:= $(shell whiptail --inputbox "Enter FASTQ file name-no spaces allowed" 8 60 3>&1 1>&2 2>&3)

#This shell command allows you to input the number of reads pulled by fastq-dump
N:= $(shell whiptail --inputbox "Enter desired read length (N)" 8 60 3>&1 1>&2 2>&3)

#defines paired fastq files
FASTQ1=fastq/$(SAMPLE_NAME)_1.fastq
FASTQ2=fastq/$(SAMPLE_NAME)_2.fastq

#Name the BAM file generated with BWA
BAM = bam/$(SAMPLE_NAME).bam

#BWA index sentinel 
INDEX= $(GENOME_FASTA).bwt

.PHONY: all download fastq trim fastq-trim fasta 

# All definitions above the line 
#=================================


all: download fastq trim fastq-trim

#download makes a fastq directory, splits the inputed SRR number into separate files for paired reads of N length
#Files are renamed to whatever was input as a file name. Be aware if there are spaces in the file name, the file will not rename correctly

fasta: $(GENOME_FASTA)

$(GENOME_FASTA):
	@mkdir -p fasta
	curl -fSL $(REF_GENOME_URL) | gunzip > $@
	seqkit stats $@

fastq: 
	@mkdir -p fastq
	fastq-dump -X $(N) --outdir fastq --split-files "$(SRR)"
	mv fastq/$(SRR)_1.fastq $(FASTQ1)
	mv fastq/$(SRR)_2.fastq $(FASTQ2)
	seqkit stats $(FASTQ1) $(FASTQ2)

#fastq runs fastq on all files that end in .fastq and inputs them in a subdirectory called fastqc
qc:
	@mkdir -p fastq/fastqc
	@fastqc -o fastq/fastqc/ fastq/*.fastq
	@rm -f fastq/fastqc/*fastqc.zip

# Saves the trimmed reads in a new directory called trimmed. If not paired, it will skip one read
trim:
	@mkdir -p trimmed
	@for r1 in $(FASTQ1); do \
		[ -e "$$r1" ] || continue; \
		r2=$${r1%_1.fastq}_2.fastq; \
		if [ ! -e "$$r2" ]; then \
			echo "Skipping $$r1: matching $$r2 not found" >&2; \
			continue; \
		fi; \
		base=$$(basename "$$r1" _1.fastq); \
		out1="trimmed/$${base}_1.trimmed.fastq"; \
		out2="trimmed/$${base}_2.trimmed.fastq"; \
		fastp -x --average_qual=25 -f 15 -t 30 \
			-i "$$r1" -I "$$r2" \
			-o "$$out1" -O "$$out2"; \
	done

#Creates fastqc reports for trimmed reads
qc_trim:
	@mkdir -p trimmed/fastqc
	@fastqc -o trimmed/fastqc/ trimmed/*.fastq
	@rm -f trimmed/fastqc/*.zip

#Index the reference genome using bwa
index: 
	bwa index $(GENOME_FASTA)

#Align the genome using bwa mem algorithmn, with flagstat summary report
align: $(BAM)
$(BAM)
	mkdir -p alignment
	bwa mem $(GENOME_FASTA) $(FASTQ1) $(FASTQ2) | samtools view -bS -o $@
	samtools index $@
	samtools flagstat $@ 


#Removes fastq and trimmed folders to start over
restart: 
	@rm -rf fastq trimmed
#Gets rid of extra files

#for easy printing of SRR url
url: 
	echo $(SRR_URL)

