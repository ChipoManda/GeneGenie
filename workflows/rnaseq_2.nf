nextflow.enable.dsl = 2
// Import modules
include { TRIMGALORE } from '../modules/trimgalore'
include { FASTP } from '../modules/fastp'
include { BOWTIE2_BUILD } from '../modules/bowtie2_build'
include { BOWTIE2_ALIGN } from '../modules/bowtie2'
include { STAR_INDEX } from '../modules/star_index'
include { STAR_ALIGN } from '../modules/star'
include { SAMTOOLS as SAMTOOLS_VIEW; SAMTOOLS as SAMTOOLS_SORT } from '../modules/samtools'
include { FEATURECOUNTS } from '../modules/featurecounts'
include { HTSEQ_COUNT } from '../modules/htseq'
include { MULTIQC } from '../modules/multiqc'
include { SEQKIT_STATS } from '../modules/seqkit_stats'

workflow RNASEQ {
    take:
    input_csv

    main:
    // Input validation
    if (!params.genome_fasta) {
        error "Genome FASTA file not specified with params.genome_fasta"
    }
    
    log.info "Running workflow in ${params.read_type}-end mode"

    // Create input channel based on params.read_type but allow both CSV formats
    input_reads = Channel
        .fromPath(input_csv)
        .splitCsv(header:true)
        .map { row -> 
            def meta = [id: row.sample_id, single_end: params.read_type == 'single']
            def reads
            
            if (params.read_type == 'paired') {
                // Check for standard paired-end format columns
                if (row.containsKey('fastq_1') && row.containsKey('fastq_2')) {
                    reads = [file(row.fastq_1), file(row.fastq_2)]
                } else {
                    error "Paired-end mode specified but required columns (fastq_1/fastq_2) missing for sample ${row.sample_id}"
                }
                
                if (reads[0] == null || reads[1] == null) {
                    error "Paired-end files missing for sample ${row.sample_id}"
                }
            } else { // Single-end mode
                // Check for the fastq column in single-end mode
                if (row.containsKey('fastq')) {
                    reads = file(row.fastq)
                } else {
                    error "Single-end mode specified but required column (fastq) missing for sample ${row.sample_id}"
                }
                
                if (reads == null) {
                    error "Single-end file missing for sample ${row.sample_id}"
                }
            }
            
            [meta, reads]
        }

    genome_fasta = file(params.genome_fasta)
    gtf = params.gtf ? file(params.gtf) : null
 
    ch_multiqc_files = Channel.empty()


    // Validate input reads with seqkit
    SEQKIT_STATS(input_reads)

    // Function to check for valid seqkit stats output
    def isValidStats = { content ->
        !content.toLowerCase().contains("erro") // Valid if "erro" is not present (case-insensitive)
    }

    // Filter out samples with invalid stats and join with input reads
    valid_reads = SEQKIT_STATS.out.stats
        .map { meta, stats -> 
            def content = stats.text
            if (!isValidStats(content)) {
                log.warn "Seqkit stats failed for sample ${meta.id}. This sample will be excluded from further processing."
                return null
            } else {
                return [meta, stats]
            }
        }
        .filter { it != null }
        .join(input_reads)
        .map { meta, stats, reads -> [meta, reads] }

    // Count valid and failed samples
    valid_count = valid_reads.count()
    total_count = SEQKIT_STATS.out.stats.count()


    // Display failed samples
    SEQKIT_STATS.out.stats
        .map { meta, stats -> 
            def content = stats.text
            return [meta.id, !isValidStats(content)]
        }
        .filter { id, failed -> failed }
        .map { id, failed -> id }
        .collect()
        

    // Display counts
    valid_count.combine(total_count)
        .view { valid, total ->
            def failed = total - valid
            "Number of samples failing SEQKIT_STATS: $failed out of $total processed samples"
        }

    
    // QC & Trimming
    if (params.qc_tool == 'trimgalore') {
        TRIMGALORE(valid_reads)
        trimmed_reads = TRIMGALORE.out.reads
        ch_multiqc_files = ch_multiqc_files.mix(
            TRIMGALORE.out.fastqc_html.map { meta, html -> [meta, html] },
            TRIMGALORE.out.fastqc_zip.map { meta, zip -> [meta, zip] },
            TRIMGALORE.out.logs.map { meta, log -> [meta, log] }
        )
    } else if (params.qc_tool == 'fastp') {
        FASTP(valid_reads)
        trimmed_reads = FASTP.out.reads
        ch_multiqc_files = ch_multiqc_files.mix(
            FASTP.out.json.map { json -> [[:], json] }
        )
    } else {
        trimmed_reads = valid_reads
        }

    // Alignment (including index building if necessary)
    if (params.aligner == 'star') {
        STAR_INDEX(genome_fasta, gtf)
        star_index = STAR_INDEX.out.index

        STAR_ALIGN(trimmed_reads, star_index, gtf)
        aligned_reads = STAR_ALIGN.out.sam
        ch_multiqc_files = ch_multiqc_files.mix(
            STAR_ALIGN.out.log.map { log -> [[:], log] }
        )
    } else if (params.aligner == 'bowtie2') {
        def index_prefix = "bowtie2_index"
        BOWTIE2_BUILD(genome_fasta, index_prefix)
        bowtie2_index = BOWTIE2_BUILD.out.index

        BOWTIE2_ALIGN(
            trimmed_reads,
            bowtie2_index.collect()
        )
        aligned_reads = BOWTIE2_ALIGN.out.sam
        ch_multiqc_files = ch_multiqc_files.mix(BOWTIE2_ALIGN.out.log.map { log -> [[:], log] })
    } else {
        error "Invalid aligner specified. Choose either 'star' or 'bowtie2'."
        }
    
    
    // SAMtools view (convert SAM to BAM)
    SAMTOOLS_VIEW(aligned_reads)
        bam_files = SAMTOOLS_VIEW.out.bam

    // SAMtools sort
    SAMTOOLS_SORT(bam_files)
        sorted_bam = SAMTOOLS_SORT.out.bam
    
    // Quantification
    if (params.quantification == 'featurecounts') {
        FEATURECOUNTS(sorted_bam, gtf)
        ch_counts = FEATURECOUNTS.out.counts
        ch_summary = FEATURECOUNTS.out.summary
        ch_multiqc_files = ch_multiqc_files.mix(
            FEATURECOUNTS.out.summary.map { summary -> [[:], summary] }
        )
    } else if (params.quantification == 'htseq') {
        HTSEQ_COUNT(sorted_bam, gtf)
        ch_counts = HTSEQ_COUNT.out.counts
        ch_summary = Channel.empty()
        ch_multiqc_files = ch_multiqc_files.mix(HTSEQ_COUNT.out.counts)
    } else {
        error "Invalid quantification method specified. Choose either 'featurecounts' or 'htseq'."
        }

         
    // Run MultiQC
    MULTIQC(
        ch_multiqc_files
            .map { meta, file -> file }
            .collect()
        )

    emit:
        trimmed_reads = trimmed_reads
        aligned_reads = aligned_reads
        bam_files     = bam_files
        sorted_bam    = sorted_bam
        counts        = ch_counts
        counts_summary = ch_summary
        multiqc_report = MULTIQC.out.report
    
}

