.PHONY: download fastq stats bio clean


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


bio:
	bio search fastq/*.fastq

clean:
	@rm -rf fastq
