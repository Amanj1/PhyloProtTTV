
for i in `basename -a *.fasta | sed 's/\.fasta//'`;do mkdir $i ;done
for i in `basename -a *.fasta | sed 's/\.fasta//'`;do mkdir $i\/Gblocks_trim ;done
for i in `basename -a *.fasta | sed 's/\.fasta//'`;do mkdir $i\/mafft_aln ;done
for i in `basename -a *.fasta | sed 's/\.fasta//'`;do mkdir $i\/RAxML_data ;done
for i in `basename -a *.fasta | sed 's/\.fasta//'`;do mkdir $i\/protein_seq ;done

for i in `basename -a *.fasta | sed 's/\.fasta//'`;do mafft --thread 10 --threadtb 5 --threadit 0 --inputorder --anysymbol --auto $i\.fasta > $i\_mafft_aln.fasta ; done

for i in `basename -a *_mafft_aln.fasta | sed 's/\_mafft_aln.fasta//'`;do Gblocks $i\_mafft_aln.fasta -t=p -b1=$( grep -c ">" $i\_mafft_aln.fasta | awk '{x=1 + $1/2; print int(x)}' ) -b2=$( grep -c ">" $i\_mafft_aln.fasta | awk '{x=$1 * 0.85; print int(x)}' ) -b3=8 -b4=5 -b5=h -b6=y ; done

for i in `basename -a *_mafft_aln.fasta | sed 's/\_mafft_aln.fasta//'`;do readseq $i\_mafft_aln.fasta-gb -all -format=FASTA -output=$i\_Gblocks_trimmed.fasta ; done

for i in `basename -a *_mafft_aln.fasta | sed 's/\_mafft_aln.fasta//'`;do raxml-ng --msa $i\_Gblocks_trimmed.fasta --model LG --opt-branches on --opt-model on --tree pars{10},rand{10} --all --bs-trees 100 --force --threads 15 --prefix $i ;done


for i in `basename -a *.fasta | sed 's/\.fasta//'`;do mv $i\.fasta $i\/protein_seq/ ;done
for i in `basename -a *_mafft_aln.fasta | sed 's/\_mafft_aln.fasta//'`;do mv $i\_mafft_aln.fasta $i\/mafft_aln/ ;done
for i in `basename -a *_mafft_aln.fasta-gb | sed 's/\_mafft_aln.fasta-gb//'`;do mv $i*raxml* $i\/RAxML_data/ ;done
for i in `basename -a *_mafft_aln.fasta-gb | sed 's/\_mafft_aln.fasta-gb//'`;do mv $i*.fasta* $i\/Gblocks_trim/ ;done
