#!/bin/bash

# Update packages list
sudo apt update
if [ ! $? = 0 ]; then
    exit 1
fi

# Install
sudo apt install software-properties-common curl -y
if [ ! $? = 0 ]; then
    exit 1
fi
curl --version
if [ ! $? = 0 ]; then
    exit 1
fi

# Install
sudo apt install git -y
if [ ! $? = 0 ]; then
    exit 1
fi
git --version
if [ ! $? = 0 ]; then
    exit 1
fi

# Download executable in local user folder
curl -sS https://get.symfony.com/cli/installer | bash
if [ ! $? = 0 ]; then
    exit 1
fi

# Move the executable in global bin directory in order to use it globally
sudo mv ~/.symfony/bin/symfony /usr/local/bin/symfony
if [ ! $? = 0 ]; then
    exit 1
fi
symfony -V
if [ ! $? = 0 ]; then
    exit 1
fi

# Add PHP official repository
sudo add-apt-repository ppa:ondrej/php -y
if [ ! $? = 0 ]; then
    exit 1
fi

# Update packages list
sudo apt update
if [ ! $? = 0 ]; then
    exit 1
fi

# Install
sudo apt install php7.3 -y
if [ ! $? = 0 ]; then
    exit 1
fi

# Install extensions
sudo apt install php7.3-mbstring php7.3-mysql php7.3-xml php7.3-curl php7.3-zip php7.3-intl php7.3-gd php-xdebug -y
if [ ! $? = 0 ]; then
    exit 1
fi

# Update some configuration in php.ini
phpinipath=$(php -r "echo php_ini_loaded_file();")
if [ ! $? = 0 ]; then
    exit 1
fi
sudo bash -c "sed -e 's/post_max_size = 8M/post_max_size = 64M/g' ${phpinipath} > ./php.ini.tmp"
if [ ! $? = 0 ]; then
    exit 1
fi
sudo mv ./php.ini.tmp ${phpinipath}
if [ ! $? = 0 ]; then
    exit 1
fi
sudo bash -c "sed -e 's/upload_max_filesize = 8M/upload_max_filesize = 64M/g' ${phpinipath} > ./php.ini.tmp"
if [ ! $? = 0 ]; then
    exit 1
fi
sudo mv ./php.ini.tmp ${phpinipath}
if [ ! $? = 0 ]; then
    exit 1
fi
sudo bash -c "sed -e 's/memory_limit = 128M/memory_limit = -1/g' ${phpinipath} > ./php.ini.tmp"
if [ ! $? = 0 ]; then
    exit 1
fi
sudo mv ./php.ini.tmp ${phpinipath}
if [ ! $? = 0 ]; then
    exit 1
fi

# Replace default PHP installation in $PATH
sudo update-alternatives --set php /usr/bin/php7.3
if [ ! $? = 0 ]; then
    exit 1
fi
php -v
if [ ! $? = 0 ]; then
    exit 1
fi

# Download installer
sudo php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
if [ ! $? = 0 ]; then
    exit 1
fi

# Install
sudo php composer-setup.php --version=1.9.1 --install-dir=/usr/local/bin/
if [ ! $? = 0 ]; then
    exit 1
fi

# Remove installer
sudo php -r "unlink('composer-setup.php');"
if [ ! $? = 0 ]; then
    exit 1
fi

# Make it executable globally
sudo mv /usr/local/bin/composer.phar /usr/local/bin/composer
if [ ! $? = 0 ]; then
    exit 1
fi
composer -V
if [ ! $? = 0 ]; then
    exit 1
fi

# Add MariaDB official repository
curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo -E bash
if [ ! $? = 0 ]; then
    exit 1
fi

# Update packages list
sudo apt update
if [ ! $? = 0 ]; then
    exit 1
fi

# Install
sudo apt install mariadb-server-10.4 -y
if [ ! $? = 0 ]; then
    exit 1
fi

# Add NodeJS official repository and update packages list
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
if [ ! $? = 0 ]; then
    exit 1
fi

# Install
sudo apt install nodejs -y
if [ ! $? = 0 ]; then
    exit 1
fi
node -v
if [ ! $? = 0 ]; then
    exit 1
fi
npm -v
if [ ! $? = 0 ]; then
    exit 1
fi

# Add Yarn official repository
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
if [ ! $? = 0 ]; then
    exit 1
fi
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
if [ ! $? = 0 ]; then
    exit 1
fi

# Update packages list
sudo apt update
if [ ! $? = 0 ]; then
    exit 1
fi

# Install
sudo apt install yarn=1.21* -y
if [ ! $? = 0 ]; then
    exit 1
fi
yarn -v
if [ ! $? = 0 ]; then
    exit 1
fi
