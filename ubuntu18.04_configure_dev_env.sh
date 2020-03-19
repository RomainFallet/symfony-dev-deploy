#!/bin/bash

# Update packages list
if ! sudo apt update; then exit 1; fi

# Install
if ! sudo apt install -y software-properties-common curl; then exit 1; fi
if ! curl --version; then exit 1; fi

# Install
if ! sudo apt install -y git; then exit 1; fi
if ! git --version; then exit 1; fi

# Download executable in local user folder
if ! curl -sS https://get.symfony.com/cli/installer | bash; then exit 1; fi

# Move the executable in global bin directory in order to use it globally
if ! sudo mv ~/.symfony/bin/symfony /usr/local/bin/symfony; then exit 1; fi
if ! symfony -V; then exit 1; fi

# Add PHP official repository
if ! sudo add-apt-repository -y ppa:ondrej/php; then exit 1; fi

# Update packages list
if ! sudo apt update; then exit 1; fi

# Install
if ! sudo apt install -y php7.3; then exit 1; fi

# Install extensions
if ! sudo apt install -y php7.3-mbstring php7.3-mysql php7.3-xml php7.3-curl php7.3-zip php7.3-intl php7.3-gd php-xdebug; then exit 1; fi

# Update some configuration in php.ini
if ! phpinipath=$(php -r "echo php_ini_loaded_file();"); then exit 1; fi
if ! sudo sed -i '.backup' -e 's/post_max_size = 8M/post_max_size = 64M/g' "${phpinipath}"; then exit 1; fi
if ! sudo sed -i '.backup' -e 's/upload_max_filesize = 8M/upload_max_filesize = 64M/g' "${phpinipath}"; then exit 1; fi
if ! sudo sed -i '.backup' -e 's/memory_limit = 128M/memory_limit = -1/g' "${phpinipath}"; then exit 1; fi

# Replace default PHP installation in $PATH
if ! sudo update-alternatives --set php /usr/bin/php7.3; then exit 1; fi
if ! php -v; then exit 1; fi

# Download installer
if ! sudo php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"; then exit 1; fi

# Install
if ! sudo php composer-setup.php --version=1.9.1 --install-dir=/usr/local/bin/; then exit 1; fi

# Remove installer
if ! sudo php -r "unlink('composer-setup.php');"; then exit 1; fi

# Make it executable globally
if ! sudo mv /usr/local/bin/composer.phar /usr/local/bin/composer; then exit 1; fi
if ! composer -V; then exit 1; fi

# Add MariaDB official repository
if ! curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo -E bash; then exit 1; fi

# Update packages list
if ! sudo apt update; then exit 1; fi

# Install
if ! sudo apt install -t mariadb-server-10.4; then exit 1; fi
if ! sudo mysql -e "SELECT VERSION();"; then exit 1; fi

# Add NodeJS official repository and update packages list
if ! curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -; then exit 1; fi

# Install
if ! sudo apt install -y nodejs; then exit 1; fi
if ! node -v; then exit 1; fi
if ! npm -v; then exit 1; fi

# Add Yarn official repository
if ! curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -; then exit 1; fi
if ! echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list; then exit 1; fi

# Update packages list
if ! sudo apt update; then exit 1; fi

# Install
if ! sudo apt install -y yarn=1.21*; then exit 1; fi
if ! yarn -v; then exit 1; fi
