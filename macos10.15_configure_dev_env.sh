#!/bin/bash

# Install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
if [ ! $? = 0 ]; then
    exit 1
fi
brew -v
if [ ! $? = 0 ]; then
    exit 1
fi

# Install
brew install git
if [ ! $? = 0 ]; then
    exit 1
fi
# Reload $PATH
export PATH="/usr/local/bin:$PATH"
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

# Install
brew install php@7.3
if [ ! $? = 0 ]; then
    exit 1
fi

# Replace default macOS PHP installation in $PATH
brew link php@7.3 --force
if [ ! $? = 0 ]; then
    exit 1
fi

# Reload $PATH
export PATH="/usr/local/opt/php@7.3/bin:$PATH"
if [ ! $? = 0 ]; then
    exit 1
fi

# Install extensions
pecl install xdebug
if [ ! $? = 0 ]; then
    exit 1
fi

# Update some configuration in php.ini
phpinipath=$(php -r "echo php_ini_loaded_file();")
if [ ! $? = 0 ]; then
    exit 1
fi
sudo sed -i '' -e 's/post_max_size = 8M/post_max_size = 64M/g' ${phpinipath} > ./php.ini.tmp
if [ ! $? = 0 ]; then
    exit 1
fi
sudo mv ./php.ini.tmp ${phpinipath}
if [ ! $? = 0 ]; then
    exit 1
fi
sudo sed -i '' -e 's/upload_max_filesize = 8M/upload_max_filesize = 64M/g' ${phpinipath} > ./php.ini.tmp
if [ ! $? = 0 ]; then
    exit 1
fi
sudo mv ./php.ini.tmp ${phpinipath}
if [ ! $? = 0 ]; then
    exit 1
fi
sudo sed -i '' -e 's/memory_limit = 128M/memory_limit = -1/g' ${phpinipath} > ./php.ini.tmp
if [ ! $? = 0 ]; then
    exit 1
fi
sudo mv ./php.ini.tmp ${phpinipath}
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

# Install
brew install mariadb@10.4
if [ ! $? = 0 ]; then
    exit 1
fi

# Install
brew install node@12
if [ ! $? = 0 ]; then
    exit 1
fi
# Add node to $PATH
brew link node@12 --force
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

# Install
curl -o- -L https://yarnpkg.com/install.sh | bash -s -- --version 1.21.1
if [ ! $? = 0 ]; then
    exit 1
fi

# Reload $PATH
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
if [ ! $? = 0 ]; then
    exit 1
fi
yarn -v
if [ ! $? = 0 ]; then
    exit 1
fi
