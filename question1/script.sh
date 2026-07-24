#!/bin/bash

# ==========================================================
# Question 1: Duplicate Submission Detection and Backup
# ==========================================================

# Directory containing student submissions
SOURCE_DIR="submissions"

# Directory where unique files will be backed up
BACKUP_DIR="backup"

# Output files
REPORT_FILE="report.txt"
ERROR_FILE="errors.log"
HASH_FILE="hashes.tmp"

# Counters
processed=0
duplicates=0
backed_up=0

# Create backup directory if it does not exist
mkdir -p "$BACKUP_DIR" 2>> "$ERROR_FILE"

# Clear old report, error and temporary hash files
> "$REPORT_FILE"
> "$ERROR_FILE"
> "$HASH_FILE"

echo "Processing student submissions..."

# Check whether source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory '$SOURCE_DIR' does not exist." \
        >> "$ERROR_FILE"
    exit 1
fi

# Read all files from the submissions directory
while IFS= read -r -d '' file
do
    # Increase processed-file counter
    ((processed++))

    # Calculate SHA-256 checksum
    hash=$(sha256sum "$file" 2>> "$ERROR_FILE" | awk '{print $1}')

    # Skip the file if hashing failed
    if [ -z "$hash" ]; then
        continue
    fi

    # Check whether this hash has already been processed
    if grep -Fxq "$hash" "$HASH_FILE"; then
        echo "Duplicate found: $file"
        ((duplicates++))
    else
        # Store hash of unique file
        echo "$hash" >> "$HASH_FILE"

        # Copy unique file to backup directory
        if cp -p "$file" "$BACKUP_DIR/" 2>> "$ERROR_FILE"; then
            echo "Backed up: $file"
            ((backed_up++))
        fi
    fi

done < <(find "$SOURCE_DIR" -type f -print0 2>> "$ERROR_FILE")

# Generate final report
{
    echo "======================================"
    echo " Student Submission Processing Report"
    echo "======================================"
    echo "Files processed : $processed"
    echo "Duplicate files : $duplicates"
    echo "Files backed up  : $backed_up"
    echo "======================================"
} > "$REPORT_FILE"

# Remove temporary hash file
rm -f "$HASH_FILE" 2>> "$ERROR_FILE"

echo
echo "Processing completed."
echo "Report saved in: $REPORT_FILE"
echo "Errors saved in: $ERROR_FILE"
echo "Unique files backed up in: $BACKUP_DIR"
