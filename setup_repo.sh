#!/bin/bash

# IP addresses to iterate over
IPs=(192.168.0.1 192.168.0.2)

# Loop over the IP addresses
for IP in "${IPs[@]}"; do

  # Check the Linux distribution
  DISTRO=$(ssh root@$IP 'cat /etc/*-release' | grep "ID=" | awk -F "=" '{print $2}')

  # Check the network
  if [[ $IP == 192* ]]; then
    NETWORK="backend"
  elif [[ $IP == 194* ]]; then
    NETWORK="DMZ"
  fi

  # Check if the distribution is RHEL
  if [[ $DISTRO == "rhel" ]]; then

    # Check the network and deploy custom yum repository
    if [[ $NETWORK == "backend" ]]; then
      ssh root@$IP 'echo "[customrepo]\nname=Custom Repository\nbaseurl=http://192.168.0.100/repo/rhel/$releasever/$basearch\ngpgcheck=0\nenabled=1" > /etc/yum.repos.d/customrepo.repo'
    elif [[ $NETWORK == "DMZ" ]]; then
      ssh root@$IP 'echo "[customrepo]\nname=Custom Repository\nbaseurl=http://172.28.0.100/repo/rhel/$releasever/$basearch\ngpgcheck=0\nenabled=1" > /etc/yum.repos.d/customrepo.repo'
    fi
  fi
done

