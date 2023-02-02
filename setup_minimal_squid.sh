#!/bin/bash

# Install Squid proxy server
sudo apt-get update
sudo apt-get install -y squid

# Backup the original squid.conf file
sudo cp /etc/squid/squid.conf /etc/squid/squid.conf.bak

# Create a new squid.conf file with no cache, no access log and allow from RFC1918 IPs
sudo cat << EOF > /etc/squid/squid.conf
http_port 3128
cache deny all
access_log none
acl localnet src 10.0.0.0/8
acl localnet src 172.16.0.0/12
acl localnet src 192.168.0.0/16
http_access allow localnet
EOF

# Restart the Squid proxy service
sudo systemctl restart squid

