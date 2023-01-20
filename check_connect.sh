#!/bin/bash
# Author: Gregor Bausch
# Company: Kesinlik Ltd.
# Date: 2023/01/18
# email: gregor@kesinlik.com

# Check for curl or wget
if command -v curl &> /dev/null; then
    check_tool='curl -s --head'
elif command -v wget &> /dev/null; then
    check_tool='wget -q -O - --server-response'
else
    echo "Neither curl nor wget is installed."
    exit 1
fi

# Check connectivity using the selected tool
response=$($check_tool https://1.1.1.1)

# Check the response for a successful connection
if echo "$response" | grep -q "200 OK"; then
    echo "Connected to the internet."
else
    echo "Not connected to the internet."
fi

