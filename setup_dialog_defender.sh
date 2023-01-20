#!/bin/bash
# Author: Gregor Bausch
# Company: Kesinlik Ltd.
# Date: 2023/01/17
# email: gregor@kesinlik.com

# Detect the Linux distribution
distribution=$(lsb_release -is)

# Install dependencies
if [ "$distribution" == "Ubuntu" ] || [ "$distribution" == "Debian" ]; then
    sudo apt-get update
    sudo apt-get install -y libssl1.1 libcurl4 dialog
elif [ "$distribution" == "RedHat" ] || [ "$distribution" == "CentOS" ] || [ "$distribution" == "Suse" ]; then
    sudo yum update
    sudo yum install -y openssl curl dialog
fi

# manual steps for registration and downloading the package
dialog --msgbox "Please follow these steps to register your device and download the package: \n1. Go to https://aka.ms/linux-defender and sign in with your Microsoft account. \n2. Follow the instructions to register your device and download the package. \n3. Once you have downloaded the package, click OK to continue the installation." 10 60

# Ask user for package location
package_location=$(dialog --stdout --inputbox "Enter the location of the package:" 0 0)

# Install the package as root
if [ "$distribution" == "Ubuntu" ] || [ "$distribution" == "Debian" ]; then
    sudo dpkg -i $package_location
elif [ "$distribution" == "RedHat" ] || [ "$distribution" == "CentOS" ] || [ "$distribution" == "Suse" ]; then
    sudo yum install $package_location
fi

# Create a new user
sudo useradd defender

# Grant the new user minimum sudo permissions 
sudo usermod -aG wheel defender

# Run the defender agent as the new user
sudo -u defender defender-command --arguments

