nextflow run genegenie.nf -profile TSF \
--input /path/to/reference/samplesheet.csv \
--outdir /path/to/output \
--gtf /path/to/reference/genomic.gtf \
--genome_fasta /path/to/reference/genomic.fna \
--max_cpus 8 \
--max_memory 16.GB \
--max_time 48.h \
--read_type single
