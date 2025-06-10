process TRIMGALORE {
    publishDir "${params.outdir}/trimgalore", mode: 'copy'
    tag "$meta.id"
    label 'process_medium'

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*{_val_1,_val_2,_trimmed}.fq.gz"), emit: reads
    tuple val(meta), path("*_trimming_report.txt"), emit: logs
    tuple val(meta), path("*_fastqc.html"), emit: fastqc_html
    tuple val(meta), path("*_fastqc.zip"), emit: fastqc_zip
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: (meta.id ?: meta.sample_id)
    def paired_end = meta.single_end ? '' : '--paired'
    
    """
    if command -v trim_galore &>/dev/null; then
        trim_galore \\
            $args \\
            --cores $task.cpus \\
            --gzip \\
            --fastqc \\
            $paired_end \\
            $reads
    else
        echo "Error: trim_galore is not installed or not in PATH. Please install trim_galore or use a Conda environment." >&2
        exit 1
    fi

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        trimgalore: \$(trim_galore --version 2>&1 | sed 's/^.*version //; s/Last.*\$//')
        cutadapt: \$(cutadapt --version)
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_val_1.fq.gz
    touch ${prefix}_val_2.fq.gz
    touch ${prefix}_trimming_report.txt
    touch ${prefix}_fastqc.zip
    touch ${prefix}_fastqc.html

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        trimgalore: \$(echo \$(trim_galore --version 2>&1) | sed 's/^.*version //; s/Last.*\$//')
        cutadapt: \$(cutadapt --version)
    END_VERSIONS
    """
}