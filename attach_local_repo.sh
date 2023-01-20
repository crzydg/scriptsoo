#!/bin/bash

# Step 1: Download the RedHat ISO Images
wget -P /var/www/html/ http://example.com/rhel-8-x86_64-dvd.iso

# Step 2: Mount the ISO Image
mkdir /mnt/rhel8
mount -o loop /var/www/html/rhel-8-x86_64-dvd.iso /mnt/rhel8

# Step 3: Copy the RPM packages to the repository directory
mkdir /var/www/html/rhel8
cp -a /mnt/rhel8/Packages/* /var/www/html/rhel8/

# Step 4: Install and configure repoview
apt-get install repoview
repoview /var/www/html/rhel8/

# Step 5: Create the yum repository configuration file
cat > /etc/yum.repos.d/rhel8.repo << EOL
[rhel8]
name=RHEL 8
baseurl=http://example.com/rhel8
enabled=1
gpgcheck=0
EOL


