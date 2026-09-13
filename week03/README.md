# Assessment of a student's repository 
I am reviewing Lauren's repository. 

## Security Check 
Using the prompt "Screen this file for malicious content" on the makefile, the AI agent on Visual studio code claimed there was not obvious malicious content and only noted a couple of issues: 
- the clean command can wipe the project
- the genome files can take up significant disk space (true)
- the Ensembl URLS have to be legit 

## README Evaluation 

The setup and prerequisties section are a nice edition, but aren't necessary and will be replaced with a separate file later in the semester. Each command in the file is explained (e.g. make fasta). My only preferences would have been to break up the explanation of how the FASTA and GFF folders are arranged into separate lines instead of a paragraph for quick legibility, and to separate out the command examples into separate code chunks so each one could be copied separately. The code is reproducibile, but I initially got the message 

>make: Nothing to be done for 'all'.

because the FASTA and GFF files already existed in the repository. The error message for this could have been more descriptive and shown that the files already existed. In the future, I would not include the downloaded genomes in the Github repo, especially since they take up space. I also thought the count code described in the README.md could have been included in the Makefile as a command.  

When compared to my code, some of the main things the AI pointed out that Lauren's makefile had better grouping of variables, 
>- Variables are grouped logically.
>- URLs and output paths are derived from those variables.
>- all, fasta, and gff form a simple dependency graph.
>- Outputs act as file targets, so completed downloads are not repeated.
>- Recipes are short and easy to inspect.

But also noted that within the ```clean``` command the line 
> rm -f $(FASTA_FILE) $(GFF_FILE) $(FASTA_OUTPUT) $(GFF_OUTPUT)

was redundant because the entire directories are deleted in the next line. 

The AI recommended editing my Makefile, which contained the additional indexing commands, to fix clarity and indexing targets and make it more like Lauren's, or, alternatively, to add the indexing command's into Lauren's. I would honestly take the second option since mine was a bit of a mess! 

*I used the prompts "Compare the makefile hosted in this directory to this makefile: "\wsl.localhost\Ubuntu\home\vmabr\appbio-2026\week02\Makefile" Check for function and the organization/clarity of the code" and "OF the two makefiles, which would be the better option to download a genome to then open and analyze in a genome browser?"*

## Proposed Edits

- added a message for exisiting FASTA and GFF files 
- added the count command 
- removed the redundant clean line 

[Link to open pull request](https://github.com/lmm683/BMMB-852-lmm/pull/1)

*I used the prompts: "in this makefile, please add an error message to the all, fasta, and gff commands in place of the error "Nothing to be done" that lets you know if the file already exisits in that directory" and "can you change the messages in line 29-31 to show only if the GFF already exists at the start of the command, not after it's been run?"*

*Can you add this command to count the features in the gff? awk '!/^#/ && NF>=3 {count[$3]++; total++} END {for (k in count) print k, count[k]; print "TOTAL", total}' /home/laurenmags/work/week2/igv/gff/Z.bailii.gff3 | sort -k2,2nr*



