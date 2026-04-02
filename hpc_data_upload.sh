#!/bin/bash

hpc_data_upload() {
    if [ "$#" -ne 2 ]; then
        echo "Usage: hpc_data_upload </path/to/local_file_or_folder> <user@hpc:/path/to/remote_destination>"
        return 1
    fi

    local LOCAL_SRC="$1"
    local REMOTE_DEST="$2"
    
    local REMOTE_HOST="${REMOTE_DEST%%:*}"
    local REMOTE_DIR="${REMOTE_DEST#*:}"

    echo "🚀 Starting smart HPC upload pipeline..."

    local OS_TYPE=$(uname -s)
    local CMD_HASH_GEN=()
    local CMD_RSYNC=()

    case "$OS_TYPE" in
        Darwin*)
            echo "🍎 System detected: macOS. Configuring caffeinate and shasum..."
            CMD_HASH_GEN=(shasum -a 256)
            CMD_RSYNC=(caffeinate -i rsync -avP)
            ;;
        Linux*)
            echo "🐧 System detected: Linux/WSL. Configuring sha256sum..."
            CMD_HASH_GEN=(sha256sum)
            CMD_RSYNC=(rsync -avP)
            ;;
        *)
            echo "❌ Operating System '$OS_TYPE' not supported."
            return 1
            ;;
    esac

    local ORIGINAL_DIR=$(pwd)
    
    echo "---------------------------------------------------"
    echo "Preparing the destination directory on the HPC..."
    # Ensure the remote destination folder exists before rsync
    ssh "$REMOTE_HOST" "mkdir -p '$REMOTE_DIR'"

    echo "---------------------------------------------------"
    echo "Analyzing the local target and calculating hashes in real-time..."
    
    # Check if the local target is a directory or a file
    local LOCAL_IS_DIR="NO"
    if [ -d "$LOCAL_SRC" ]; then
        LOCAL_IS_DIR="YES"
    elif [ ! -f "$LOCAL_SRC" ]; then
        echo "❌ Error: The local file or folder was not found."
        return 1
    fi

    local RSYNC_SRC=""

    if [ "$LOCAL_IS_DIR" = "YES" ]; then
        # It's a folder: calculate the content hash
        cd "$LOCAL_SRC" || return 1
        find . -type f ! -path '*/.*' ! -name "checksums_local.txt" -exec "${CMD_HASH_GEN[@]}" {} + > checksums_local.txt
        RSYNC_SRC="./"
    else
        # It's a single file: calculate the hash only for it
        cd "$(dirname "$LOCAL_SRC")" || return 1
        "${CMD_HASH_GEN[@]}" "$(basename "$LOCAL_SRC")" > checksums_local.txt
        RSYNC_SRC="$(basename "$LOCAL_SRC")"
    fi

    # Check if the checksum file was successfully generated
    if [ ! -s checksums_local.txt ]; then
        echo "❌ Error: Failed to generate local hashes or empty folder."
        rm -f checksums_local.txt
        cd "$ORIGINAL_DIR"
        return 1
    fi
    echo "✅ Local checksums mapped and saved."

    echo "---------------------------------------------------"
    echo "Starting secure transfer (rsync)..."

    if [ "$LOCAL_IS_DIR" = "YES" ]; then
        # Sends the folder content (checksums_local.txt is already inside and goes with it)
        "${CMD_RSYNC[@]}" "$RSYNC_SRC" "$REMOTE_DEST/"
    else
        # Sends the specific file and the checksum txt together
        "${CMD_RSYNC[@]}" "$RSYNC_SRC" checksums_local.txt "$REMOTE_DEST/"
    fi

    if [ $? -ne 0 ]; then
        echo "❌ Error or interruption during transfer."
        echo "Just run the command again to resume from where it left off."
        cd "$ORIGINAL_DIR"
        return 1
    fi
    echo "✅ Upload complete."

    echo "---------------------------------------------------"
    echo "Verifying data integrity remotely..."
    
    # The HPC reads the uploaded text file and checks if the transfer was perfect
    ssh "$REMOTE_HOST" "cd '$REMOTE_DIR' && sha256sum -c checksums_local.txt"

    if [ $? -eq 0 ]; then
        echo "---------------------------------------------------"
        echo "🎉 SUCCESS! Transfer cryptographically validated on the HPC."
    else
        echo "---------------------------------------------------"
        echo "⚠️ WARNING: Verification failed for one or more files. Check the log above."
    fi

    cd "$ORIGINAL_DIR"
}

hpc_data_upload "$@"
