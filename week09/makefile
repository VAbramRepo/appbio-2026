# User-provided settings; edit these values before running make.
GENOME_NAME=Staph
GENOME_FASTA=fasta/$(GENOME_NAME).fasta
REF_GENOME_URL=https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/013/425/GCF_000013425.1_ASM1342v1/GCF_000013425.1_ASM1342v1_genomic.fna.gz
GFF_URL=https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/013/425/GCF_000013425.1_ASM1342v1/GCF_000013425.1_ASM1342v1_genomic.gff.gz
SRR=SRR38523917
SAMPLE_NAME=sample
N=200000

#The inputted SRR can be added onto the end of this url
SRR_URL= https://www.ncbi.nlm.nih.gov/sra/?term=$(SRR)

#defines paired fastq files
FASTQ1=fastq/$(SAMPLE_NAME)_1.fastq
FASTQ2=fastq/$(SAMPLE_NAME)_2.fastq

#Name the BAM file generated with BWA
BAM = bam/$(SAMPLE_NAME).bam

# Variant-calling inputs and parameters
FASTA=$(GENOME_FASTA)
GFF=gff/$(GENOME_NAME).gff.gz
VCF=vcf/$(SAMPLE_NAME).vcf.gz
ANN=-d 100 --annotate 'INFO/AD,FORMAT/DP,FORMAT/AD,FORMAT/ADF,FORMAT/ADR,FORMAT/SP'
CALL=--ploidy 1 --annotate 'FORMAT/GQ'

#BWA index sentinel 
INDEX= $(GENOME_FASTA).bwt

# Number of samples to process from the design.csv file
N_SAMPLES=10

#Sets number of jobs to run in parallel. Default is 3, but can be changed to any number
N_JOBS=3

.PHONY: all download fastq trim fasta qc qc_trim align variants 

# All definitions above the line 
#=================================


all:  fasta gff fastq qc index align variants mergeBAM

batch: # Run the first 10 samples in parallel
	cat design.csv | head -$(N_SAMPLES) | parallel --colsep , --header : --eta -j$(N_JOBS) \
    	make \
    	SRR={run_accession} \
    	SAMPLE_NAME={sample_alias} \
    	N=$(N) \
    	all

fasta: $(GENOME_FASTA)

$(GENOME_FASTA):
	@mkdir -p fasta
	curl -fSqL $(REF_GENOME_URL) | gunzip > $@
	seqkit stats $@


#Download the gff file for the genome specified in ref_genome_url. The gff file will be saved in a subdirectory called gff
gff: $(GFF)
$(GFF):
	@mkdir -p gff
	curl -fSqL $(GFF_URL) | gunzip | bgzip -c > $@
	tabix -p gff $@


#makes a fastq directory, splits the inputed SRR number into separate files for paired reads of N length
#Files are renamed to whatever was input as a file name. Be aware if there are spaces in the file name, the file will not rename correctly

fastq: 
	@mkdir -p fastq
	fastq-dump -X $(N) --outdir fastq --split-files "$(SRR)"
	mv fastq/$(SRR)_1.fastq $(FASTQ1)
	mv fastq/$(SRR)_2.fastq $(FASTQ2)
	seqkit stats $(FASTQ1) $(FASTQ2)

#qc runs fastq on all files that end in .fastq and inputs them in a subdirectory called fastqc
qc:
	@mkdir -p fastq/fastqc
	@fastqc -o fastq/fastqc/ fastq/*.fastq
	@rm -f fastq/fastqc/*fastqc.zip

# Saves the trimmed reads in a new directory called trimmed. If not paired, it will skip one read
trim:
	@mkdir -p trimmed
	@fastp -x --average_qual=25 -f 15 \
		-i "$(FASTQ1)" -I "$(FASTQ2)" \
		-o "trimmed/$(SAMPLE_NAME)_1.trimmed.fastq" \
		-O "trimmed/$(SAMPLE_NAME)_2.trimmed.fastq"

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
$(BAM):
	mkdir -p bam
	bwa mem $(GENOME_FASTA) $(FASTQ1) $(FASTQ2) | samtools sort -o $@
	samtools index $@
	samtools flagstat $@ 

# Call and normalize variants from the aligned reads
variants: $(VCF)

$(VCF): $(FASTA) $(BAM)
	@mkdir -p vcf
	bcftools mpileup $(ANN) -O u -f $(FASTA) $(BAM) | \
		bcftools call $(CALL) -mv -O u | \
		bcftools norm -f $(FASTA) -d all -O u | \
		bcftools sort --write-index -O z -o $(VCF)

# Will generate a stats file and plots pdf for the vcf file generated in the variants step
stats: $(VCF)
	bcftools stats $(VCF) > vcf/$(SAMPLE_NAME).stats
	plot-vcfstats -p vcf/$(SAMPLE_NAME).plots vcf/$(SAMPLE_NAME).stats

#Removes fastq and trimmed folders to start over
restart: 
	@rm -rf fastq trimmed bam fasta
#Gets rid of extra files

#for easy printing of SRR url
url: 
	echo $(SRR_URL)


#merge togther ALL VCF files contained in the VCF folder into a single VCF file called merged-VCF.vcf.gz. 

merge: 
	bcftools merge --write-index -O z -o vcf/merged-VCF.vcf.gz \
		vcf/*.vcf.gz

mergeBAM:
	bcftools mpileup -d 100 --annotate 'INFO/AD,FORMAT/DP,FORMAT/AD,FORMAT/ADF,FORMAT/ADR,FORMAT/SP' -O u -f $(FASTA)\
    bam/*.bam | \
    bcftools call $(CALL) -mv -O u | \
    bcftools norm -f $(FASTA) -d all -O u | \
    bcftools sort --write-index -O z -o vcf/merged-BAM.vcf.gz