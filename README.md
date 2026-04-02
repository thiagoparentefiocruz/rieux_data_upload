# 🚀 HPC Data Upload

[![DOI](https://zenodo.org/badge/1187474279.svg)](https://doi.org/10.5281/zenodo.19139228)

**A Local-to-HPC data transfer pipeline with native cryptographic auditing.**

In bioinformatics and data science, transferring large volumes of data (e.g., NGS sequencing) from local workstations to High-Performance Computing (HPC) environments requires more than a simple copy command. It demands mathematical assurance that not a single byte was corrupted or lost during network transit.

`hpc_data_upload` is a smart Bash wrapper designed to scale across any Linux server. It orchestrates local hash calculation, resilient transfer, and remote server-side validation in a single command.

## ✨ Key Features

* 🧠 **Smart Target Resolution:** Automatically detects whether the local target is an isolated file or an entire directory, dynamically adjusting the hashing and copying strategy.
* 🔐 **Cryptographic Auditing:** The local machine calculates SHA-256 hashes of the files *before* transfer and forces the remote HPC server to audit these receipts immediately after receiving the data.
* 🛡️ **Resilient Transfer:** Uses `rsync` to allow resuming interrupted uploads without losing any progress.
* 🍎 **OS-Aware:** Automatically detects if the local machine runs macOS or Linux/WSL, adjusting cryptographic binaries (`shasum` vs `sha256sum`) and injecting power-management protections (like `caffeinate` on Mac to prevent sleep during lengthy NGS uploads).

## ⚙️ Prerequisites

* Configured SSH access (preferably with multiplexing/RSA keys) to the remote server. See our companion tool: `hpc_ssh_multiplexing`.
* Runs natively on **macOS** (zsh/bash) and **Linux/WSL** terminals.

## 🛠️ Installation

To install and use the tool as a native system command, simply clone the repository and run our automated installation script. 

You can download it anywhere on your machine (like the `Downloads` folder), as the installer will handle the rest. Open your terminal and run the commands below:

```bash
# 1. Clone the repository
git clone [https://github.com/thiagoparentefiocruz/hpc_data_upload.git](https://github.com/thiagoparentefiocruz/hpc_data_upload.git)

# 2. Enter the cloned directory
cd hpc_data_upload

# 3. Run the installer
bash install.sh
```

*(The `install.sh` script will securely copy the executable to `~/.local/bin` and automatically configure your `PATH` if necessary).*

**Cleanup (Optional):**
Since the installer makes a physical copy of the file, you can delete the downloaded folder right after installation to keep your computer organized:

```bash
cd ..
rm -rf hpc_data_upload
```

## 📖 Usage

The syntax follows the standard Unix copy pattern: `<Local_Source> <Remote_Destination>`. After installation, the tool is globally available in any terminal.

```bash
hpc_data_upload </path/to/local_file_or_folder> <user@server:/path/to/remote_destination>
```

**Practical Example:**
```bash
hpc_data_upload ~/MyExperiments/NGSSamples/ username@hpc.cluster.edu:/home/username/projects/ngs_run1/
```

## 🏗️ Architecture (Under the Hood)

When executed, the pipeline strictly follows 3 phases:

1. **Local Profiling & Hashing:** Identifies the nature of the local data (file or folder), runs an iterative `find`, and generates a `.txt` manifest file containing the original hashes.
2. **Syncing:** Prepares the destination directory on the server and opens an optimized Rsync tunnel. If the connection drops, simply run the exact same command line to resume from the failure point.
3. **Remote Audit:** Executes an SSH sub-shell on the target server that reads the newly uploaded manifest and verifies byte-by-byte that the received files perfectly match your local machine.
