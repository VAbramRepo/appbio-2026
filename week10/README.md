# Assignment 10: Define CHIP-seq peaks 

I am continuing to use my S. aureus genome: 

[Reference Genome Page](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_000013425.1/)

[Reference Genome Download](https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/013/425/GCF_000013425.1_ASM1342v1/GCF_000013425.1_ASM1342v1_genomic.fna.gz )

[Gff Download](https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/013/425/GCF_000013425.1_ASM1342v1/GCF_000013425.1_ASM1342v1_genomic.gff.gz)


This time, however, I will be looking at CHIP-seq project: [PRJNA360436](https://www.ncbi.nlm.nih.gov/bioproject/360436). 

Briefly, the researchers were looking to find Noc-associated spatial regulators of division, but found along the way that Noc seems to control DNA replication. Noc mutants over-replicate and can be rescued by dnaA mutantations. 

``` Overall design: ChIP-seq experiments were performed on wild type and mutant cells of Staphylococcus aureus HG003 (Herbert et al, 2010 PMID: 20212089), and Bacillus subtilis PY79 (Youngman et al 1983, PMID: 6300908) growing in tryptic soy broth (TSB) and CH, separately, at 37°C with aeration ``` 


The project contains 20 samples total, but some are for *Bacilus subtilus*. There are 6 *S. aureus* samples, one with anti-noc antibodies, and one with anti-6xHis antibodies (SRR5151568, SRR5151569, SRR5151572, SRR5151567, SRR5151570,SRR5151571)

