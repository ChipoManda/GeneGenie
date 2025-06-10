# Container Dependencies

This pipeline uses the following Singularity containers from BioContainers:

- `bowtie2:2.5.2--12e15c204b09f691` - Read alignment
- `star:2.7.11b--84fcc19fdfab53a4` - Read alignment  
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
# Download all containers
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