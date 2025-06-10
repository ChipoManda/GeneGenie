import os
import json
import csv

def parse_fastp(fastp_file):
    """Parse metrics from fastp JSON file."""
    with open(fastp_file) as f:
        data = json.load(f)
    
    metrics = {
        "Tool": "fastp",
        "File": os.path.basename(fastp_file),
        "Total Reads Processed": data["summary"]["before_filtering"]["total_reads"],
        "Reads Remaining": data["summary"]["after_filtering"]["total_reads"],
        "Percentage of Bases Trimmed": round(
            (data["summary"]["before_filtering"]["total_bases"] - data["summary"]["after_filtering"]["total_bases"])
            / data["summary"]["before_filtering"]["total_bases"] * 100, 2
        ),
        "Adapter Content": data["filtering_result"]["passed_filter_reads"],
        "Reads Discarded (Low Quality)": data["filtering_result"]["low_quality_reads"],
        "Mean Quality Score (After Trimming)": round(data["summary"]["after_filtering"]["q30_rate"] * 100, 2),  # proxy using Q30 rate
        "Runtime (s)": None,
        "Resource Usage (CPU, Memory)": None,
    }
    return metrics

def parse_fastqc_quality_score(fastqc_file):
    """Extract mean quality score from FastQC report."""
    with open(fastqc_file) as f:
        lines = f.readlines()
    for i, line in enumerate(lines):
        if line.startswith(">>Per base sequence quality"):
            # Start parsing values from this section
            start = i + 1
            while not lines[start].startswith("#Base"):
                start += 1
            start += 1  # Skip header
            scores = []
            for l in lines[start:]:
                if l.startswith(">>END_MODULE"):
                    break
                parts = l.strip().split()
                if len(parts) >= 2:
                    try:
                        score = float(parts[1])
                        scores.append(score)
                    except:
                        continue
            return round(sum(scores) / len(scores), 2) if scores else None
    return None

def parse_trimgalore(trimgalore_file):
    """Parse metrics from Trim Galore trimming report."""
    metrics = {}
    with open(trimgalore_file) as f:
        lines = f.readlines()
    
    for line in lines:
        if "Total reads processed:" in line:
            metrics["Total Reads Processed"] = int(line.split(":")[1].strip().replace(",", ""))
        elif "Reads written (passing filters):" in line:
            metrics["Reads Remaining"] = int(line.split(":")[1].strip().split(" ")[0].replace(",", ""))
        elif "Quality-trimmed:" in line:
            metrics["Percentage of Bases Trimmed"] = float(line.split(":")[1].strip().split(" ")[0].replace(",", ""))
        elif "Reads with adapters:" in line:
            metrics["Adapter Content"] = int(line.split(":")[1].strip().split(" ")[0].replace(",", ""))
        elif "Sequences removed because they became shorter than the length cutoff" in line:
            metrics["Reads Discarded (Low Quality)"] = int(line.split(":")[1].strip().split(" ")[0].replace(",", ""))
        elif "Finished in" in line:
            try:
                metrics["Runtime (s)"] = float(line.split("Finished in")[1].split("s")[0].strip())
            except:
                metrics["Runtime (s)"] = None

    metrics["Tool"] = "Trim Galore"
    metrics["File"] = os.path.basename(trimgalore_file)

    # Try to locate associated FastQC report for quality score
    base = os.path.basename(trimgalore_file).replace("_trimming_report.txt", "")
    fastqc_file = os.path.join(os.path.dirname(trimgalore_file), f"{base}_fastqc", "fastqc_data.txt")
    if os.path.exists(fastqc_file):
        metrics["Mean Quality Score (After Trimming)"] = parse_fastqc_quality_score(fastqc_file)
    else:
        metrics["Mean Quality Score (After Trimming)"] = None

    metrics["Resource Usage (CPU, Memory)"] = None
    return metrics

def find_files_in_directory(directory, extension):
    """Find all files with a specific extension in a directory."""
    files = []
    for root, _, filenames in os.walk(directory):
        for filename in filenames:
            if filename.endswith(extension):
                files.append(os.path.join(root, filename))
    return files

def write_comparison_to_csv(metrics_list, output_file):
    """Write comparison metrics to a CSV file."""
    if not metrics_list:
        print("No metrics to write.")
        return
    with open(output_file, mode='w', newline='') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=metrics_list[0].keys())
        writer.writeheader()
        writer.writerows(metrics_list)

if __name__ == "__main__":
    # Directories containing fastp.json and trimming reports
    fastp_dir = "/home/cmanda/containerised_workflow/mtb_ncbi_FSF/fastp"
    trimgalore_dir = "/home/cmanda/containerised_workflow/mtb_ncbi_TBF/trimgalore"
    output_csv = "/home/cmanda/containerised_workflow/compare/trimg_vs_fastp.csv"
    
    # Find all relevant files
    fastp_files = find_files_in_directory(fastp_dir, ".json")
    trimgalore_files = find_files_in_directory(trimgalore_dir, "_trimming_report.txt")
    
    # Parse metrics for all files
    metrics_list = []
    for fastp_file in fastp_files:
        metrics_list.append(parse_fastp(fastp_file))
    for trimgalore_file in trimgalore_files:
        metrics_list.append(parse_trimgalore(trimgalore_file))
    
    # Write to CSV
    write_comparison_to_csv(metrics_list, output_csv)
    print(f"Comparison metrics written to {output_csv}")
