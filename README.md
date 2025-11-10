# 🧞‍♂️ GeneGenie: RNA-seq Preprocessing Pipeline for *Mycobacterium tuberculosis*

GeneGenie is a modular, containerized workflow for preprocessing *Mycobacterium tuberculosis* RNA-seq data. 

It supports both single- and paired-end sequencing formats and performs quality control, alignment, quantification, and reporting. 

The pipeline is implemented in Nextflow DSL2, ensuring reproducibility and scalability.

---

## ✨ Key Features

- **Input Validation:** Uses `seqkit` for FASTQ validation; invalid samples are excluded and reported.
- **Quality Control & Trimming:** Supports `trimgalore` and `fastp` for adapter and quality trimming.
- **Alignment:** Offers `bowtie2` and `STAR` aligners, with automatic index generation.
- **BAM Processing:** SAM to BAM conversion, sorting using `samtools`
- **Quantification:** Supports both `featureCounts` and `HTSeq` for gene-level quantification.
- **Comprehensive Reporting:** Aggregates QC and summary metrics via `MultiQC`.
- **Containerized Execution:** The pipeline runs in a dedicated Singularity container for reproducibility.
- **Parameter Profiles:** Predefined profiles for possible tool combinations.

---

## 🏃‍♂️ Usage

### Project directory structure:

project_root/
├── genegenie.nf                    # Your main Nextflow workflow script
├── nextflow.config                 # Main configuration file
├── multiqc_config.yaml             # MultiQC configuration
│
├── reference/                      # Reference genome files
│   ├── genomic_h37rv.gtf           # GTF annotation file
│   └── genomic_h37rv.fna           # Genome FASTA file
│
├── containers/                     
│    ├── htseq_subread_trim-galore_aeb6b8b7800db0b0.sif           
│    ├── bowtie2_fastp_samtools_star_pruned:5f151da513ade4ad.sif
│    └── multiqc:1.21--d44678e7b9933bf6.sif
│
│
└──  output/


### Running with a Profile

GeneGenie supports several profiles for six tool combinations. Use the `-profile` flag to select a profile:

| Profile | QC Tool     | Aligner  | Quantification   |
|---------|-------------|----------|------------------|
| TBF     | trimgalore  | bowtie2  | featurecounts    |
| TBH     | trimgalore  | bowtie2  | htseq            |
| FSF     | fastp       | star     | featurecounts    |
| FSH     | fastp       | star     | htseq            |
| TSH     | trimgalore  | star     | htseq            |
| TSF     | trimgalore  | star     | featurecounts    |

**Example use:**
```bash
nextflow run GeneGenie.nf -profile TBF
```

### Custom Parameters

You may override any parameter at runtime:

```bash
nextflow run GeneGenie.nf \
  --input /path/to/samplesheet.csv \
  --read_type paired or single \
  --outdir /path/to/output \
  --genome_fasta /path/to/genomic_h37rv.fna \
  --gtf /path/to/genomic_h37rv.gtf
```

**Main parameters:**
- `--input`: Path to input CSV file (required)
- `--read_type`: `single` or `paired` (default: `paired`)
- `--outdir`: Output directory (default: `${projectDir}/output`)
- `--genome_fasta`: Reference genome FASTA file (required)
- `--gtf`: GTF annotation file (required for quantification)
- `--qc_tool`: `trimgalore` or `fastp`
- `--aligner`: `bowtie2` or `star`
- `--quantification`: `featurecounts` or `htseq`

---

## 🛠️ Workflow Steps

| Step                | Tool(s)                | Output Directory         |
|---------------------|------------------------|-------------------------|
| Input Validation    | seqkit                 | `seqkit/`               |
| QC & Trimming       | trimgalore / fastp     | `trimgalore/` or `fastp/` |
| Alignment           | bowtie2 / STAR         | `bowtie2/` or `star/`   |
| BAM Processing      | samtools               | `samtools/`  |
| Quantification      | featureCounts / HTSeq  | `featurecounts/` or `htseq/` |
| Reporting           | MultiQC                | `multiqc/`   |

All output files are organized under the specified `--outdir`.

---

## 📦 Output Files

- `seqkit/validation_results.txt`: Per-sample validation status.
- `trimgalore/`, `fastp/`: Cleaned FASTQ and QC logs.
- `bowtie2/`, `star/`: Alignment files (SAM/BAM).
- `samtools/`: Sorted BAMs, alignment metrics.
- `featurecounts/`, `htseq/`: Gene count tables.
- `multiqc_report.html`: Aggregated summary report.
- `pipeline_info/`: Execution reports, timeline, trace, and DAG.

---

## ⚡ Requirements

- Nextflow 21.04.0 or higher
- Apptainer/Singularity
- Sufficient disk space for intermediate and output files

---

## 🧠 Note

- Invalid samples are excluded after validation and reported in the output.

---


> GeneGenie provides a flexible, reproducible workflow for *M. tuberculosis* RNA-seq preprocessing.  
>  
> 🧞‍♂️ Reliable, containerized, and modular.
---
