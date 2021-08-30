# Protein-phylogenetic-tree-pipeline-focused-on-TTV-ORFs
A Nextflow DSL 1 pipeline to preform a protein phylogenetic analysis of fasta sequece data mainly focused on Torqe Teno Virus (TTV) Open Reading Frames (ORFs), but it is possible to tweak the pipeline for other purposes.
The phylogenetic trees are based on statistical metod called maximum likelihood with bootstrapping. We are using [RAxML-NG](https://academic.oup.com/bioinformatics/article/35/21/4453/5487384) (click on link to read article) tool to produce the trees. 

The first step is to filter out fasta sequences based on the length (currently it is set to 0). 
2nd step is to add the outgroups to the sequence fasta files after that we are running a multiple sequences alignment and trimming. 
The Final step is running RAxML.

 ## Software requirements 
 All versions of the softwares should be compatible with the pipeline. Currently I don't have any conflicts between softwares. 
 - [Nextflow DSL1](https://www.nextflow.io/)
 - [Python3](https://www.python.org/downloads/)
 - [seqtk](https://github.com/lh3/seqtk)
 - [MAFFT](https://mafft.cbrc.jp/alignment/software/)
 - [trimAl](http://trimal.cgenomics.org/)
 - [RAxML-NG](https://github.com/amkozlov/raxml-ng)

#### Software versions used when developing pipeline
Softwares
| Software | Version |
| -------- | ------- |
| Nextflow | 19.07.0 |
| Python   | 3.7.8   |
| Seqtk    | 1.3-r106|
| MAFFT    | v7.455  |
| trimAl   | 1.2rev59|
| RAxML-NG | v.0.9.0 |

## Required files
