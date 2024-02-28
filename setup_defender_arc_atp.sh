#!/bin/bash

echo "This script installs Microsoft Defender ATP on Linux, detects the Linux distribution, installs the ATP agent, registers the device with ATP, installs the Defender agent and finally registers the agent with Microsoft"

# Detect the Linux distribution
distribution=$(lsb_release -is)

# Install the Microsoft ATP Agent
if [ "$distribution" == "Ubuntu" ] || [ "$distribution" == "Debian" ]; then
    wget https://aka.ms/linux-atp-agent -O atp-agent.deb
    sudo dpkg -i atp-agent.deb
elif [ "$distribution" == "RedHat" ] || [ "$distribution" == "CentOS" ] || [ "$distribution" == "Suse" ]; then
    wget https://aka.ms/linux-atp-agent -O atp-agent.rpm
    sudo yum install atp-agent.rpm
fi

# Register the device with ATP
sudo -u arcagent atp-register

# Install Microsoft Defender as an agent
if [ "$distribution" == "Ubuntu" ] || [ "$distribution" == "Debian" ]; then
    sudo apt-get update
    sudo apt-get install -y libssl1.1 libcurl4
elif [ "$distribution" == "RedHat" ] || [ "$distribution" == "CentOS" ] || [ "$distribution" == "Suse" ]; then
    sudo yum update
    sudo yum install -y openssl curl
fi
sudo -u arcagent atp-install-agent

# Register the Defender agent with Microsoft
sudo -u arcagent atp-register-agent

