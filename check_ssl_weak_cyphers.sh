#!/bin/bash

# array of URLs to check
urls=("https://example1.com" "https://example2.com" "https://example3.com")

# Best practices ciphers
best_practice_ciphers="TLS13-AES-256-GCM-SHA384:TLS13-CHACHA20-POLY1305-SHA256:TLS13-AES-128-GCM-SHA256:TLS13-AES-128-CCM-8-SHA256:TLS13-AES-128-CCM-SHA256"

# check SSL/TLS cipher suites for each URL
for url in "${urls[@]}"
do
    echo "Checking SSL/TLS cipher suites for $url..."
    # check SSL/TLS cipher suites
    ciphers=$(echo | openssl s_client -connect $url:443 2>/dev/null | openssl ciphers -V 'ALL:eNULL' | awk '{print $1}')
    echo "The SSL/TLS cipher suites supported by $url are:"
    echo $ciphers
    echo
    # compare to best practice ciphers
    if [[ $ciphers == *$best_practice_ciphers* ]]; then
        echo "The SSL/TLS cipher suites for $url are following best practices"
    else
        echo "WARNING: The SSL/TLS cipher suites for $url are not following best practices. We recommend disabling the weak ciphers."
    fi
done

