#!/bin/bash

# Update packages list
sudo apt update
if [ ! $? = 0 ]; then
    exit 1
fi

# Install
sudo apt install apache2 -y
if [ ! $? = 0 ]; then
    exit 1
fi

# Enable modules
sudo a2enmod ssl
if [ ! $? = 0 ]; then
    exit 1
fi
sudo a2enmod rewrite
if [ ! $? = 0 ]; then
    exit 1
fi

# Copy php.ini CLI configuration
sudo mv $(php -r "echo php_ini_loaded_file();") /etc/php/7.3/apache2/php.ini
if [ ! $? = 0 ]; then
    exit 1
fi
apache2 -v
if [ ! $? = 0 ]; then
    exit 1
fi

# Add Certbot official repositories
sudo add-apt-repository universe
if [ ! $? = 0 ]; then
    exit 1
fi
sudo add-apt-repository ppa:certbot/certbot -y
if [ ! $? = 0 ]; then
    exit 1
fi

# Install
sudo apt install certbot -y
if [ ! $? = 0 ]; then
    exit 1
fi

# Add rules and activate firewall
sudo ufw allow OpenSSH
if [ ! $? = 0 ]; then
    exit 1
fi
sudo ufw allow in "Apache Full"
if [ ! $? = 0 ]; then
    exit 1
fi
echo 'y' | sudo ufw enable
if [ ! $? = 0 ]; then
    exit 1
fi
