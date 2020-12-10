#!/usr/bin/env nextflow

/*
nextflow -C phylogenetic_tree_prot_seq.nf.config run phylogenetic_tree_prot_seq.nf -profile amanj
*/

params.contigs='contig_files'
params.req='req_files'

/* input files */
//contig sequences
contig_files = Channel.fromFilePairs("${params.contigs}/*.fa",size:1)

//sequences with outgroups
outgroup_file = Channel.fromFilePairs("${params.req}/*.fa",size:1)

/**

**/

process filter_contigs{
  tag {"${sample_id}"}

  publishDir "${params.publish_base_dir}/${sample_id}/selecting_files_with_seq", mode:'link'

  input:
  set sample_id, contig from contig_files 
  
  output:
  set sample_id, stdout, "${sample_id}_selected_seq_filt.fa" into filt_contigs
  
  script:
""" 
 seqtk seq -L 0 ${contig[0]} > "${sample_id}_selected_seq_filt.fa"
  nr_of_seq=\$(cat "${sample_id}_selected_seq_filt.fa" | grep ">" | wc -l)
 if [ \$nr_of_seq -eq 0 ]
 then
    echo false
 else
    echo true
 fi
"""
}

combine_filt_contigs_outgroup = filt_contigs.filter({ it[1].contains("true") }).combine(outgroup_file)

process add_outgroup_to_seq{
  tag {"${sample_id}"}

  publishDir "${params.publish_base_dir}/${sample_id}/outgroup_added", mode:'link'

  input:
  set sample_id, bool, contig, outgrp_name, outgrp_seq from combine_filt_contigs_outgroup 
  
  output:
  set sample_id, "${sample_id}_selected_seq_filt_with_outgrp.fa" into filt_contigs_and_outgrp
  
  script:
""" 
#!/usr/bin/python 

f1 = open("${contig}","r+")
contigs = f1.readlines()
f2 = open("${outgrp_seq[0]}","r+")
outgrp = f2.readlines()
f3 = open("${sample_id}_selected_seq_filt_with_outgrp.fa", "a+")
val = 0
if "ORF1" in "${sample_id}":
    val = 1
elif "ORF2" in "${sample_id}":
    val = 2
elif "ORF3" in "${sample_id}":
    val = 3
elif "ORF4" in "${sample_id}":
    val = 4

for i in range(len(outgrp)):
    if val == 1 and "ORF1" in outgrp[i]:
        f3.write(outgrp[i])
        f3.write(outgrp[i+1])
    elif val == 2 and "ORF2" in outgrp[i]:
        f3.write(outgrp[i])
        f3.write(outgrp[i+1])
    elif val == 3 and "ORF3" in outgrp[i]:
        f3.write(outgrp[i])
        f3.write(outgrp[i+1])
    elif val == 4 and "ORF4" in outgrp[i]:
        f3.write(outgrp[i])
        f3.write(outgrp[i+1])
for x in contigs:
    f3.write(x)
f1.close()
f2.close()
f3.close()
"""
}


process mafft{
  tag {"${sample_id}"}

  publishDir "${params.publish_base_dir}/${sample_id}/mafft", mode:'link'

  input:
  set sample_id, seq from filt_contigs_and_outgrp 
  
  output:
  set sample_id,"${sample_id}_mafft_alignment.fasta" into mafft_out
  
  script:
""" 
 mafft --thread ${task.cpus} --threadtb 5 --threadit 0 --inputorder --anysymbol --auto ${seq} > "${sample_id}_mafft_alignment.fasta" 
"""
}

process trimAl{
  tag {"${sample_id}"}

  publishDir "${params.publish_base_dir}/${sample_id}/trimAl", mode:'link'

  input:
  set sample_id, mafft_aln from mafft_out 
  
  output:
  set sample_id, "${sample_id}_trimAl_trimmed.fasta" into trim_out
  
  script:
""" 
 trimal -in ${mafft_aln} -out "${sample_id}_trimAl_trimmed.fasta" -gt 0.9
"""
}

process RAxML{
  tag {"${sample_id}"}

  publishDir "${params.publish_base_dir}/${sample_id}/RAxML", mode:'link'

  input:
  set sample_id, seq from trim_out 
  
  output:
  set sample_id, "${sample_id}*" into raxml_out
  
  script:
""" 
  raxml-ng --msa ${seq} --model LG --opt-branches on --opt-model on --tree pars{10},rand{10} --all --bs-trees 100 --force --threads ${task.cpus} --prefix ${sample_id}

"""
}





