process SAMTOOLS_VIEW {
    tag "$meta.id"
    
    input:
    tuple val(meta), path(input_file)
    
    output:
    tuple val(meta), path("*.bam"), emit: bam
    path "versions.yml", emit: versions
    
    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def args = task.ext.args ?: ''
    
    """
    samtools view -bS $args -@ ${task.cpus} $input_file > ${prefix}.bam
    
    cat <<-END_VERSIONS > versions.yml
    "SAMTOOLS_VIEW":
        samtools: \$(samtools --version | sed '1!d; s/samtools //')
    END_VERSIONS
    """
}