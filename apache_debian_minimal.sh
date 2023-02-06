#!/bin/bash

# Update the package list and install Apache
sudo apt-get update
sudo apt-get install apache2 -y

# Start Apache and enable it to start at boot
sudo systemctl start apache2
sudo systemctl enable apache2

# Set firewall rules to allow HTTP and HTTPS traffic
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Enable the firewall and check the status
sudo ufw enable
sudo ufw status

# Install and enable the Apache modules mod_security and mod_ssl
sudo apt-get install libapache2-mod-security2 -y
sudo a2enmod security2
sudo apt-get install libapache2-mod-ssl -y
sudo a2enmod ssl

# Configure SSL certificates
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt
sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

# Update the Apache configuration to use SSL and configure security measures
sudo echo "
<VirtualHost *:443>
  ServerAdmin webmaster@localhost
  DocumentRoot /var/www/html

  SSLEngine on
  SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
  SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key

  <Directory /var/www/html>
    AllowOverride None
    Require all granted
  </Directory>

  ServerSignature Off
  Header unset ETag
  FileETag None

  LimitRequestFields 50
  LimitRequestLine 8190
  LimitRequestBody 10240000
  LimitXMLRequestBody 1048576

  TraceEnable off

  <IfModule mod_security2.c>
    SecRuleEngine On
    SecRequestBodyAccess On
    SecResponseBodyAccess On
    SecUploadDir /tmp
    SecUploadKeepFiles Off
    SecRuleRemoveById 960015
    SecRuleRemoveById 960032
  </IfModule>

  ErrorLog ${APACHE_LOG_DIR}/error.log
  CustomLog ${APACHE_LOG_DIR}/access.log combined

  SSLCipherSuite ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256
  SSLProtocol all -SSLv2 -SSLv3
  SSLHonorCipherOrder on
  SSLCompression off
  SSLDHParam /etc/ssl/certs/dhparam.pem
</Virtual
" | sudo tee /etc/apache2/sites-available/default-ssl.conf
sudo a2ensite default-ssl.conf

# Restart Apache to apply the changes
sudo systemctl restart apache

