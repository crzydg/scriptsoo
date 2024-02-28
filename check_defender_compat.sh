#!/bin/bash

# Define the servers to be checked
servers=("server1" "server2" "server3")

# Define compat script to use
defenderscript="https://raw.githubusercontent.com/microsoft/mdatp-xplat/master/linux/installation/mde_installer.sh"

# Define the proxy server and port
proxy_server="proxy.example.com"
proxy_port="8080"

# Loop through each server
for server in ${servers[@]}; do
# Check the compatibility of Microsoft Defender for Linux
    compatibility=$(ssh $server "bash -c 'curl -x $proxy_server:$proxy_port -s $defenderscript -m| sudo bash'")
    echo "Server $server: $compatibility"
done
