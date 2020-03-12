#!/bin/bash

# Get app name from parameter or ask user for it (copy and paste all code between "if" and "fi" in your terminal)
if [[ -z ${1} ]] && [[ -z "${appname}" ]]; then
    read -p "Enter the name of your app without hyphens (eg. myawesomeapp):" appname
else
    appname=${1:-${appname}}
fi

# Go inside the app directory
cd /var/www/${appname}
if [ ! $? = 0 ]; then
    exit 1
fi

# Pull the latest changes
git pull
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
if [ ! $? = 0 ]; then
    exit 1
fi
php bin/console doctrine:migrations:migrate -n
if [ ! $? = 0 ]; then
    exit 1
fi

# Clear the cache
php bin/console cache:clear
if [ ! $? = 0 ]; then
    exit 1
fi
