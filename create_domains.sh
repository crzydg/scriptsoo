#!/bin/bash

# Function to get daily fresh TLDs from the Internet
get_tlds() {
    # weed out the first line with the timestamp and xn-- TLDs
    curl -s https://data.iana.org/TLD/tlds-alpha-by-domain.txt | sed 1d | tr -d ' ' | tr '[:upper:]' '[:lower:]' | grep -v 'xn--'
}

# Get desired Domainname
echo "Please enter a domain name in ASCII:"
read domain_name

# Combine TLDs with the Domainname
combine_tlds() {
    local domain_name="$1"
    local tlds=$(get_tlds)
    for tld in $tlds; do
        echo "$domain_name.$tld"
    done
}

# Print out on StdOut
combine_tlds "$domain_name"

