.PHONY: all download fastq stats bio trim clean

-include fastq/.safe_name.mk

export SAFE_NAME

all: download fastq stats trim

# Download SRA reads for a genome accession.
# The download command uses whiptail to open a dialog box to prompt the user for a genome's SRR number. 
#It then uses the bio command with -t and -H to create a tab delinated table, finds the column "scientific_name", and stores the output  
# Lines 38-40 change the scientific name to a safe name by replacing any non-alphanumeric characters with underscores.
# Lines 41-42 create a directory called fastq and use fastq-dump to download the reads for the given SRR number, splitting them into separate files if necessary.
#It's a little messy but it works?

download:
	@srr=$$(whiptail --inputbox "Enter the genome's SRR number:" 10 60 3>&1 1>&2 2>&3); \
	if [ -z "$$srr" ]; then \
		echo "No SRR number entered." >&2; \
		exit 1; \
	fi; \
	   scientific_name=$$(bio search -t -H "$$srr" | \
        awk -F '\t' '\
            NR == 1 { \
                for (i = 1; i <= NF; i++) { \
                    if ($$i == "scientific_name") \
                        column = i; \
                } \
                next \
            } \
            NR == 2 { \
                print $$column; \
                exit \
            }'); \
	if [ -z "$$scientific_name" ]; then \
		echo "No scientific name found for $$srr." >&2; \
		exit 1; \
	fi; \
	safe_name=$$(printf '%s' "$$scientific_name" | sed 's/[^[:alnum:]._-]/_/g'); \
	mkdir -p fastq; \
	printf 'SAFE_NAME := %s\n' "$$safe_name" > fastq/.safe_name.mk.tmp; \
	mv -- fastq/.safe_name.mk.tmp fastq/.safe_name.mk; \
	fastq-dump -X 10000 --outdir fastq --split-files "$$srr"; \
	for file in fastq/"$$srr"*.fastq; do \
		[ -e "$$file" ] || continue; \
		suffix=$${file#fastq/"$$srr"}; \
		mv -- "$$file" "fastq/$$safe_name$$suffix"; \
	done; \
	printf '\r\n'

stats:
	@seqkit stats fastq/*.fastq

fastq:
	@fastqc fastq/*.fastq
	@mkdir -p fastq/fastqc
	@mv fastq/*fastqc.html fastq/fastqc/
	@rm -f fastq/*fastqc.zip

clean:
	@rm -rf fastq trimmed

trim:
	@mkdir -p trimmed
	@for r1 in fastq/*_1.fastq; do \
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
	@fastqc trimmed/*.fastq
	@mkdir -p trimmed/fastqc
	@mv trimmed/*fastqc.html trimmed/fastqc/
	@rm -f trimmed/*fastqc.zip
