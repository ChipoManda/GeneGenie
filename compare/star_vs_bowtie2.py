import os
import csv

def parse_star_log(log_file):
    """Parse metrics from STAR Log.final.out file."""
    metrics = {"Tool": "STAR", "File": os.path.basename(log_file)}
    with open(log_file) as f:
        for line in f:
            if "Uniquely mapped reads number" in line:
                metrics["Uniquely Mapped Reads"] = int(line.split("|")[1].strip())
            if "Number of reads mapped to multiple loci" in line:
                metrics["Multi-Mapped Reads"] = int(line.split("|")[1].strip())
            if "Uniquely mapped reads %" in line:
                metrics["Overall Alignment Rate (%)"] = float(line.split("|")[1].strip().replace("%", ""))
            if "Number of discordant pairs" in line:
                metrics["Discordant Pairs"] = "N/A"  # STAR logs do not include discordant pairs directly
    return metrics

def parse_bowtie2_log(log_file):
    """Parse metrics from Bowtie2 alignment summary."""
    metrics = {"Tool": "Bowtie2", "File": os.path.basename(log_file)}
    with open(log_file) as f:
        for line in f:
            if "aligned exactly 1 time" in line:
                metrics["Uniquely Mapped Reads"] = int(line.split()[0])
            if "aligned >1 times" in line:
                metrics["Multi-Mapped Reads"] = int(line.split()[0])
            if "overall alignment rate" in line:
                metrics["Overall Alignment Rate (%)"] = float(line.split()[0].replace("%", ""))
            if "pairs aligned discordantly" in line:
                metrics["Discordant Pairs"] = "N/A"  # Bowtie2 logs do not include discordant pairs for single-end reads
    return metrics

def find_files_in_directory(directory, filename_pattern):
    """Find all files in a directory matching a specific pattern."""
    files = []
    for root, _, filenames in os.walk(directory):
        for filename in filenames:
            if filename_pattern in filename:
                files.append(os.path.join(root, filename))
    return files

def write_metrics_to_csv(metrics_list, output_csv):
    """Write extracted metrics to a CSV file."""
    with open(output_csv, mode='w', newline='') as csvfile:
        fieldnames = ["Tool", "File", "Uniquely Mapped Reads", "Multi-Mapped Reads", "Overall Alignment Rate (%)", "Discordant Pairs"]
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(metrics_list)

if __name__ == "__main__":
    # Directories containing STAR and Bowtie2 log files
    star_dir = "/home/cmanda/containerised_workflow/mtb_ncbi_FSH/star"
    bowtie2_dir = "/home/cmanda/containerised_workflow/mtb_ncbi_TBF/bowtie2"
    output_csv = "/home/cmanda/containerised_workflow/compare/star_vs_bowtie2.csv"
    
    # Find all relevant log files
    star_logs = find_files_in_directory(star_dir, "Log.final.out")
    bowtie2_logs = find_files_in_directory(bowtie2_dir, ".log")
    
    # Parse metrics for all files
    metrics_list = []
    for log_file in star_logs:
        metrics_list.append(parse_star_log(log_file))
    for log_file in bowtie2_logs:
        metrics_list.append(parse_bowtie2_log(log_file))
    
    # Write metrics to CSV
    write_metrics_to_csv(metrics_list, output_csv)
    print(f"Alignment metrics written to {output_csv}")

    
   
    
    




