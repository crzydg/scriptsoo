#!/bin/bash

# Check if the access.log file exists
if [ ! -f /var/log/squid/access.log ]; then
    echo "Squid access.log file not found at /var/log/squid/access.log"
    echo "Please make sure the file exists and the path is correct."
    exit 1
fi

# Generate a report of the top 100 accessed URLs with the client IP and user-agent
echo "Top 100 Accessed URLs with Client IP and User-Agent:"
awk '{print $3, $7, $12}' /var/log/squid/access.log | sort | uniq -c | sort -nr | head -n 100
echo ""

# Generate a report of the top 100 requestors
echo "Top 100 Requestors:"
awk '{print $3}' /var/log/squid/access.log | sort | uniq -c | sort -nr | head -n 100
echo ""

# Generate a report of the top 100 accessed websites
echo "Top 100 Accessed Websites:"
awk -F/ '{print $1"//"$3}' /var/log/squid/access.log | sort | uniq -c | sort -nr | head -n 100


