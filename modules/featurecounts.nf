process FEATURECOUNTS {
    publishDir "${params.outdir}/featurecounts", mode: 'copy'
    tag "$meta.id"
    
    input:
    tuple val(meta), path(bam)
    path gtf
    
    output:
    tuple val(meta), path("*.txt"), emit: counts
    path "*.summary", emit: summary
    
    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def paired_end = meta.single_end ? '' : '-p'
    
    """
    featureCounts -a ${gtf} \
                  -o ${prefix}.featureCounts.CDS.txt \
                  -T ${task.cpus} \
                  ${paired_end} \
                  -t CDS \
                  -g gene_id \
                  ${bam}
    """
}