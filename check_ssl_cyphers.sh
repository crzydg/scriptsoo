#!/bin/bash

# array of URLs to check
urls=("https://example1.com" "https://example2.com" "https://example3.com")

# check SSL/TLS cipher suites for each URL
for url in "${urls[@]}"
do
    echo "Checking SSL/TLS cipher suites for $url..."
    # check SSL/TLS cipher suites
    ciphers=$(echo | openssl s_client -connect $url:443 2>/dev/null | openssl ciphers -V 'ALL:eNULL' | awk '{print $1}')
    echo "The SSL/TLS cipher suites supported by $url are:"
    echo $ciphers
    echo
done

