import re
import sys

def parse_seff_output(seff_output):
    # Extract relevant fields using regex
    def safe_search(pattern, text, default="N/A"):
        match = re.search(pattern, text)
        return match.group(1) if match else default

    job_id = safe_search(r"Job ID\s+:\s+(\S+)", seff_output)
    job_name = safe_search(r"Job name\s+:\s+(.+)", seff_output)
    status = safe_search(r"Status\s+:\s+(.+)", seff_output)
    running_node = safe_search(r"Running on node\s+:\s+(.+)", seff_output)
    user = safe_search(r"User\s+:\s+(.+)", seff_output)
    group = safe_search(r"Shareholder group\s+:\s+(.+)", seff_output)
    partition = safe_search(r"Slurm partition \(queue\)\s+:\s+(.+)", seff_output)
    command = safe_search(r"Command\s+:\s+(.+)", seff_output)
    wall_clock = safe_search(r"Wall-clock\s+:\s+(.+)", seff_output)
    cpu_time = safe_search(r"Total CPU time\s+:\s+(.+)", seff_output)
    cpu_utilization = safe_search(r"CPU utilization\s+:\s+(\d+\.\d+)%", seff_output, "0.0")
    memory_utilized = safe_search(r"Total resident memory\s+:\s+(\d+\.\d+) MiB", seff_output, "0.0")
    memory_utilization = safe_search(r"Resident memory utilization\s+:\s+(\d+\.\d+)%", seff_output, "0.0")

    try:
        memory_utilized_gb = float(memory_utilized) / 1024  # Convert MiB to GiB
    except ValueError:
        memory_utilized_gb = 0.0

    # Prepare table rows
    headers = [
        "Job_ID", "Job_Name", "Status", "Running_Node", "User", "Group",
        "Partition", "Wall_Clock", "CPU_Time", "CPU_Utilization", "Memory_Utilized_GB", "Memory_Utilization"
    ]
    values = [
        job_id, job_name, status, running_node, user, group,
        partition, wall_clock, cpu_time, cpu_utilization, f"{memory_utilized_gb:.2f}", memory_utilization
    ]

    # Generate table as tab-separated values
    table = "\t".join(headers) + "\n" + "\t".join(values)

    return table

def main():
    if len(sys.argv) != 2:
        print("Usage: python script.py <seff_output_file>")
        sys.exit(1)

    input_file = sys.argv[1]

    try:
        with open(input_file, "r") as file:
            seff_output = file.read()
    except FileNotFoundError:
        print(f"Error: File '{input_file}' not found.")
        sys.exit(1)

    table_output = parse_seff_output(seff_output)
    print(table_output)

if __name__ == "__main__":
    main()
