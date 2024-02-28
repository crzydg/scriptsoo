#!/bin/bash
# Author: Gregor Bausch
# Company: Kesinlik Ltd.
# Date: 2023/01/18
# email: gregor@kesinlik.com

# based on the details from https://learn.microsoft.com/en-us/azure/azure-arc/servers/prerequisites#supported-operating-systems

# Check for supported Linux distribution
if [ -f /etc/redhat-release ]; then
    distro="RedHatEnterpriseServer"
elif [ -f /etc/SuSE-release ]; then
    distro="SLES"
elif [ -f /etc/lsb-release ]; then
    if grep -q "Ubuntu" /etc/lsb-release; then
        distro="Ubuntu"
    fi
elif [ -f /etc/centos-release ]; then
    distro="CentOS"
else
    echo "Error: Unsupported Linux distribution"
    exit 1
fi

# Check for supported kernel version
kernel=$(uname -r)
if [[ $distro == "RedHatEnterpriseServer" ]] || [[ $distro == "CentOS" ]]; then
    if [[ ${kernel:0:3} != "3.10" ]]; then
        echo "Error: Unsupported kernel version"
        exit 1
    fi
elif [[ $distro == "SLES" ]]; then
    if [[ ${kernel:0:3} != "3.12" ]]; then
        echo "Error: Unsupported kernel version"
        exit 1
    fi
elif [[ $distro == "Ubuntu" ]]; then
    if [[ ${kernel:0:3} != "4.4" ]]; then
        echo "Error: Unsupported kernel version"
        exit 1
    fi
fi

# Check for supported architecture
arch=$(uname -m)
if [[ $arch != "x86_64" ]]; then
    echo "Error: Unsupported architecture"
    exit 1
fi

# Check for systemd
if ! command -v systemctl > /dev/null; then
    echo "Error: systemd not found"
    exit 1
fi

# Check for wget
if ! command -v wget > /dev/null; then
    echo "Error: wget not found"
    exit 1
fi

# Check for openssl
if ! command -v openssl > /dev/null; then
    echo "Error: openssl not found"
    exit 1
fi

# Check for gnupg
if ! command -v gnupg > /dev/null; then
    echo "Error: gnupg not found"
    exit 1
fi

# All checks passed
echo "Host meets the requirements for installing Microsoft Defender for Endpoint"

