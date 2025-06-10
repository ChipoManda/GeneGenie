process VALIDATE_FASTQ {
    publishDir "${params.outdir}/fastutils", mode: 'copy'
    tag "$meta.id"
    
    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path(reads), emit: validated_reads
    path "*.log", emit: log

    script:
    def input = reads.collect { "-i $it" }.join(' ')
    """
    fastq_info ${input} > ${sample_id}_validation.log
    """
}