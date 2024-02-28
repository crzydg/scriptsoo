#!/bin/bash

# Step 1: Download the RedHat ISO Images
wget -P /var/ftp/pub/redhat/ https://example.com/rhel-8-x86_64-dvd.iso

# Step 2: Create the directory structure
mkdir -p /var/ftp/pub/redhat/rhel8/

# Step 3: Use createrepo to generate the metadata
createrepo /var/ftp/pub/redhat/rhel8/

# Step 4: Configure Apache to serve the repository
cat > /etc/apache2/sites-available/rhel8.conf << EOL
<VirtualHost *:80>
        ServerName rhel8.example.com
        DocumentRoot /var/ftp/pub/redhat/rhel8/

        <Directory /var/ftp/pub/redhat/rhel8/>
                Options Indexes FollowSymLinks MultiViews
                AllowOverride None
                Order allow,deny
                allow from all
        </Directory>
</VirtualHost>
EOL

a2ensite rhel8
systemctl reload apache2

# Step 5: Create the comps.xml file
cat > /var/ftp/pub/redhat/rhel8/comps.xml << EOL
<?xml version="1.0"?>
<comps>
  <group>
    <id>rhel8-server-group</id>
    <name>RHEL 8 Server Group</name>
    <description>This group contains packages for a basic RHEL 8 server installation.</description>
    <default>true</default>
    <uservisible>true</uservisible>
    <packagelist>
      <packagereq type="mandatory">httpd</packagereq>
      <packagereq type="mandatory">rsyslog</packagereq>
    </packagelist>
  </group>
</comps>
EOL

# Step 6 : configure client to use the repository
cat > /etc/apt/sources.list.d/rhel8.list << EOL
deb [trusted=yes] http://rhel8.example.com/ /
EOL

# Step 7: update package cache and start installing packages
apt-get update
apt-get install httpd


