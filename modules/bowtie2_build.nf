process BOWTIE2_BUILD {
    publishDir "${params.outdir}/bowtie2", mode: 'copy'
    tag "$genome_fasta"
     
    input:
    path genome_fasta
    val prefix
    
    output:
    path "bowtie2_index", emit: index
    
    script:
    """
    mkdir -p bowtie2_index
    bowtie2-build ${genome_fasta} bowtie2_index/${prefix}
    """
}