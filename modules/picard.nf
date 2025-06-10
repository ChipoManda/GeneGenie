process PICARD_MARK_DUPLICATES {
    publishDir "${params.outdir}/picard_mark_duplicates", mode: 'copy'
    tag "$meta.id"
    label 'process_high'

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("*_markdup.bam"), emit: bam
    tuple val(meta), path("*_markdup.bam.bai"), emit: bai
    tuple val(meta), path("*_markdup.metrics.txt"), emit: metrics
    
    script:
    """
    # Add read groups
    picard AddOrReplaceReadGroups \
        I=$bam \
        O=${meta.id}_with_rg.bam \
        RGID=${meta.id} \
        RGLB=lib1 \
        RGPL=illumina \
        RGPU=unit1 \
        RGSM=${meta.id}

    # Mark duplicates
    picard MarkDuplicates \
        INPUT=${meta.id}_with_rg.bam \
        OUTPUT=${meta.id}_markdup.bam \
        METRICS_FILE=${meta.id}_markdup.metrics.txt \
        CREATE_INDEX=true \
        VALIDATION_STRINGENCY=LENIENT \
        TMP_DIR=tmp

    # Ensure the index file is created with the correct name
    if [ -f ${meta.id}_markdup.bai ]; then
        mv ${meta.id}_markdup.bai ${meta.id}_markdup.bam.bai
    elif [ ! -f ${meta.id}_markdup.bam.bai ]; then
        picard BuildBamIndex \
            INPUT=${meta.id}_markdup.bam \
            OUTPUT=${meta.id}_markdup.bam.bai
    fi
    """
}