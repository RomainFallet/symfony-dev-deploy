#!/bin/bash

# Install
if ! /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"; then
    exit 1
fi
if ! brew -v; then
    exit 1
fi

# Install
brew install git
if ! brew install git; then
    exit 1
fi
# Reload $PATH
if ! export PATH="/usr/local/bin:$PATH"; then
    exit 1
fi
if  ! git --version; then
    exit 1
fi

# Download executable in local user folder
if ! curl -sS https://get.symfony.com/cli/installer | bash; then
    exit 1
fi

# Move the executable in global bin directory in order to use it globally
if ! sudo mv ~/.symfony/bin/symfony /usr/local/bin/symfony; then
    exit 1
fi
if ! symfony -V; then
    exit 1
fi

# Install
if ! brew install php@7.3; then
    exit 1
fi

# Replace default macOS PHP installation in $PATH
if ! brew link php@7.3 --force; then
    exit 1
fi

# Reload $PATH
if ! export PATH="/usr/local/opt/php@7.3/bin:$PATH"; then
    exit 1
fi

# Install extensions

if ! pecl install xdebug; then
    exit 1
fi

# Update some configuration in php.ini
if ! phpinipath=$(php -r "echo php_ini_loaded_file();"); then
    exit 1
fi
if ! sudo sed -i '.backup' -e 's/post_max_size = 8M/post_max_size = 64M/g' "${phpinipath}"; then
    exit 1
fi
if ! sudo sed -i '.backup' -e 's/upload_max_filesize = 8M/upload_max_filesize = 64M/g' "${phpinipath}"; then
    exit 1
fi
if ! sudo sed -i '.backup' -e 's/memory_limit = 128M/memory_limit = -1/g' "${phpinipath}"; then
    exit 1
fi
if ! php -v; then
    exit 1
fi

# Download installer
if ! sudo php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"; then
    exit 1
fi

# Install
if ! sudo php composer-setup.php --version=1.9.1 --install-dir=/usr/local/bin/; then
    exit 1
fi

# Remove installer
if ! sudo php -r "unlink('composer-setup.php');"; then
    exit 1
fi

# Make it executable globally
if ! sudo mv /usr/local/bin/composer.phar /usr/local/bin/composer; then
    exit 1
fi
if ! composer -V; then
    exit 1
fi

# Install
if ! brew install mariadb@10.4; then
    exit 1
fi
if ! brew services start mariadb; then
    exit 1
fi
if ! sudo mysql -e "SELECT VERSION();"; then
    exit 1
fi

# Install
if ! brew install node@12; then
    exit 1
fi
# Add node to $PATH
if ! brew link node@12 --force; then
    exit 1
fi
if ! node -v; then
    exit 1
fi
if ! npm -v; then
    exit 1
fi

# Install
if ! curl -o- -L https://yarnpkg.com/install.sh | bash -s -- --version 1.21.1; then
    exit 1
fi

# Reload $PATH
if ! export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"; then
    exit 1
fi
if ! yarn -v; then
    exit 1
fi
