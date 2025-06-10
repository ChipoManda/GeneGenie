process SAMTOOLS_SORT {
    tag "$meta.id"
    
    input:
    tuple val(meta), path(input_file)
    
    output:
    tuple val(meta), path("*.sorted.bam"), emit: bam
    path "versions.yml", emit: versions
    
    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def args = task.ext.args ?: ''
    
    """
    samtools sort $args -@ ${task.cpus} -o ${prefix}.sorted.bam $input_file
    
    cat <<-END_VERSIONS > versions.yml
    "SAMTOOLS_SORT":
        samtools: \$(samtools --version | sed '1!d; s/samtools //')
    END_VERSIONS
    """
}