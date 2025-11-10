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
```
project_root/
├── genegenie.nf                    # Your main Nextflow workflow script
├── nextflow.config                 # Main configuration file
├── multiqc_config.yaml             # MultiQC configuration
│
├── reference/                      # Reference files
│   ├── data
│   ├── genome.gtf                  # GTF annotation file
│   └── genome.fasta                # Reference genome FASTA file
│
├── containers/                     
│
│
└──  output/
```
### Downloading containers
This pipeline uses the following Singularity containers from BioContainers:

- `bowtie2:2.5.2--12e15c204b09f691` - Read alignment
- `star:2.7.11a--0f5e3d475719bcac` - Read alignment  
- `htseq:2.0.3--3205f67d4c550865` - Read counting
- `fastp:0.23.4--b69359f46d2a8ebf` - Read Quality control and trimming
- `trim-galore:0.6.10--bc38c9238980c80e` - Quality control and adapter trimming
- `samtools:1.19.2--fbfb56ef5299fcef` - SAM/BAM processing
- `picard:3.4.0--2976616e7cbd4840` - BAM processing
- `subread:2.0.6--2dd2dd526de026fd` - Feature counting
- `seqkit:2.10.0--9a5d37887d7c4e09` - Sequence toolkit (Fastq validation)
- `multiqc:1.21--d44678e7b9933bf6` - Reporting

## Usage

### Download containers:

```bash
singularity pull oras://community.wave.seqera.io/library/trim-galore:0.6.10--bc38c9238980c80e
singularity pull oras://community.wave.seqera.io/library/fastp:0.24.0--0397de619771c7ae
singularity pull oras://community.wave.seqera.io/library/star:2.7.11a--0f5e3d475719bcac
singularity pull oras://community.wave.seqera.io/library/bowtie2:2.5.2--12e15c204b09f691 
singularity pull oras://community.wave.seqera.io/library/subread:2.0.6--2dd2dd526de026fd
singularity pull oras://community.wave.seqera.io/library/htseq:2.0.3--3205f67d4c550865
sigularity pull oras://community.wave.seqera.io/library/multiqc:1.21--d44678e7b9933bf6
sigularity pull oras://community.wave.seqera.io/library/samtools:1.19.2--fbfb56ef5299fcef
sigularity pull oras://community.wave.seqera.io/library/picard:3.4.0--2976616e7cbd4840
```

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


> GeneGenie   
>  
> 🧞‍♂️ Reproducible, containerized, and modular workflow for *M. tuberculosis* RNA-seq preprocessing
---
