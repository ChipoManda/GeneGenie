process BOWTIE2_ALIGN {
    publishDir "${params.outdir}/bowtie2", mode: 'copy'
    tag "$meta.id"
    label 'process_high'
    
    input:
    tuple val(meta), path(reads)
    path index
    
    output:
    tuple val(meta), path("*.sam"), emit: sam
    path "*.log", emit: log
    
    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def reads_command = meta.single_end ? "-U ${reads}" : "-1 ${reads[0]} -2 ${reads[1]}"
    def index_name = index.name.tokenize('.')[0]
    
    """
    bowtie2 -x ${index}/${index_name} \
            ${reads_command} \
            -p ${task.cpus} \
            -S ${prefix}.sam \
            2> ${prefix}.log\
            --rg "LB:lib1" \
            --rg "PL:illumina" \
            --rg "PU:unit1" \
            --rg "SM:${meta.id}" 
           
    """
}