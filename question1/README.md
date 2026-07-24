Justification of commands and techniques

find "$SOURCE_DIR" -type f recursively identifies regular submission files. The -print0 option and read -d '' technique safely handle filenames containing spaces and other unusual characters.

sha256sum calculates a SHA-256 checksum for every submission. Files with identical content normally produce the same SHA-256 digest, allowing content-based duplicate detection even when filenames differ.

grep -Fxq searches the temporary hash list. -F treats the checksum as literal text, -x requires the complete line to match, and -q suppresses normal output because only the command's success/failure status is required.

cp -p copies each unique submission into the backup directory while preserving basic file metadata such as modification time and permissions.

mkdir -p creates the backup directory if necessary. The -p option prevents an error if the directory already exists.

The redirection operator > creates or overwrites a file. For example:

> "$REPORT_FILE"

clears the previous report, while:

} > "$REPORT_FILE"

writes the newly generated report.

The >> operator appends data without deleting existing contents. It is used to store hashes and accumulate errors.

The 2>> operator redirects standard error (file descriptor 2) and appends errors to errors.log:

2>> "$ERROR_FILE"

This separates diagnostic/error messages from normal terminal output and the final report.

The temporary hashes.tmp file records hashes that have already been encountered. It is deleted with rm -f after processing because it is only needed while the script runs.

The counters processed, duplicates, and backed_up track the three statistics required by the assignment. They are finally written to report.txt.
