#!/bin/bash

# Get the list of remote machines
echo "you need to have root access to the machines. This script doesn't use sudo."
echo "Enter the list of remote machines (IP or hostname, separated by space):"
read -a remote_machines

# Loop through the remote machines
for remote_machine in "${remote_machines[@]}"; do
  echo "########## Analyzing $remote_machine ##########"
  
  # Linux distribution
  echo "Linux distribution:"
  ssh -q $remote_machine "cat /etc/*-release"
  
  # Network configuration
  echo "Network configuration:"
  ssh -q $remote_machine "ip addr show; route -n"
  
  # Users
  echo "Users:"
  ssh -q $remote_machine "cat /etc/passwd"
  
  # Running services and open ports
  echo "Running services and open ports:"
  ssh -q $remote_machine "netstat -tulpen"
  
  # Uptime and last patched date
  echo "Uptime and last patched date:"
  ssh -q $remote_machine "uptime; ls -lct /var/log/yum.log | head -n 1"
  
  # Available updates
  echo "Available updates:"
  ssh -q $remote_machine "if command -v yum &> /dev/null; then yum check-update; elif command -v apt-get &> /dev/null; then apt-get update && apt-get upgrade -s; fi"
  
  # RHEL subscription status
  echo "RHEL subscription status:"
  ssh -q $remote_machine "if command -v subscription-manager &> /dev/null; then subscription-manager status; fi"
  
  # Local filesystem and possible mounts
  echo "Local filesystem and possible mounts:"
  ssh -q $remote_machine "df -hT"
  
  # Apache vhosts and reverse proxys
  echo "Apache vhosts and reverse proxys:"
  ssh -q $remote_machine "if command -v apachectl &> /dev/null; then apachectl -S; fi"
  
  # SSL certificates
  echo "SSL certificates:"
  ssh -q $remote_machine "if command -v openssl &> /dev/null; then for cert in $(find /etc/ssl/certs -name \"*.pem\"); do echo -e \"\$cert:\n\$(openssl x509 -noout -dates -in \$cert)\n\"; done; fi"
  
  # Last access and open files
  echo "Last access and open files:"
  ssh -q $remote_machine "echo \"Last accessed: \$(ls -ltu /var/log/secure*)\"; lsof -n"
  echo ""
done

