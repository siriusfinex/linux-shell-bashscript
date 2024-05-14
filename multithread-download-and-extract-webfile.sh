#!/bin/bash

# Define the download directory
download_dir="/node/archive/fantom/data"

# Enable error handling
set -e

# Function to calculate MD5 hash
calculate_md5() {
    md5sum "$1" | awk '{print $1}'
}

# Read each line from download_url.txt
while IFS= read -r url; do
    # Download the file using aria2c with 16 segments and 16 connections
    aria2c -s 16 -x 16 -d "$download_dir" "$url"

    # Get the filename from the URL
    filename=$(basename "$url")

    # Calculate MD5 hash of the downloaded file
    md5_value=$(calculate_md5 "${download_dir}/${filename}")

    # Append filename and MD5 hash to file_md5value.txt
    echo "$filename $md5_value" >> "${download_dir}/file_md5value.txt"

    # Extract the downloaded file using tar
    tar -xvf "${download_dir}/${filename}" -C "$download_dir"

    # Remove the downloaded archive
    rm "${download_dir}/${filename}"

done < "/node/archive/fantom/data/download_url.txt"
