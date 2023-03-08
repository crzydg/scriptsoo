#!/bin/bash

# Check that a filename was provided as an argument
if [ $# -lt 1 ]; then
  echo "Usage: $0 filename"
  exit 1
fi

# Read the list of URLs from the specified file
filename=$1
urls=$(cat ${filename})

# Define the header for the output CSV file
echo "URL;IP;HTTP_STATUS;REMARKS" > output.csv

# Loop through the list of URLs
for url in ${urls[@]}; do

  # Check the DNS entry of the URL against 1.1.1.1
  dns_result=$(dig +short @1.1.1.1 ${url})

  # If a DNS entry was found, sort the IPs and run the curl command
  if [ ! -z "${dns_result}" ]; then
    ip=$(echo ${dns_result} | awk '{print $1}')
    if [[ ${ip} == "194.240"* ]]; then
      ip_type="194.240"
    elif [[ ${ip} == "194.241"* ]]; then
      ip_type="194.241"
    else
      ip_type="other"
    fi
    http_code=$(curl -L -s -o /dev/null -w "%{http_code}" ${url} -H "Host: ${url}" --resolve ${url}:${ip} --connect-timeout 3 -m 3)
    remarks=$(case ${http_code} in
      200) echo "Connect";;
      301) echo "Moved Permanently";;
      302) echo "Moved Temporarily";;
      400) echo "Bad Request";;
      401) echo "Unauthorized";;
      403) echo "Forbidden";;
      404) echo "Not Found";;
      500) echo "Internal Server Error";;
      502) echo "Bad Gateway";;
      503) echo "Service Unavailable";;
      504) echo "Gateway Timeout";;
      *) echo "Unknown";;
    esac)
    echo "${url};${ip};${http_code};${remarks}" >> output.csv
  fi

done

