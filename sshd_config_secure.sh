#!/bin/bash

# Backup the original file
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# 1. Login only with ssh key
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config

# 2. Prohibit root login via ssh
echo "PermitRootLogin no" >> /etc/ssh/sshd_config

# 3. Write own /var/log/secure
echo "SyslogFacility AUTHPRIV" >> /etc/ssh/sshd_config
echo "LogLevel VERBOSE" >> /etc/ssh/sshd_config
echo "LogFormat %h %l %u %t \"%r\" %s %b" >> /etc/ssh/sshd_config
echo "SyslogFacility AUTH" >> /etc/ssh/sshd_config
echo "AuthorizedKeysFile .ssh/authorized_keys" >> /etc/ssh/sshd_config

# 4. Set log to be verbose, so that ssh fingerprints will be logged
echo "LogLevel VERBOSE" >> /etc/ssh/sshd_config

# 5. Determine main IP address and bind port 22 to only listen to this interface
main_ip=$(hostname -I | awk '{print $1}')
echo "ListenAddress $main_ip" >> /etc/ssh/sshd_config
echo "Port 22" >> /etc/ssh/sshd_config

# Best practices
echo "PermitEmptyPasswords no" >> /etc/ssh/sshd_config
echo "UsePAM no" >> /etc/ssh/sshd_config
echo "AllowAgentForwarding no" >> /etc/ssh/sshd_config
echo "X11Forwarding no" >> /etc/ssh/sshd_config
echo "MaxAuthTries 3" >> /etc/ssh/sshd_config
echo "ClientAliveInterval 600" >> /etc/ssh/sshd_config
echo "ClientAliveCountMax 0" >> /etc/ssh/sshd_config
echo "Protocol 2" >> /etc/ssh/sshd_config
echo "Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr" >> /etc/ssh/sshd_config
echo "MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com" >> /etc/ssh/sshd_config

# Custom SSH banner
echo "Banner /etc/issue.net" >> /etc/ssh/sshd_config
echo "Unauthorized access is prohibited. System is monitored at all times." > /etc/issue.net

# Restart ssh service
service ssh restart

