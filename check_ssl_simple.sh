#!/bin/bash

# array of URLs to check
urls=("https://example1.com" "https://example2.com" "https://example3.com")

# check SSL expiration date for each URL
for url in "${urls[@]}"
do
    echo "Checking SSL certificate for $url..."
    expiry_date=$(echo | openssl s_client -connect $url:443 2>/dev/null | openssl x509 -noout -dates | grep 'After' | cut -f 2- -d '=')
    expiry_timestamp=$(date -d "$expiry_date" +%s)
    current_timestamp=$(date +%s)
    # calculate the number of days until expiration
    days_until_expiry=$(( (expiry_timestamp - current_timestamp) / 86400 ))
    if [[ $days_until_expiry -le 30 ]]; then
        echo "WARNING: SSL certificate for $url will expire in $days_until_expiry days."
    else
        echo "SSL certificate for $url is valid for another $days_until_expiry days."
    fi
done
