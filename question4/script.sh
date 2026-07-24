#!/bin/bash

LOG_FILE="/var/log/app.log"
REPORT_FILE="error_report.txt"

echo "Monitoring $LOG_FILE for ERROR messages..."
echo "Report saved to $REPORT_FILE"

# Monitor with pipeline
tail -f "$LOG_FILE" 2>/dev/null | \
while read line; do
    if echo "$line" | grep -q "ERROR"; then
        echo "$(date): $line" | tee -a "$REPORT_FILE"
    fi
done
