#!/bin/bash

echo "Enter network range (e.g. 192.168.0.0/24):"
read network

nmap -sP $network | awk '/^Nmap/{ip=$NF}/Bcast/{print ip}' | while read ip; do
  mac=$(arp -a $ip | awk '{print $4}')
  echo "$ip: $mac"
done
