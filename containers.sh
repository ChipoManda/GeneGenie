# This pipeline uses 3 Singularity containers from BioContainers:

### Download containers:

```bash
singularity pull oras://community.wave.seqera.io/library/htseq_subread_trim-galore:aeb6b8b7800db0b0
singularity pull oras://community.wave.seqera.io/library/bowtie2_fastp_samtools_star_pruned:5f151da513ade4ad
singularity pull oras://community.wave.seqera.io/library/multiqc:1.21--d44678e7b9933bf6
```
