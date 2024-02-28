#!/bin/bash

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
if [ -z "$package_location" ]; then
    dialog --msgbox "No package location provided. Exiting." 0 0
    exit 1
elif [ ! -f "$package_location" ]; then
    dialog --msgbox "Invalid package location provided. Exiting." 0 0
    exit 1
fi

# Ask user for Microsoft Login
username=$(dialog --stdout --inputbox "Enter your Microsoft login:" 0 0)
if [ -z "$username" ]; then
    dialog --msgbox "No username provided. Exiting." 0 0
    exit 1
fi
password=$(dialog --stdout --passwordbox "Enter your Microsoft password:" 0 0)
if [ -z "$password" ]; then
    dialog --msgbox "No password provided. Exiting." 0 0
    exit 1
fi

# Install the package
if [ "$distribution" == "Ubuntu" ] || [ "$distribution" == "Debian" ]; then
    sudo dpkg -i $package_location
elif [ "$distribution" == "RedHat" ] || [ "$distribution" == "CentOS" ] || [ "$distribution" == "Suse" ]; then
    sudo yum install $package_location
fi

# Register the Defender agent with Microsoft
sudo defender-register --username $username --password $password

