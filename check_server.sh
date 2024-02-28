#!/bin/bash

# Get the list of remote machines
echo "Enter the list of remote machines (IP or hostname, separated by space):"
read -a remote_machines

# Loop through the remote machines
for remote_machine in "${remote_machines[@]}"; do
  echo "########## Analyzing $remote_machine ##########"
  
  # Linux distribution
  echo "Linux distribution:"
  ssh -t -q $remote_machine "sudo cat /etc/*-release"
  
  # Network configuration
  echo "Network configuration:"
  ssh -t -q $remote_machine "sudo ip addr show; sudo route -n"
  
  # Users
  echo "Users:"
  ssh -t -q $remote_machine "sudo cat /etc/passwd"
  
  # Running services and open ports
  echo "Running services and open ports:"
  ssh -t -q $remote_machine "sudo netstat -tulpen"
  
  # Uptime and last patched date
  echo "Uptime and last patched date:"
  ssh -t -q $remote_machine "sudo uptime; sudo ls -lct /var/log/yum.log | head -n 1"
  
  # Available updates
  echo "Available updates:"
  ssh -t -q $remote_machine "sudo sh -c 'if command -v yum &> /dev/null; then yum check-update; elif command -v apt-get &> /dev/null; then apt-get update && apt-get upgrade -s; fi'"
  
  # RHEL subscription status
  echo "RHEL subscription status:"
  ssh -t -q $remote_machine "sudo sh -c 'if command -v subscription-manager &> /dev/null; then subscription-manager status; fi'"
  
  # Local filesystem and possible mounts
  echo "Local filesystem and possible mounts:"
  ssh -t -q $remote_machine "sudo df -hT"
  
  # Apache vhosts and reverse proxys
  echo "Apache vhosts and reverse proxys:"
  ssh -t -q $remote_machine "sudo sh -c 'if command -v apachectl &> /dev/null; then apachectl -S; fi'"
  
  # SSL certificates
  echo "SSL certificates:"
  ssh -t -q $remote_machine "sudo sh -c 'if command -v openssl &> /dev/null; then for cert in $(find /etc/ssl/certs -name \"*.pem\"); do echo -e \"\$cert:\n\$(openssl x509 -noout -dates -in \$cert)\n\"; done; fi'"
  
  # Last access and open files
  echo "Last access and open files:"
  ssh -t -q $remote_machine "sudo sh -c 'echo \"Last accessed: \$(ls -ltu /var/log/secure*)\"; lsof -n'"
  echo ""
done

