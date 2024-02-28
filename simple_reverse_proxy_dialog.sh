#!/bin/bash

echo "Enter the DNS name (source):"
read source_dns

echo "Enter the destination DNS name or IP address:"
read destination

# enable the reverse proxy and SSL modules in Apache
sudo a2enmod proxy proxy_http ssl

# create a virtual host configuration file
sudo bash -c "cat > /etc/apache2/sites-available/$source_dns.conf << EOL
<VirtualHost *:80>
        ServerName $source_dns
        Redirect / https://$source_dns/
</VirtualHost>

<VirtualHost *:443>
        ServerName $source_dns

        SSLEngine on
        SSLCertificateFile /etc/ssl-certs/$source_dns.crt
        SSLCertificateKeyFile /etc/ssl-certs/$source_dns.key

        SSLProtocol all -SSLv2 -SSLv3
        SSLCipherSuite ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384

        ProxyPreserveHost On
        ProxyPass / http://$destination/
        ProxyPassReverse / http://$destination/
</VirtualHost>
EOL"

# enable the virtual host and restart Apache
sudo a2ensite $source_dns.conf
sudo systemctl restart apache2
