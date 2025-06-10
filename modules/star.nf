process STAR_ALIGN {
    publishDir "${params.outdir}/star", mode: 'copy'
    tag "$meta.id"
    label 'process_high'
    
    input:
    tuple val(meta), path(reads)
    path index
    path gtf
    
    output:
    tuple val(meta), path("*.sam"), emit: sam
    path "*Log.final.out", emit: log
    
    script:
    def single_end = meta.single_end
    def prefix = task.ext.prefix ?: "${meta.id}"
    def reads_command = single_end ? "--readFilesIn ${reads}" : "--readFilesIn ${reads[0]} ${reads[1]}"
    
    """
    STAR --genomeDir ${index} \
         ${reads_command} \
         --readFilesCommand zcat \
         --runThreadN ${task.cpus} \
         --outFileNamePrefix ${prefix}. \
         --outSAMtype SAM \
         --sjdbGTFfile ${gtf}
    """
}