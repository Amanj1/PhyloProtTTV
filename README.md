# PhyloProtTTV
A Nextflow DSL 1 pipeline to preform a protein phylogenetic analysis of fasta sequece data mainly focused on Torqe Teno Virus (TTV) Open Reading Frames (ORFs), but it is possible to tweak the pipeline for other purposes.
The phylogenetic trees are based on statistical metod called maximum likelihood with bootstrapping. We are using [RAxML-NG](https://academic.oup.com/bioinformatics/article/35/21/4453/5487384) (click on link to read article) tool to produce the trees. 

The first step is to filter out fasta sequences based on the length (currently it is set to 1). 
second step is to add the outgroups to the sequence fasta files after that we are running a multiple sequences alignment and trimming. 
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
In the pipeline we have two channels for inputs. First channel called "contig_files" requires a folder called "contig_files" and should include fasta files with the extension name '.fasta'. You will need to specify which ORF region the sequences belongs to in each file for the pipeline to add the correct outgroup. This pipeline is hardcoded for TTV ORFs and you can choose between ORF1, ORF2, ORF3 and ORF4. 
```
>10350_5_ORF1_AML
```
In the example above we can see that "ORF1" is mentioned in the fasta header for the input sequence.

In the second channel the input file should be sequences with the outgroups and it should be a folder called "req_files". You will need to specify in each fasta header to which ORF the sequence belongs to.
```
>YP_009115496.1_ORF1_SEAL_anellovirus4_OutGrp
```
In the example above we can see that "ORF1" is mentioned in the fasta header for the outgroup sequence.

This is useful if you plan on running different samples where each sample contains different ORFs and the outgroup file contains multiple ORF regions. If you don't add the ORF labels in the files the pipeline does not work properly and I don't have an error-handler.

## Installing using Conda environment
...
...

## Running 
The user should create two folders one called 'contig_files' and one called 'req_files' and store all samples in contig_files and the file with outgroups in req_files. All files must be in fasta format with the file extension ".fasta". 
It is also possible to change the following code line to the preferred filename and file extension, but the content of the files should be in fasta format:
```
//contig sequences
contig_files = Channel.fromFilePairs("${params.contigs}/*.fasta",size:1)

//sequences with outgroups
outgroup_file = Channel.fromFilePairs("${params.req}/*.fasta",size:1)
```

To run the pipeline in command line:
```
nextflow -C PhyloProtTTV.config run PhyloProtTTV.nf -profile amanj
```
To run the pipeline in command line and resume from cache memory:
```
nextflow -C PhyloProtTTV.config run PhyloProtTTV.nf -profile amanj -resume
```
### Changing sequence size filter
In the config file "PhyloProtTTV.config" you can change the sequence size to filter out sequences based on sequence length.
```
/* Pipeline running parameters */
params{
  seq_size=1
  publish_base_dir='phylogenetic_prot_output'
}
```
seq_size can be changed to the desirable minimum sequence length. It is currently set to 1 to include all fasta sequences. 

## Alternative to protein pipeline (if the pipeline does not work with your data)
I created a bash script containing multiple one-liners of for loops to run on multiple files within the current directory you are in. Some sequence in the input data is not accepted by the trimming program TrimAl used in the pipeline and I've tried to include an alternative trimming program, [Gblocks](http://molevol.cmima.csic.es/castresana/Gblocks.html), but for some reason Gblocks outputs an exit message when finishing the run and this makes the pipeline exit and I created this script instead.

### How to run the bash script (alternative for pipeline)
You will need to have all input data in a folder and move into the directory with the input data. In each input file you need to have both the sequences you want to run your phylogenetic study on and your outgroup sequences. Each file should be with the file extension ".fasta" and should be in fasta format. Everything else will be handled by the script. 

When running the script ignore the error messages from the command move (mv) and don't forget to adjust the number of threads in flags "--thread" and "--threads". The script will you use the file name as ID without the file extension. The ID will be used to name files and create folders. Each folder will be labeled with the ID and it will contain four folders. One folder for the protein sequence that you used as an input data called "protein_seq", one folder for the multiple sequence alignment called "mafft_aln", one for trimming results called "Gblocks_trim" and the final results with the tree data in "RAxML_data".

#### Gblocks settings
If you prefer other settings for trimming your data you can read about "Command line parameters" in this link [Gblocks documentation](http://molevol.cmima.csic.es/castresana/Gblocks/Gblocks_documentation.html).

#### Software versions used when I ran the script
Softwares
| Software | Version |
| -------- | ------- |
| MAFFT    | v7.455  |
| Gblocks  | 0.91b   |
| readseq  | 2.1.30  |
| RAxML-NG | v.0.9.0 |
