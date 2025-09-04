#!/bin/bash

# Create required directory structure
echo "Creating project directories..."
mkdir -p containers output reference multiqc_config pipeline_info

# Pull Apptainer containers from GitHub Container Registry
echo "Downloading container images..."

containers=(
  bowtie2
  fastp
  star
  seqkit
  samtools
  featurecounts
  htseq
  picard
  trimgalore
)

for c in "${containers[@]}"; do
  echo "Pulling container: $c"
  apptainer pull "oras://ghcr.io/chipomanda/genegenie:$c"
done

echo "Setup complete. Place your reference genome files in the 'reference/' directory and run the pipeline."
