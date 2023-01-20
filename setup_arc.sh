#!/bin/bash
# Author: Gregor Bausch
# Company: Kesinlik Ltd.
# Date: 2023/01/17
# email: gregor@kesinlik.com

# create a dedicated user account for the Azure Arc Agent
password=$(tr -dc A-Za-z0-9 < /dev/urandom | head -c 16)
useradd -c "ARC-Agent" -m -p $(openssl passwd -1 $password) arcagent
echo "$password" >> ~arcagent/pw.txt

# check for the distribution
if [ -f /etc/redhat-release ]; then
  # download the Azure Arc Agent package for RedHat
  wget -O azcmagent.rpm https://aka.ms/azcmagent
  # install the package using yum
  yum install azcmagent.rpm -y
elif [ -f /etc/debian_version ]; then
  # download the Azure Arc Agent package for Debian
  wget -O azcmagent.deb https://aka.ms/azcmagent
  # install the package using dpkg
  dpkg -i azcmagent.deb
elif [ -f /etc/lsb-release ]; then
  if grep -q "Ubuntu" /etc/lsb-release; then
    # download the Azure Arc Agent package for Ubuntu
    wget -O azcmagent.deb https://aka.ms/azcmagent
    # install the package using dpkg
    dpkg -i azcmagent.deb
  elif grep -q "SUSE" /etc/lsb-release; then
    # download the Azure Arc Agent package for SuSE
    wget -O azcmagent.rpm https://aka.ms/azcmagent
    # install the package using zypper
    zypper install azcmagent.rpm
  fi
elif [ -f /etc/centos-release ]; then
  # download the Azure Arc Agent package for CentOS
  wget -O azcmagent.rpm https://aka.ms/azcmagent
  # install the package using yum
  yum install azcmagent.rpm -y
else
  echo "Unsupported distribution"
  exit 1
fi

# configure the agent to run as the dedicated user
if [ -f /etc/redhat-release ] || [ -f /etc/centos-release ]; then
  sed -i "s/User=root/User=arcagent/" /usr/lib/systemd/system/azcmagent.service
else
  sed -i "s/User=root/User=arcagent/" /etc/systemd/system/azcmagent.service
fi

# reload the systemctl daemon
systemctl daemon-reload

# start the azcmagent service
systemctl start azcmagent

# enable the azcmagent service to start at boot
systemctl enable azcmagent

# grant arcagent user minimum sudo rights
cat <<EOF >> /etc/sudoers.d/arcagent
arcagent ALL=(ALL) NOPASSWD: /usr/sbin/azcmagent
arcagent ALL=(ALL) NOPASSWD: /usr/sbin/azcmagent-ctl
arcagent ALL=(ALL) NOPASSWD: /usr/sbin/azcmagent-config
arcagent ALL=(ALL) NOPASSWD: /usr/bin/az
arcagent ALL=(ALL) NOPASSWD: /usr/bin/apt-get
arcagent ALL=(ALL) NOPASSWD: /usr/bin/rpm
EOF

