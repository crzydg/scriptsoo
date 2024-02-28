#!/bin/bash

# Detect the Linux distribution
distribution=$(lsb_release -is)

# Install dependencies
if [ "$distribution" == "Ubuntu" ] || [ "$distribution" == "Debian" ]; then
    sudo apt-get update
    sudo apt-get install -y libssl1.1 libcurl4
elif [ "$distribution" == "RedHat" ] || [ "$distribution" == "CentOS" ] || [ "$distribution" == "Suse" ]; then
    sudo yum update
    sudo yum install -y openssl curl
fi

# Download the Microsoft Defender for Endpoint package
if [ "$distribution" == "Ubuntu" ] || [ "$distribution" == "Debian" ]; then
    wget https://aka.ms/linux-defender -O defender.deb
elif [ "$distribution" == "RedHat" ] || [ "$distribution" == "CentOS" ] || [ "$distribution" == "Suse" ]; then
    wget https://aka.ms/linux-defender -O defender.rpm
fi

# Install the package
if [ "$distribution" == "Ubuntu" ] || [ "$distribution" == "Debian" ]; then
    sudo dpkg -i defender.deb
elif [ "$distribution" == "RedHat" ] || [ "$distribution" == "CentOS" ] || [ "$distribution" == "Suse" ]; then
    sudo yum install defender.rpm
fi

