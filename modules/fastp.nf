process FASTP {
    publishDir "${params.outdir}/fastp", mode: 'copy'
    tag "$meta.id"
    
    input:
    tuple val(meta), path(reads)
    
    output:
    tuple val(meta), path("*_trimmed.fastq.gz"), emit: reads
    tuple val(meta), path("*.json"), emit: json
    tuple val(meta), path("*.html"), emit: html
    
    script:
    def single_end = meta.single_end
    def prefix = task.ext.prefix ?: "${meta.id}"
    
    if (single_end) {
        """
        fastp \
            -i ${reads} \
            -o ${prefix}_trimmed.fastq.gz \
            -j ${prefix}.fastp.json \
            -h ${prefix}.fastp.html
        """
    } else {
        """
        fastp \
            -i ${reads[0]} \
            -I ${reads[1]} \
            -o ${prefix}_1_trimmed.fastq.gz \
            -O ${prefix}_2_trimmed.fastq.gz \
            -j ${prefix}.fastp.json \
            -h ${prefix}.fastp.html
        """
    }
}