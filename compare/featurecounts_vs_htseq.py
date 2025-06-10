import os
import csv

def parse_featurecounts_output(file_path):
    """Parse featureCounts output to extract metrics."""
    metrics = {"Tool": "featureCounts", "File": os.path.basename(file_path)}
    gene_counts = 0
    total_counts = 0
    with open(file_path) as f:
        for line in f:
            if line.startswith("# Program:"):
                metrics["Command"] = line.strip().split("Command:")[1].strip()
            elif not line.startswith("#") and not line.startswith("Geneid"):
                parts = line.strip().split("\t")
                if len(parts) > 6:
                    gene_counts += 1
                    total_counts += int(parts[-1])  # Use the last column for counts
    metrics["Number of Genes/Features Detected"] = gene_counts
    metrics["Reads Assigned to Features"] = total_counts
    return metrics

def parse_htseq_output(file_path):
    """Parse HTSeq-count output to extract metrics."""
    metrics = {"Tool": "HTSeq-count", "File": os.path.basename(file_path)}
    gene_counts = 0
    total_assigned = 0
    with open(file_path) as f:
        for line in f:
            if line.startswith("__"):
                if "__no_feature" in line:
                    metrics["Reads Not Assigned to Features"] = int(line.split("\t")[1].strip())
                elif "__ambiguous" in line:
                    metrics["Ambiguous Reads"] = int(line.split("\t")[1].strip())
                elif "__alignment_not_unique" in line:
                    metrics["Multi-Mapped Reads"] = int(line.split("\t")[1].strip())
            else:
                parts = line.strip().split("\t")
                if len(parts) == 2:
                    gene_counts += 1
                    total_assigned += int(parts[1])
    metrics["Number of Genes/Features Detected"] = gene_counts
    metrics["Reads Assigned to Features"] = total_assigned
    return metrics

def find_files_in_directory(directory, extension):
    """Find all files with a specific extension in a directory."""
    files = []
    for root, _, filenames in os.walk(directory):
        for filename in filenames:
            if filename.endswith(extension):
                files.append(os.path.join(root, filename))
    return files

def compare_tools(featurecounts_metrics, htseq_metrics, aligner):
    """Compare metrics between featureCounts and HTSeq-count for a specific aligner."""
    comparisons = []
    for fc_metric in featurecounts_metrics:
        for ht_metric in htseq_metrics:
            if fc_metric["File"].split(".")[0] == ht_metric["File"].split(".")[0]:  # Assuming file names start with sample ID
                comparison = {
                    "Sample": fc_metric["File"].split(".")[0],
                    "Aligner": aligner,
                    "featureCounts_Genes": fc_metric["Number of Genes/Features Detected"],
                    "HTSeq_Genes": ht_metric["Number of Genes/Features Detected"],
                    "featureCounts_Assigned": fc_metric["Reads Assigned to Features"],
                    "HTSeq_Assigned": ht_metric["Reads Assigned to Features"],
                    "HTSeq_MultiMapped": ht_metric.get("Multi-Mapped Reads", "N/A"),
                    "HTSeq_Unassigned": ht_metric.get("Reads Not Assigned to Features", "N/A"),
                    "HTSeq_Ambiguous": ht_metric.get("Ambiguous Reads", "N/A"),
                }
                comparisons.append(comparison)
    return comparisons

def write_comparisons_to_csv(comparisons, output_csv):
    """Write comparison results to a CSV file."""
    with open(output_csv, mode='w', newline='') as csvfile:
        fieldnames = [
            "Sample", "Aligner", "featureCounts_Genes", "HTSeq_Genes", 
            "featureCounts_Assigned", "HTSeq_Assigned",
            "HTSeq_MultiMapped", "HTSeq_Unassigned", "HTSeq_Ambiguous"
        ]
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(comparisons)

if __name__ == "__main__":
    # Directories for featureCounts and HTSeq-count outputs
    featurecounts_star_dir = "/home/cmanda/containerised_workflow/mtb_ncbi_FSF/featurecounts"
    featurecounts_bowtie2_dir = "/home/cmanda/containerised_workflow/mtb_ncbi_TBF/featurecounts"
    htseq_star_dir = "/home/cmanda/containerised_workflow/mtb_ncbi_TSH/htseq"
    htseq_bowtie2_dir = "/home/cmanda/containerised_workflow/mtb_ncbi_TBH/htseq"
    output_csv = "/home/cmanda/containerised_workflow/compare/featurecounts_vs_htseq_comparison.csv"
    
    # Find all relevant files
    featurecounts_star_files = find_files_in_directory(featurecounts_star_dir, ".txt")
    featurecounts_bowtie2_files = find_files_in_directory(featurecounts_bowtie2_dir, ".txt")
    htseq_star_files = find_files_in_directory(htseq_star_dir, ".txt")
    htseq_bowtie2_files = find_files_in_directory(htseq_bowtie2_dir, ".txt")
    
    # Parse metrics for all files
    featurecounts_star_metrics = [parse_featurecounts_output(f) for f in featurecounts_star_files]
    featurecounts_bowtie2_metrics = [parse_featurecounts_output(f) for f in featurecounts_bowtie2_files]
    htseq_star_metrics = [parse_htseq_output(f) for f in htseq_star_files]
    htseq_bowtie2_metrics = [parse_htseq_output(f) for f in htseq_bowtie2_files]
    
    # Compare tools and write results
    comparisons = []
    comparisons.extend(compare_tools(featurecounts_star_metrics, htseq_star_metrics, "STAR"))
    comparisons.extend(compare_tools(featurecounts_bowtie2_metrics, htseq_bowtie2_metrics, "Bowtie2"))
    write_comparisons_to_csv(comparisons, output_csv)
    print(f"Comparison results written to {output_csv}")