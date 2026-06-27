# GeneGenie: RNA‑seq Preprocessing Pipeline for *Mycobacterium tuberculosis*

GeneGenie is a modular, containerized Nextflow DSL2 workflow for preprocessing *Mycobacterium tuberculosis* RNA‑seq data, from raw FASTQ files to gene‑level count tables and comprehensive QC reports.

It supports both single‑ and paired‑end sequencing formats and performs input validation, quality control, alignment, quantification, and reporting in a reproducible and scalable manner on HPC or container‑enabled environments.

---

## Overview and Statement of Need

RNA‑seq analysis in *Mycobacterium tuberculosis* research often relies on ad‑hoc scripts or generic RNA‑seq pipelines that are not tailored to pathogen‑specific requirements, tool combinations, or reproducible deployment in public‑health and molecular‑biology workflows.

GeneGenie addresses this gap by providing a pathogen‑focused, containerized preprocessing pipeline with validated combinations of QC, alignment, and quantification tools, standardized outputs, and modular Nextflow DSL2 components that can be easily integrated into downstream differential‑expression and functional‑analysis workflows.

The pipeline is intended for bioinformatics and molecular‑biology researchers working with *M. tuberculosis* RNA‑seq data, including public‑health laboratories and academic groups who need a reproducible, maintainable workflow rather than custom one‑off scripts.

---

## Related Work

Several Nextflow RNA‑seq pipelines exist for general transcriptomics analysis, but they typically target broad eukaryotic use cases and do not provide *M. tuberculosis*‑specific presets or profiles.

GeneGenie differs by:

- Focusing on *M. tuberculosis* and similar bacterial genomes.
- Providing curated tool profiles (QC, aligner, quantifier combinations) tested on *M. tuberculosis* datasets.
- Emphasizing containerized, pathogen‑specific preprocessing that slots into TB‑focused downstream analysis pipelines.

---

## Key Features

- **Input validation**  
  Uses `seqkit` for FASTQ validation; invalid samples are excluded and reported.

- **Quality control and trimming**  
  Supports `trimgalore` and `fastp` for adapter and quality trimming.

- **Alignment**  
  Offers `bowtie2` and `STAR` aligners, with automatic index generation.

- **BAM processing**  
  Converts SAM to BAM and performs sorting using `samtools`, with optional additional metrics via `picard`.

- **Quantification**  
  Supports both `featureCounts` and `HTSeq` for gene‑level quantification.

- **Comprehensive reporting**  
  Aggregates QC and summary metrics via `MultiQC`.

- **Containerized execution**  
  Runs in Singularity/Apptainer containers for reproducibility across environments.

- **Parameter profiles**  
  Predefined profiles for multiple tool combinations (QC, aligner, quantifier) to match different analysis preferences.

---

## Installation

### Requirements

- Nextflow 21.04.0 or higher
- Apptainer/Singularity
- Sufficient disk space for intermediate and output files

### Clone the repository

```bash
git clone https://github.com/ChipoManda/GeneGenie.git
cd GeneGenie
```

You can then follow the usage instructions below to download containers and run the pipeline.

---

## Project Directory Structure

A typical project directory structure is:

```text
GeneGenie-1.0/
  ├── containers/
  ├── modules/
  ├── output/
  ├── reference/
  │   ├── data
  │   ├── genome.gtf
  │   └── genome.fasta
  ├── workflows/
  │   └── rnaseq.nf
  ├── genegenie.nf
  ├── multiqc_config.yaml
  ├── nextflow.config
  ├── nextflowrun.sh
  └── README.md
```

---

## Containers

GeneGenie uses the following Singularity containers from BioContainers:

- `bowtie2:2.5.2--12e15c204b09f691` – read alignment
- `star:2.7.11a--0f5e3d475719bcac` – read alignment
- `htseq:2.0.3--3205f67d4c550865` – read counting
- `fastp:0.23.4--b69359f46d2a8ebf` – read QC and trimming
- `trim-galore:0.6.10--bc38c9238980c80e` – QC and adapter trimming
- `samtools:1.19.2--fbfb56ef5299fcef` – SAM/BAM processing
- `picard:3.4.0--2976616e7cbd4840` – BAM metrics/processing
- `subread:2.0.6--2dd2dd526de026fd` – feature counting
- `seqkit:2.10.0--9a5d37887d7c4e09` – FASTQ validation
- `multiqc:1.21--d44678e7b9933bf6` – reporting

