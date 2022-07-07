## Introduction
This is the code used for the microbiome analysis published in `insert link
when published`.

The raw sequencing data can be obtained from the NCBI short read archive, see
the published paper for details. 


## Workflow
The raw sequencing data was processed using qiime2 2020.1128, the relevant code
is in the script file: qiime_workflow.sh.
Downstream processing and filtering of microbiome data can be found in:
initial_analysis.Rmd.
differential abundance analysis is available as the standalone script:
cmp_microbiome.R.
additional_microbiome_analysis.Rmd contains additional analyses, relying on
data after initial processing.

The scripts contain the entirety of code used, including many analyses that
were not included in the published manuscripts.
The larger scripts will soon be updated, for improved readability.

For questions, contact the owner of the repository.
