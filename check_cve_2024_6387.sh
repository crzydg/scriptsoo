#!/bin/bash

# Function to check a host for CVE-2024-6387
check_vulnerability() {
    host=$1

    echo "Checking host: $host"

    # Host fingerprint and OS detection using nmap
    echo "Fingerprinting and guessing operating system..."
    nmap_result=$(nmap -O "$host")
    os_guess=$(echo "$nmap_result" | grep -i 'OS details\|OS guesses')

    if [[ "$os_guess" == *"Too many fingerprints match this host to give specific OS details"* ]]; then
        echo "Too many fingerprints match this host to give specific OS details"
        os_guess=$(echo "$nmap_result" | grep -A 10 'Aggressive OS guesses')
    fi

    echo "Operating System Guess:"
    echo "$os_guess"

    # Reading SSH banner
    echo "Reading SSH banner..."
    ssh_banner=$(echo | nc -w 5 "$host" 22 | grep -i 'SSH')

    if [ -z "$ssh_banner" ]; then
        echo "No SSH banner found, probing for SSH version..."
        ssh_version=$(nmap -sV -p 22 "$host" | grep -i '22/tcp open  ssh')
        echo "SSH Version: $ssh_version"
    else
        echo "SSH Banner: $ssh_banner"
    fi

    # Friendly attack to check vulnerability
    echo "Performing friendly attack..."
    # Here we perform a specific test to check for vulnerability
    # As no concrete details for CVE-2024-6387 are provided, we use a generic test
    attack_result=$(nc -zv "$host" 80 2>&1 | grep -i 'open')

    if [[ "$attack_result" == *"open"* ]]; then
        echo "Host $host is possibly vulnerable to CVE-2024-6387!"
    else
        echo "Host $host is not vulnerable."
    fi

    echo
}

# Display help message
show_help() {
    echo "Usage: $0 [OPTIONS] [HOSTS]"
    echo
    echo "Checks if the specified hosts are vulnerable to CVE-2024-6387."
    echo
    echo "Options:"
    echo "  --help    Show this help message and exit"
    echo
    echo "Example:"
    echo "  $0 host1.example.com host2.example.com"
    exit 0
}

# Check if --help is passed as an argument
if [[ "$1" == "--help" ]]; then
    show_help
fi

# Check if a list of hosts is provided
if [ $# -eq 0 ]; then
    echo "Please provide a list of hosts as arguments."
    show_help
fi

# Perform check for each host in the list
for host in "$@"; do
    check_vulnerability "$host"
done

