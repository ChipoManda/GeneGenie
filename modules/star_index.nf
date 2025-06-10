process STAR_INDEX {
    tag "$genome_fasta"
    container "${projectDir}/containers/star.sif"
    
    input:
    path genome_fasta
    path gtf
    
    output:
    path "star_index", emit: index
    
    script:
    """
    STAR --runMode genomeGenerate \
         --genomeDir star_index \
         --genomeFastaFiles ${genome_fasta} \
         --sjdbGTFfile ${gtf} \
         --runThreadN ${task.cpus}
    """
}