Example command to download the STAR container:

```bash
singularity pull oras://community.wave.seqera.io/library/star:2.7.11a--0f5e3d475719bcac
```

---

## Quick Start

Assuming your reference files and containers are prepared, you can run the pipeline with a predefined profile:

```bash
nextflow run genegenie.nf -profile TBF \
  --input /path/to/reference/samplesheet.csv \
  --outdir /path/to/output \
  --gtf /path/to/reference/genome.gtf \
  --genome_fasta /path/to/reference/genome.fna
```

This will perform validation, QC, alignment, quantification, and generate a MultiQC report in the specified output directory.

---

## Profiles

GeneGenie supports several profiles for six tool combinations. Use the `-profile` flag to select a profile:

| Profile | QC tool    | Aligner | Quantification |
|---------|------------|---------|----------------|
| TBF     | trimgalore | bowtie2 | featurecounts  |
| TBH     | trimgalore | bowtie2 | htseq          |
| FSF     | fastp      | star    | featurecounts  |
| FSH     | fastp      | star    | htseq          |
| TSH     | trimgalore | star    | htseq          |
| TSF     | trimgalore | star    | featurecounts  |

Example:

```bash
nextflow run genegenie.nf -profile TBF
```

---

## Main Parameters

- `--input`  
  Path to input CSV file (required).

- `--read_type`  
  `single` or `paired` (default: `paired`).

- `--outdir`  
  Output directory (default: `${projectDir}/output`).

- `--genome_fasta`  
  Reference genome FASTA file (required).

- `--gtf`  
  GTF annotation file (required for quantification).

- `--qc_tool`  
  `trimgalore` or `fastp`.

- `--aligner`  
  `bowtie2` or `star`.

- `--quantification`  
  `featurecounts` or `htseq`.

You may override parameters at runtime, for example:

```bash
nextflow run genegenie.nf -profile TSF \
  --input /path/to/reference/samplesheet.csv \
  --outdir /path/to/output \
  --gtf /path/to/reference/genome.gtf \
  --genome_fasta /path/to/reference/genome.fna \
  --max_cpus 8 \
  --max_memory 16.GB \
  --max_time 48.h \
  --read_type single
```

---

## Workflow Steps

| Step              | Tool(s)              | Output directory                |
|-------------------|----------------------|---------------------------------|
| Input validation  | seqkit               | `seqkit/`                       |
| QC & trimming     | trimgalore / fastp   | `trimgalore/` or `fastp/`      |
| Alignment         | bowtie2 / STAR       | `bowtie2/` or `star/`          |
| BAM processing    | samtools (+ picard)  | `samtools/`                    |
| Quantification    | featureCounts / HTSeq| `featurecounts/` or `htseq/`   |
| Reporting         | MultiQC              | `multiqc/`                     |

All output files are organized under the specified `--outdir`.

---

## Output Files

Typical outputs include:

- `seqkit/validation_results.txt` – per‑sample validation status.
- `trimgalore/`, `fastp/` – cleaned FASTQ files and QC logs.
- `bowtie2/`, `star/` – alignment files (SAM/BAM).
- `samtools/` – sorted BAMs and alignment metrics.
- `featurecounts/`, `htseq/` – gene‑level count tables.
- `multiqc_report.html` – aggregated summary report.
- `pipeline_info/` – execution reports, timeline, trace, and DAG.

Invalid samples are excluded after validation and reported in the output.

---

## License

GeneGenie is released under the MIT License. See the `LICENSE` file for details.

---

## Citation

If you use GeneGenie in your research or publications, please cite:

> Chipo Manda (2026). GeneGenie: a Nextflow DSL2 pipeline for *Mycobacterium tuberculosis* RNA‑seq preprocessing (software).  
> https://github.com/ChipoManda/GeneGenie

A DOI‑based citation will be provided once the software is archived (e.g., via Zenodo) and the JOSS paper is published.

---

GeneGenie: a reproducible, containerized, and modular workflow for *M. tuberculosis* RNA‑seq preprocessing.
