nextflow run genegenie.nf -profile TSF
--input /home/mandac/Documents/gene_genie/data/mtb_cut/samplesheet_h37rv_cut.csv \
--outdir /home/mandac/Downloads/test/GeneGenie-1.0/output \
--gtf /home/mandac/Downloads/test/GeneGenie-1.0/genome/h37rv/GCF_000195955.2_ASM19595v2_genomic.gff \
--genome_fasta /home/mandac/Downloads/test/GeneGenie-1.0/genome/h37rv/GCF_000195955.2_ASM19595v2_cds_from_genomic.fna \
--max_cpus 8 \
--max_memory 24.GB \
--max_time 48.h 
-profile TBF
