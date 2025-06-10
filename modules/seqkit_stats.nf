process SEQKIT_STATS {
    publishDir "${params.outdir}/seqkit", mode: 'copy', pattern: '*.seqkit_stats.txt'
    tag "$meta.id"

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("${meta.id}.seqkit_stats.txt"), emit: stats
    path "versions.yml", emit: versions

    script:
    """
    seqkit stats $reads > ${meta.id}.seqkit_stats.txt 2>&1 || echo "Error processing ${meta.id}: \$?" >> ${meta.id}.seqkit_stats.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        seqkit: \$(seqkit version | sed 's/seqkit v//')
    END_VERSIONS
    """
}