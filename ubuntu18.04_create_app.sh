#!/bin/bash

# Get app name from parameter or ask user for it (copy and paste all stuffs between "if" and "fi" in your terminal)
if [[ -z "${appname}" ]]; then
    read -r -p "Enter the name of your app without hyphens (eg. myawesomeapp):" appname
fi

# Get app domain name from parameter or ask user for it (copy and paste all stuffs between "if" and "fi" in your terminal)
if [[ -z "${appdomain}" ]]; then
    read -r -p "Enter the domain name on which you want your app to be served (eg. example.com or test.example.com):" appdomain
fi

# Get app Git repository URL from parameter or ask user for it (copy and paste all stuffs from "if" to "fi" in your terminal)
if [[ -z "${apprepositoryurl}" ]]; then
    read -r -p "Enter the Git repository URL of your app:" apprepositoryurl
fi

# Clone app repository
sudo git clone "${apprepositoryurl}" "/var/www/${appname}" || exit 1

# Go inside the app directory
cd "/var/www/${appname}" || exit 1

# Generate a random password for the new mysql user
mysqlpassword=$(openssl rand -hex 15) || exit 1

# Create database and related user for the app and grant permissions (copy and paste all stuffs from "sudo mysql" to "EOF" in your terminal)
sudo mysql -e "
CREATE DATABASE ${appname};
CREATE USER ${appname}@localhost IDENTIFIED BY '${mysqlpassword}';
GRANT ALL ON ${appname}.* TO ${appname}@localhost;" || exit 1

# Create .env.local file
sudo cp ./.env ./.env.local || exit 1

# Set APP_ENV to "prod"
sudo sed -i '.tmp' -e 's/APP_ENV=dev/APP_ENV=prod/g' ./.env.local || exit 1
sudo rm  ./.env.local.tmp || exit 1

# Set mysql credentials
sudo sed -i '.tmp' -e "s,DATABASE_URL=mysql://db_user:db_password@127.0.0.1:3306/db_name,DATABASE_URL=mysql://${appname}:${mysqlpassword}@127.0.0.1:3306/${appname},g" ./.env.local || exit 1
sudo rm  ./.env.local.tmp || exit 1

# Set ownership to Apache
sudo chown -R www-data:www-data "/var/www/${appname}" || exit 1

# Set files permissions to 644
sudo find "/var/www/${appname}" -type f -exec chmod 644 {} \; || exit 1

# Set folders permissions to 755
sudo find "/var/www/${appname}" -type d -exec chmod 755 {} \; || exit 1

# Install PHP dependencies
composer install || exit 1

# Install JS dependencies
yarn install || exit 1

# Build assets
yarn build || exit 1

# Execute database migrations
php bin/console doctrine:migrations:diff
php bin/console doctrine:migrations:migrate -n

# Create an Apache conf file for the app (copy and paste all stuffs from "cat" to "EOF" in your terminal)
echo "
# Listen on port 80 (HTTP)
<VirtualHost ${appdomain}:80>
    # Set up server name
    ServerName ${appdomain}

    # Set up document root
    DocumentRoot /var/www/${appname}/public

    # Configure separate log files
    ErrorLog /var/log/apache2/${appname}.error.log
    CustomLog /var/log/apache2/${appname}.access.log combined
</VirtualHost>" | sudo tee "/etc/apache2/sites-available/${appname}.conf" > /dev/null || exit 1

# Activate Apache conf
sudo a2ensite "${appname}.conf" || exit 1

# Restart Apache to make changes available
sudo service apache2 restart || exit 1

# Get a new HTTPS certficate
sudo certbot certonly --webroot -w "/var/www/${appname}/public" -d "${appdomain}"

# Replace existing conf (copy and paste all stuffs from "cat" to last "EOF" in your terminal)
echo "
# Listen for the app domain on port 80 (HTTP)
<VirtualHost ${appdomain}:80>
    # All we need to do here is redirect to HTTPS
    RewriteEngine on
    RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]
</VirtualHost>

# Listen for the app domain on port 443 (HTTPS)
<VirtualHost ${appdomain}:443>
    # Set up server name
    ServerName ${appdomain}

    # Set up document root
    DocumentRoot /var/www/${appname}/public
    DirectoryIndex /index.php

    # Set up Symfony specific configuration
    <Directory /var/www/${appname}/public>
        AllowOverride None
        Order Allow,Deny
        Allow from All
        FallbackResource /index.php
    </Directory>
    <Directory /var/www/${appname}/public/bundles>
        FallbackResource disabled
    </Directory>

    # Configure separate log files
    ErrorLog /var/log/apache2/${appname}.error.log
    CustomLog /var/log/apache2/${appname}.access.log combined

    # Configure HTTPS
    SSLEngine on
    SSLCertificateFile /etc/letsencrypt/live/${appdomain}/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/${appdomain}/privkey.pem
</VirtualHost>" | sudo tee "/etc/apache2/sites-available/${appname}.conf" > /dev/null || exit 1

# Restart Apache to make changes available
sudo service apache2 restart | exit 1
