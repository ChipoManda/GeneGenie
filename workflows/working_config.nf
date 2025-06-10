profiles {
    TBF {
        params.qc_tool = 'trimgalore'
        params.aligner = 'bowtie2'
        params.samtools = true
        params.quantification = 'featurecounts'
    }
    TBH {
        params.qc_tool = 'trimgalore'
        params.aligner = 'bowtie2'
        params.samtools = true
        params.quantification = 'htseq'
    }
    FSF {
        params.qc_tool = 'fastp'
        params.aligner = 'star'
        params.samtools = true
        params.quantification = 'featurecounts'
    }
    FSH {
        params.qc_tool = 'fastp'
        params.aligner = 'star'
        params.samtools = true
        params.quantification = 'htseq'
    }
    TSH {
        params.qc_tool = 'trimgalore'
        params.aligner = 'star'
        params.samtools = true
        params.quantification = 'htseq'
    }
    TSF {
        params.qc_tool = 'trimgalore'
        params.aligner = 'star'
        params.samtools = true
        params.quantification = 'featurecounts'
    }
}
params {
    input = "/home/cmanda/reference/data_set/mtb_full/sra_single/SRA_mtb.csv"
    outdir = "${projectDir}/output"
    gtf = "${projectDir}/reference/genomic_h37rv.gtf"
    genome_fasta = "${projectDir}/reference/genomic_h37rv.fna"
    lib_type = 'A'
    bowtie2_index = null
    star_index = null
    multiqc_config = "${projectDir}/multiqc_config.yaml"
    save_unaligned = false  // or true
    save_hostremoval_bam = true
    save_hostremoval_unmapped = true
    nextflow.preview.output = true
    read_type = 'single'  
}

process {
    publishDir = [
        path: { "${params.outdir}/${task.process.tokenize(':')[-1].toLowerCase()}" },
        mode: 'copy',
        saveAs: { filename -> filename.equals('versions.yml') ? null : filename }
    ]
    
    withName: 'TRIMGALORE' {
        container = "/home/cmanda/containerised_workflow/containers/trim-galore_0.6.10--bc38c9238980c80e.sif"
        publishDir = [
            path: { "${params.outdir}/trimgalore" },
            mode: 'copy',
            saveAs: { filename -> filename.equals('versions.yml') ? null : filename }
        ]
    }
    withName: 'SEQKIT_STATS' {
        container = "/home/cmanda/containerised_workflow/containers/seqkit_2.10.0--9a5d37887d7c4e09.sif"
        publishDir = [
            path: { "${params.outdir}/seqkit" },
            mode: 'copy',
            saveAs: { filename -> filename }
        ]
        errorStrategy = 'ignore'    
    }
    withName: 'FASTP' {
        container = "/home/cmanda/containerised_workflow/containers/fastp_0.23.4--b69359f46d2a8ebf.sif"
        publishDir = [
            path: { "${params.outdir}/fastp" },
            mode: 'copy',
            saveAs: { filename -> filename.equals('versions.yml') ? null : filename }
        ]
    }
    withName: 'BOWTIE2_ALIGN' {
        container = "/home/cmanda/containerised_workflow/containers/bowtie2_2.5.2--12e15c204b09f691.sif"
        publishDir = [
            path: { "${params.outdir}/bowtie2" },
            mode: 'copy',
            saveAs: { filename -> filename.equals('versions.yml') ? null : filename }
        ]
    }
    withName: 'BOWTIE2_BUILD' {
        container = "/home/cmanda/containerised_workflow/containers/bowtie2_2.5.2--12e15c204b09f691.sif"
        publishDir = [
            path: { "${params.outdir}/bowtie2_index" },
            mode: 'copy',
            saveAs: { filename -> filename }
        ]
    }
    withName: 'STAR_ALIGN' {
        container = "/home/cmanda/containerised_workflow/containers/star_2.7.11b--84fcc19fdfab53a4.sif"
        publishDir = [
            path: { "${params.outdir}/star" },
            mode: 'copy',
            saveAs: { filename -> filename.equals('versions.yml') ? null : filename }
        ]
    }
    withName: 'STAR_INDEX' {
        container = "/home/cmanda/containerised_workflow/containers/star_2.7.11b--84fcc19fdfab53a4.sif"
        publishDir = [
            path: { "${params.outdir}/star_index" },
            mode: 'copy',
            saveAs: { filename -> filename }
        ]
    }
    process {
    withName: 'SAMTOOLS_.*' {
        container = "/home/cmanda/containerised_workflow/containers/samtools_1.19.2--fbfb56ef5299fcef.sif"
        publishDir = [
            path: { "${params.outdir}/samtools" },
            mode: 'copy',
            saveAs: { filename -> filename }
        ]
    }
}
    withName: 'FEATURECOUNTS' {
        container = "/home/cmanda/containerised_workflow/containers/subread_2.0.6--2dd2dd526de026fd.sif"
        publishDir = [
            path: { "${params.outdir}/featurecounts" },
            mode: 'copy',
            saveAs: { filename -> filename }
        ]
    }
    withName: 'HTSEQ_COUNT' {
        container = "/home/cmanda/containerised_workflow/containers/htseq_2.0.3--3205f67d4c550865.sif"
        publishDir = [
            path: { "${params.outdir}/htseq" },
            mode: 'copy',
            saveAs: { filename -> filename }
        ]
    }
    withName: 'SAMTOOLS' {
        container = "/home/cmanda/containerised_workflow/containers/samtools_1.19.2--fbfb56ef5299fcef.sif"
        publishDir = [
            path: { "${params.outdir}/samtools" },
            mode: 'copy',
            saveAs: { filename -> filename }
        ]
    }
}

wave {
    enabled = false
}

apptainer {
    enabled = true
    autoMounts = true
}

report {
    enabled = true
    overwrite = true
    file = "${params.outdir}/pipeline_info/execution_report.html"
}

timeline {
    enabled = true
    overwrite = true
    file = "${params.outdir}/pipeline_info/execution_timeline.html"
}

trace {
    enabled = true
    overwrite = true
    file = "${params.outdir}/pipeline_info/execution_trace.txt"
}

dag {
    enabled = true
    overwrite = true
    file = "${params.outdir}/pipeline_info/pipeline_dag.svg"
}

