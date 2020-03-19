#!/bin/bash

# Get app name from parameter or ask user for it (copy and paste all code between "if" and "fi" in your terminal)
if [[ -z "${appname}" ]]; then
    read -r -p "Enter the name of your app without hyphens (eg. myawesomeapp): " appname
fi

# Go inside the app directory
cd "/var/www/${appname}" || exit 1

# Pull the latest changes
git pull || exit 1

# Install PHP dependencies
composer install || exit 1

# Install JS dependencies
yarn install || exit 1

# Build assets
yarn build || exit 1

# Execute database migrations
php bin/console doctrine:migrations:diff
php bin/console doctrine:migrations:migrate -n

# Clear the cache
php bin/console cache:clear || exit 1
