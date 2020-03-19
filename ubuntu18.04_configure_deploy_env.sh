#!/bin/bash

# Update packages list
if ! sudo apt update; then exit 1; fi

# Install
if ! sudo apt install-y apache2; then exit 1; fi

# Enable modules
if ! sudo a2enmod ssl; then exit 1; fi
if ! sudo a2enmod rewrite; then exit 1; fi

# Copy php.ini CLI configuration
phpinipath=$(php -r "echo php_ini_loaded_file();")
if ! sudo mv "${phpinipath}" /etc/php/7.3/apache2/php.ini; then exit 1; fi
if ! apache2 -v; then exit 1; fi

# Add Certbot official repositories
if ! sudo add-apt-repository universe; then exit 1; fi
if ! sudo add-apt-repository -y ppa:certbot/certbot; then exit 1; fi

# Install
if ! sudo apt install -y certbot; then exit 1; fi

# Add rules and activate firewall
if ! sudo ufw allow OpenSSH; then exit 1; fi
if ! sudo ufw allow in "Apache Full"; then exit 1; fi
if ! echo 'y' | sudo ufw enable; then exit 1; fi
