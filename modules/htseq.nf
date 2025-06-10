// modules/htseq.nf
process HTSEQ_COUNT {
    publishDir "${params.outdir}/htseq", mode: 'copy'
    tag "$meta.id"
    label 'process_medium'
    
    input:
    tuple val(meta), path(bam)
    path gtf

    output:
    tuple val(meta), path("${meta.id}.htseq.txt"), emit: counts
    path "versions.yml"                           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    htseq-count \\
        -f bam \\
        -r pos \\
        -s no \\
        -t CDS \\
        -i gene_id \\
        -n $task.cpus \\
        $args \\
        $bam \\
        $gtf \\
        > ${prefix}.htseq.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        htseq: \$(htseq-count --version 2>&1 | sed 's/^.*htseq-count //; s/Using.*\$//')
    END_VERSIONS
    """
}