#!/bin/bash

# Get app name from parameter or ask user for it (copy and paste all stuffs between "if" and "fi" in your terminal)
if [[ -z ${1} ]] && [[ -z "${appname}" ]]; then
    read -p "Enter the name of your app without hyphens (eg. myawesomeapp):" appname
else
    appname=${1:-${appname}}
fi

# Get app domain name from parameter or ask user for it (copy and paste all stuffs between "if" and "fi" in your terminal)
if [[ -z ${2} ]] && [[ -z "${appdomain}" ]]; then
    read -p "Enter the domain name on which you want your app to be served (eg. example.com or test.example.com):" appdomain
else
    appdomain=${2:-${appdomain}}
fi

# Get app Git repository URL from parameter or ask user for it (copy and paste all stuffs from "if" to "fi" in your terminal)
if [[ -z ${3} ]] && [[ -z "${apprepositoryurl}" ]]; then
    read -p "Enter the Git repository URL of your app:" apprepositoryurl
else
    apprepositoryurl=${3:-${apprepositoryurl}}
fi

# Clone app repository
git clone ${apprepositoryurl} /var/www/${appname}
if [ ! $? = 0 ]; then
    exit 1
fi

# Go inside the app directory
cd /var/www/${appname}
if [ ! $? = 0 ]; then
    exit 1
fi

# Generate a random password for the new mysql user
mysqlpassword=$(openssl rand -hex 15)
if [ ! $? = 0 ]; then
    exit 1
fi

# Create database and related user for the app and grant permissions (copy and paste all stuffs from "sudo mysql" to "EOF" in your terminal)
sudo mysql <<EOF
CREATE DATABASE ${appname};
CREATE USER ${appname}@localhost IDENTIFIED BY '${mysqlpassword}';
GRANT ALL ON ${appname}.* TO ${appname}@localhost;
EOF
if [ ! $? = 0 ]; then
    exit 1
fi

# Create .env.local file
cp ./.env ./.env.local
if [ ! $? = 0 ]; then
    exit 1
fi

# Set APP_ENV to "prod"
sed -e 's/APP_ENV=dev/APP_ENV=prod/g' ./.env.local > ./.env.local.tmp
if [ ! $? = 0 ]; then
    exit 1
fi
mv ./.env.local.tmp ./.env.local
if [ ! $? = 0 ]; then
    exit 1
fi

# Set mysql credentials
sed -e 's,DATABASE_URL=mysql://db_user:db_password@127.0.0.1:3306/db_name,DATABASE_URL=mysql://'${appname}':'${mysqlpassword}'@127.0.0.1:3306/'${appname}',g' ./.env.local > ./.env.local.tmp
if [ ! $? = 0 ]; then
    exit 1
fi
mv ./.env.local.tmp ./.env.local
if [ ! $? = 0 ]; then
    exit 1
fi

# Set ownership to Apache
sudo chown -R www-data:www-data /var/www/${appname}
if [ ! $? = 0 ]; then
    exit 1
fi

# Set files permissions to 644
sudo find /var/www/${appname} -type f -exec chmod 644 {} \;
if [ ! $? = 0 ]; then
    exit 1
fi

# Set folders permissions to 755
sudo find /var/www/${appname} -type d -exec chmod 755 {} \;
if [ ! $? = 0 ]; then
    exit 1
fi

# Install PHP dependencies
composer install
if [ ! $? = 0 ]; then
    exit 1
fi

# Install JS dependencies
yarn install
if [ ! $? = 0 ]; then
    exit 1
fi

# Build assets
yarn build
if [ ! $? = 0 ]; then
    exit 1
fi

# Execute database migrations
php bin/console doctrine:migrations:diff
php bin/console doctrine:migrations:migrate -n

# Create an Apache conf file for the app (copy and paste all stuffs from "cat" to "EOF" in your terminal)
cat > /etc/apache2/sites-available/${appname}.conf <<EOF
# Listen on port 80 (HTTP)
<VirtualHost ${appdomain}:80>
    # Set up server name
    ServerName ${appdomain}

    # Set up document root
    DocumentRoot /var/www/${appname}/public

    # Configure separate log files
    ErrorLog /var/log/apache2/${appname}.error.log
    CustomLog /var/log/apache2/${appname}.access.log combined
</VirtualHost>
EOF
if [ ! $? = 0 ]; then
    exit 1
fi

# Activate Apache conf
sudo a2ensite ${appname}.conf
if [ ! $? = 0 ]; then
    exit 1
fi

# Restart Apache to make changes available
sudo service apache2 restart
if [ ! $? = 0 ]; then
    exit 1
fi

# Get a new HTTPS certficate
sudo certbot certonly --webroot -w /var/www/${appname}/public -d ${appdomain}
if [ ! $? = 0 ]; then
    exit 1
fi

# Replace existing conf (copy and paste all stuffs from "cat" to last "EOF" in your terminal)
cat > /etc/apache2/sites-available/${appname}.conf <<EOF
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
</VirtualHost>
EOF
if [ ! $? = 0 ]; then
    exit 1
fi

# Restart Apache to make changes available
sudo service apache2 restart
if [ ! $? = 0 ]; then
    exit 1
fi
