#!/bin/bash
# Author: Gregor Bausch
# Company: Kesinlik Ltd.
# Date: 2023/01/18
# email: gregor@kesinlik.com

# Read the /etc/*-release file
release_file=`cat /etc/*-release`

# Set the proxy variables based on the distribution
if echo "$release_file" | grep -q "Debian"; then
    # Debian
    proxy_line=$(apt-config dump | grep -o 'Acquire::http::Proxy.*;')
    proxy=$(echo "$proxy_line" | cut -d '"' -f 2)
    proxy_port=$(echo "$proxy_line" | grep -o '[0-9]\+' | head -1)
elif echo "$release_file" | grep -q "Ubuntu"; then
    # Ubuntu
    proxy_line=$(apt-config dump | grep -o 'Acquire::http::Proxy.*;')
    proxy=$(echo "$proxy_line" | cut -d '"' -f 2)
    proxy_port=$(echo "$proxy_line" | grep -o '[0-9]\+' | head -1)
elif echo "$release_file" | grep -q "SUSE"; then
    # SuSE
    proxy_line=$(grep -o 'http_proxy=.*' /etc/sysconfig/proxy)
    proxy=$(echo "$proxy_line" | cut -d '=' -f 2 | cut -d ':' -f 1)
    proxy_port=$(echo "$proxy_line" | cut -d ':' -f 3)
elif echo "$release_file" | grep -q "Red Hat"; then
    # RedHat
    proxy_line=$(grep -o 'http_proxy=.*' /etc/rhsm/rhsm.conf)
    proxy=$(echo "$proxy_line" | cut -d '=' -f 2 | cut -d ':' -f 1)
    proxy_port=$(echo "$proxy_line" | cut -d ':' -f 2)
elif echo "$release_file" | grep -q "CentOS"; then
    # CentOS
    proxy_line=$(grep -o 'http_proxy=.*' /etc/rhsm/rhsm.conf)
    proxy=$(echo "$proxy_line" | cut -d '=' -f 2 | cut -d ':' -f 1)
    proxy_port=$(echo "$proxy_line" | cut -d ':' -f 2)
fi

# Export the proxy settings
if [ -n "$proxy" ]; then
    export http_proxy="$proxy:$proxy_port"
    export https_proxy="$proxy:$proxy_port"
    export ftp_proxy="$proxy:$proxy_port"
    echo "Proxy environment variables exported: $http_proxy"
else
    echo "No proxy settings found."
fi

