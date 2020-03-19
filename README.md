# The Symfony dev & deploy instructions kit

![Dev environment install scripts](https://github.com/RomainFallet/symfony-dev-deploy/workflows/Dev%20environment%20install%20scripts/badge.svg)

Welcome! Here is what this repository can do for you:

* Provide instructions to configure a similar Symfony development environment on each platform (Ubuntu 18.04 Desktop, macOS 10.15 and Windows 10).

* Provide instructions to configure a deploy environment on an Ubuntu 18.04 Server machine and automate the update process of a Symfony app.

The goal is to provide an opinionated, fully tested environment, that just work.

**This means no headaches trying to configure an environment or a specific tool and no more versions conflicts!**

![tenor](https://user-images.githubusercontent.com/6952638/72103402-6b97af00-3329-11ea-980d-63242df89644.gif)

## Table of contents

* [Important notice](#important-notice)
* [Quickstart](#quickstart)
    1. [Configure dev environment](#configure-dev-environment)
    2. [Configure deploy environment](#configure-deploy-environment)
    3. [Deploy a new app](#deploy-a-new-app)
    4. [Deploy updates of an existing app](#deploy-updates-of-an-existing-app)
    5. [Deploy updates automatically with GitHub Actions](#deploy-updates-automatically-with-github-actions)
* [Manual configuration: dev environment](#manual-configuration-dev-environment)
    1. [Prerequisites](#prerequisites)
    2. [Git](#git)
    3. [Symfony CLI](#symfony-cli)
    4. [PHP 7.3](#php-73)
    5. [Composer 1.9](#composer-19)
    6. [MariaDB 10.4](#mariadb-104)
    7. [NodeJS 12](#nodejs-12)
    8. [Yarn 1.21](#yarn-121)
* [Manual configuration: deploy environment](#manual-configuration-deploy-environment)
    1. [Apache 2](#apache-2)
    2. [Certbot](#certbot)
    3. [Firewall](#firewall)
* [Manual configuration: deploy a new app](#manual-configuration-deploy-a-new-app)
   1. [Set up variables](#set-up-variables)
   2. [Download our app](#download-our-app)
   3. [Set up the database and the production mode](#set-up-the-database-and-the-production-mode)
   4. [Set permissions](#set-permissions)
   5. [Install dependencies and build assets](#install-dependencies-and-build-assets)
   6. [Execute database migrations](#execute-database-migrations)
   7. [Set up the web server](#set-up-the-web-server)
   8. [Enabling HTTPS & configure for Symfony](#enabling-https--configure-for-symfony)
* [Manual configuration: deploy updates of an existing app](#manual-configuration-deploy-updates-of-an-existing-app)
   1. [Set up variable](#set-up-variable)
   2. [Download updates of our app](#download-updates-of-our-app)
   3. [Update dependencies and rebuild assets](#update-dependencies-and-rebuild-assets)
   4. [Update database structure & clearing cache](#update-database-structure--clearing-cache)

## Important notice

Configuration scripts for dev & deploy environments are meant to be executed after fresh installation of each OS.

Their purpose in not to be bullet-proof neither to handle all cases (we will not build a new MAMP/XAMPP). They are just here to get started quickly as they just execute the exact same commands listed in "manual configuration" sections.

**So, if you have any trouble a non fresh-installed machine, please use "manual configuration" sections to complete your installation environment process.**

## Quickstart

### Configure dev environment

[Back to top ↑](#table-of-contents)

Ubuntu 18.04:

```bash
# Get and execute script directly
bash <(wget --no-cache -o /dev/null -O- https://raw.githubusercontent.com/RomainFallet/symfony-dev-deploy/master/ubuntu18.04_configure_dev_env.sh)
```

MacOS 10.15:

```bash
# Get and execute script directly
bash <(curl -L -H 'Cache-Control: no-cache' https://raw.githubusercontent.com/RomainFallet/symfony-dev-deploy/master/macos10.15_configure_dev_env.sh)
```

Windows 10:

```powershell
# Get and execute script directly
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/RomainFallet/symfony-dev-deploy/master/windows10_configure_dev_env.ps1'))
```

*See [manual instructions](#manual-configuration-dev-environment) for details.*

### Configure deploy environment

[Back to top ↑](#table-of-contents)

*Note: you first need to install everything from [dev environment](#configure-dev-environment).*

Ubuntu 18.04 Server:

```bash
# Get and execute script directly
bash <(wget --no-cache -o /dev/null -O- https://raw.githubusercontent.com/RomainFallet/symfony-dev-deploy/master/ubuntu18.04_configure_deploy_env.sh)
```

*See [manual instructions](#manual-configuration-deploy-a-new-app) for details.*

### Deploy a new app

[Back to top ↑](#table-of-contents)

*Note: you first need to add a A or AAAA record on your domain name poiting to this machine IP address.*

Ubuntu 18.04 Server:

```bash
# Get and execute script directly
bash <(wget --no-cache -o /dev/null -O- https://raw.githubusercontent.com/RomainFallet/symfony-dev-deploy/master/ubuntu18.04_create_app.sh)
```

*Note: just after the "bash" command, you can pass the app name, the domain name and the repository URL as arguments in order to make the script non-interactive (eg. … bash myawesameapp example.com <https://github.com/me/myapp>).*

*See [manual instructions](#manual-configuration-deploy-a-new-app) for details.*

### Deploy updates of an existing app

[Back to top ↑](#table-of-contents)

Ubuntu 18.04 Server:

```bash
# Get and execute script directly
bash <(wget --no-cache -o /dev/null -O- https://raw.githubusercontent.com/RomainFallet/symfony-dev-deploy/master/ubuntu18.04_update_app.sh)
```

*Note: just after the "bash" command, you can pass the app name as an argument in order to make the script non-interactive (eg. … bash myawesameapp).*

*See [manual instructions](#manual-configuration-deploy-updates-of-an-existing-app) for details.*

### Deploy updates automatically with GitHub Actions

To do that you simply have to add a basic Github Actions configuration in your repository and execute the update commands through SSH.

Create a file in ".github/workflows/deploy.yml" at the root of your project containing:

```yaml
name: Deploy updates

on:
  push:
    branches: master

jobs:
  deploy:

    runs-on: ubuntu-18.04

    steps:
    - name: Deploy through SSH
      run: |
        sshpass -p "${{ secrets.SSH_PASS }}" ssh \
        -tt ${{ secrets.SSH_USER }}@${{ secrets.SSH_HOST }} \
        -o StrictHostKeyChecking=no \
        "appname=${{ secrets.APP_NAME }} && $(wget --no-cache -o /dev/null -O- https://raw.githubusercontent.com/RomainFallet/symfony-dev-deploy/master/ubuntu18.04_update_app.sh)"
```

*Note: you must define SSH_PASS, SSH_USER, SSH_HOST and APP_NAME variables in the "Settings > Secrets" section of your GitHub repository. The APP_NAME value must match the one used to deploy the app initially.*

## Manual configuration: dev environment

### Prerequisites

[Back to top ↑](#table-of-contents)

Ubuntu 18.04 Desktop:

![curl](https://user-images.githubusercontent.com/6952638/70372369-31785f00-18de-11ea-9835-2946537372ea.jpg)

On Ubuntu, CURL is needed in order to install some packages with the default package manager.

```bash
# Update packages list
sudo apt update

# Install
sudo apt install -y software-properties-common curl
```

MacOS 10.15:

![homebrew](https://user-images.githubusercontent.com/6952638/70372309-a0a18380-18dd-11ea-8280-e86e84f51043.png)

On MacOS, there is no package manager by default. We need to install the Homebrew package manager in order to install our packages.

Open the Terminal app and type:

```bash
# Install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
```

Windows 10:

![chocolatey](https://user-images.githubusercontent.com/6952638/70372307-a008ed00-18dd-11ea-8288-97a9fbc7fb46.png)

On Windows 10, there is no package manager by default. We need to install the Chocolatey package manager in order to install our packages.

Open the PowerShell command prompt in administrator mode and type:

```powershell
# Install
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Reload your $PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
```

**On Windows, after each installation, you must start a new PowerShell or reload your \$PATH** in order to use the installed packages. All command listed here must only be used inside the PowerShell in **administrator mode** (not the default command prompt).

### Git

[Back to top ↑](#table-of-contents)

![git](https://user-images.githubusercontent.com/6952638/71176962-3a1c4e00-226b-11ea-83a1-5a66bd37a68b.png)

Ubuntu 18.04 Desktop:

```bash
# Install
sudo apt install -y git
```

MacOS 10.15:

```bash
# Install
brew install git

# Reload $PATH
export PATH="/usr/local/bin:$PATH"
```

Windows 10:

```powershell
# Install
choco install -y git

# Reload $PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
```

### Symfony CLI

[Back to top ↑](#table-of-contents)

![symfony](https://user-images.githubusercontent.com/6952638/71176964-3ab4e480-226b-11ea-8522-081106cbff50.png)

Ubuntu 18.04 Desktop:

```bash
# Download executable in local user folder
curl -sS https://get.symfony.com/cli/installer | bash

# Move the executable in global bin directory in order to use it globally
sudo mv ~/.symfony/bin/symfony /usr/local/bin/symfony
```

MacOS 10.15:

```bash
# Download executable in local user folder
curl -sS https://get.symfony.com/cli/installer | bash

# Move the executable in global bin directory in order to use it globally
sudo mv ~/.symfony/bin/symfony /usr/local/bin/symfony
```

Windows 10:

```powershell
# Create a new folder
New-Item -ItemType Directory -Force -Path C:\tools
New-Item -ItemType Directory -Force -Path C:\tools\symfony

# Add this folder to $PATH
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\tools\symfony", "Machine")

# Determine computer architecture
IF ((Get-WmiObject -class Win32_Processor) -like '*Intel*'){$arch="386"} Else {$arch="amd64"}

# Enable TLS 1.2 (in order to connect correctly to Github)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;

# Download executable from Github depending on computer architecture
(New-Object System.Net.WebClient).DownloadFile("https://github.com/symfony/cli/releases/latest/download/symfony_windows_$arch.exe", "C:\tools\symfony\symfony.exe");

# Reload $PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
```

### PHP 7.3

[Back to top ↑](#table-of-contents)

![php](https://user-images.githubusercontent.com/6952638/70372327-bca52500-18dd-11ea-8638-7cdab7c5d6e0.png)

Ubuntu 18.04 Desktop:

```bash
# Add PHP official repository
sudo add-apt-repository -y ppa:ondrej/php

# Update packages list
sudo apt update

# Install
sudo apt install -y php7.3

# Install extensions
sudo apt install -y php7.3-mbstring php7.3-mysql php7.3-xml php7.3-curl php7.3-zip php7.3-intl php7.3-gd php-xdebug

# Update some configuration in php.ini
phpinipath=$(php -r "echo php_ini_loaded_file();")
sudo sed -i '.backup' -e 's/post_max_size = 8M/post_max_size = 64M/g' "${phpinipath}"
sudo sed -i '.backup' -e 's/upload_max_filesize = 8M/upload_max_filesize = 64M/g' "${phpinipath}"
sudo sed -i '.backup' -e 's/memory_limit = 128M/memory_limit = -1/g' "${phpinipath}"

# Replace default PHP installation in $PATH
sudo update-alternatives --set php /usr/bin/php7.3
```

**Installed PHP Modules:** calendar, Core, ctype, curl, date, dom, exif, fileinfo, filter, ftp, gettext, hash, iconv, json, libxml, mbstring, mysqli, mysqlnd, openssl, pcntl, pcre, PDO, pdo_mysql, Phar, posix, readline, Reflection, session, shmop, SimpleXML, sockets, sodium, SPL, standard, sysvmsg, sysvsem, sysvshm, tokenizer, wddx, xdebug, xml, xmlreader, xmlwriter, xsl, Zend OPcache, zip, zlib

**Installed Zend Modules:** Xdebug, Zend OPcache

MacOS 10.15:

```bash
# Install
brew install php@7.3

# Replace default macOS PHP installation in $PATH
brew link php@7.3 --force

# Reload $PATH
export PATH="/usr/local/opt/php@7.3/bin:$PATH"

# Install extensions
pecl install xdebug

# Update some configuration in php.ini
phpinipath=$(php -r "echo php_ini_loaded_file();")
sudo sed -i '.backup' -e 's/post_max_size = 8M/post_max_size = 64M/g' "${phpinipath}"
sudo sed -i '.backup' -e 's/upload_max_filesize = 8M/upload_max_filesize = 64M/g' "${phpinipath}"
sudo sed -i '.backup' -e 's/memory_limit = 128M/memory_limit = -1/g' "${phpinipath}"
```

**Installed PHP Modules:** bcmath, bz2, calendar, Core, ctype, curl, date, dba, dom, exif, fileinfo, filter, ftp, gd, gettext, gmp, hash, iconv, intl, json, ldap, libxml, mbstring, mysqli, mysqlnd, odbc, openssl, pcntl, pcre, PDO, pdo_dblib, pdo_mysql, PDO_ODBC, pdo_pgsql, pdo_sqlite, pgsql, Phar, phpdbg_webhelper, posix, pspell, readline, Reflection, session, shmop, SimpleXML, soap, sockets, sodium, SPL, sqlite3, standard, sysvmsg, sysvsem, sysvshm, tidy, tokenizer, wddx, xdebug, xml, xmlreader, xmlrpc, xmlwriter, xsl, Zend OPcache, zip, zlib

**Installed Zend Modules:** Xdebug, Zend OPcache

Windows 10:

```powershell
# Install
choco install -y php --version=7.3.12

# Install extensions
iwr -outf C:\tools\php73\ext\php_xdebug.dll http://xdebug.org/files/php_xdebug-2.9.0-7.3-vc15-nts-x86_64.dll

# Activate extensions in php.ini
Add-Content c:\tools\php73\php.ini "extension_dir = ext"
Add-Content c:\tools\php73\php.ini "zend_extension = C:\tools\php73\ext\php_xdebug.dll"
Add-Content c:\tools\php73\php.ini "zend_extension = C:\tools\php73\ext\php_opcache.dll"
((Get-Content -path C:\tools\php73\php.ini -Raw) -replace ';extension=mbstring','extension=mbstring') | Set-Content -Path C:\tools\php73\php.ini
((Get-Content -path C:\tools\php73\php.ini -Raw) -replace ';extension=openssl','extension=openssl') | Set-Content -Path C:\tools\php73\php.ini
((Get-Content -path C:\tools\php73\php.ini -Raw) -replace ';extension=curl','extension=curl') | Set-Content -Path C:\tools\php73\php.ini
((Get-Content -path C:\tools\php73\php.ini -Raw) -replace ';extension=pdo_mysql','extension=pdo_mysql') | Set-Content -Path C:\tools\php73\php.ini
((Get-Content -path C:\tools\php73\php.ini -Raw) -replace ';extension=gd2','extension=gd2') | Set-Content -Path C:\tools\php73\php.ini
((Get-Content -path C:\tools\php73\php.ini -Raw) -replace ';extension=intl','extension=intl') | Set-Content -Path C:\tools\php73\php.ini

# Update some configuration in php.ini
((Get-Content -path C:\tools\php73\php.ini -Raw) -replace 'post_max_size = 8M','post_max_size = 64M') | Set-Content -Path C:\tools\php73\php.ini
((Get-Content -path C:\tools\php73\php.ini -Raw) -replace 'upload_max_filesize = 2M','upload_max_filesize = 64M') | Set-Content -Path C:\tools\php73\php.ini
((Get-Content -path C:\tools\php73\php.ini -Raw) -replace 'memory_limit = 128M','memory_limit = -1') | Set-Content -Path C:\tools\php73\php.ini

# Reload $PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
```

**Installed PHP Modules:** bcmath, calendar, Core, ctype, curl, date, dom, filter, gd, hash, iconv, intl, json, libxml, mbstring, mysqlnd, openssl, pcre, PDO, pdo_mysql, Phar, readline, Reflection, session, SimpleXML, SPL, standard, tokenizer, wddx, xdebug, xml, xmlreader, xmlwriter, Zend OPcache, zip, zlib

**Installed Zend Modules:** Xdebug, Zend OPcache

### Composer 1.9

[Back to top ↑](#table-of-contents)

![composer](https://user-images.githubusercontent.com/6952638/70372308-a008ed00-18dd-11ea-9ee0-61d017dfa488.png)

Ubuntu 18.04 Desktop:

```bash
# Download installer
sudo php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"

# Install
sudo php composer-setup.php --version=1.9.1 --install-dir=/usr/local/bin/

# Remove installer
sudo php -r "unlink('composer-setup.php');"

# Make it executable globally
sudo mv /usr/local/bin/composer.phar /usr/local/bin/composer
```

MacOS 10.15:

```bash
# Download installer
sudo php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"

# Install
sudo php composer-setup.php --version=1.9.1 --install-dir=/usr/local/bin/

# Remove installer
sudo php -r "unlink('composer-setup.php');"

# Make it executable globally
sudo mv /usr/local/bin/composer.phar /usr/local/bin/composer
```

Windows 10:

```powershell
# Download installer
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"

# Create a new folder
New-Item -ItemType Directory -Force -Path C:\tools
New-Item -ItemType Directory -Force -Path C:\tools\composer

# Add this folder to $PATH
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\tools\composer", "Machine")

# Install
php composer-setup.php --version=1.9.1 --install-dir=C:\tools\composer

# Remove installer
php -r "unlink('composer-setup.php');"

# Make it executable globally
New-Item -ItemType File -Path C:\tools\composer\composer.bat
Add-Content C:\tools\composer\composer.bat '@php "%~dp0composer.phar" %*'

# Reload $PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
```

### MariaDB 10.4

[Back to top ↑](#table-of-contents)

![mariadb](https://user-images.githubusercontent.com/6952638/71176963-3a1c4e00-226b-11ea-9627-e64caabef009.png)

Ubuntu 18.04:

```bash
# Add MariaDB official repository
curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo -E bash

# Update packages list
sudo apt update

# Install
sudo apt install -y mariadb-server-10.4
```

MacOS 10.15:

```bash
# Install
brew install mariadb@10.4

# Start MariaDB
brew services start mariadb
```

Windows 10:

```powershell
# Install
choco install -y mariadb --version=10.4.8

# Reload $PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
```

### NodeJS 12

[Back to top ↑](#table-of-contents)

![node](https://user-images.githubusercontent.com/6952638/71177167-a4cd8980-226b-11ea-9095-c96d5b96faa7.png)

Ubuntu 18.04 Desktop:

```bash
# Add NodeJS official repository and update packages list
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -

# Install
sudo apt install -y nodejs
```

MacOS 10.15:

```bash
# Install
brew install node@12

# Add node to $PATH
brew link node@12 --force
```

Windows 10:

```powershell
# Install
choco install -y nodejs --version=12.13.1

# Reload $PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
```

### Yarn 1.21

[Back to top ↑](#table-of-contents)

![yarn](https://user-images.githubusercontent.com/6952638/70372314-a13a1a00-18dd-11ea-9cdb-7b976c2beab8.png)

Ubuntu 18.04 Desktop:

```bash
# Add Yarn official repository
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

# Update packages list
sudo apt update

# Install
sudo apt install -y yarn=1.21*
```

MacOS 10.15:

```bash
# Install
curl -o- -L https://yarnpkg.com/install.sh | bash -s -- --version 1.21.1

# Reload $PATH
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
```

Windows 10:

```powershell
# Install
choco install -y yarn --version=1.21.1

# Reload $PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
```

## Deploy environment: Quick configuration

[Back to top ↑](#table-of-contents)

*Note: you first need to install everything from [dev environment](#dev-environment-quick-configuration).*

Ubuntu 18.04 Server:

```bash
# Get and execute configuration script directly
wget --no-cache -o /dev/null -O- https://raw.githubusercontent.com/RomainFallet/symfony-dev-deploy/master/ubuntu18.04_configure_deploy_env.sh | bash
```

## Manual configuration: deploy environment

*Note: you first need to install everything from [dev environment](#dev-environment-quick-configuration).*

### Apache 2

[Back to top ↑](#table-of-contents)

Ubuntu 18.04 Server:

```bash
# Update packages list
sudo apt update

# Install
sudo apt install -y apache2

# Enable modules
sudo a2enmod ssl
sudo a2enmod rewrite

# Copy php.ini CLI configuration
phpinipath=$(php -r "echo php_ini_loaded_file();")
sudo mv "${phpinipath}" /etc/php/7.3/apache2/php.ini
```

**Installed Apache Modules:** core_module, so_module, watchdog_module, http_module, log_config_module, logio_module, version_module, unixd_module, access_compat_module, alias_module, auth_basic_module, authn_core_module, authn_file_module, authz_core_module, authz_host_module, authz_user_module, autoindex_module, deflate_module, dir_module, env_module, filter_module, mime_module, mpm_prefork_module, negotiation_module, php7_module, reqtimeout_module, rewrite_module, setenvif_module, socache_shmcb_module, ssl_module, status_module

### Certbot

[Back to top ↑](#table-of-contents)

In order to get SSL certifications, we need certbot.

Ubuntu 18.04 Server:

```bash
# Add Certbot official repositories
sudo add-apt-repository universe
sudo add-apt-repository -y ppa:certbot/certbot

# Install
sudo apt install -y certbot
```

### Firewall

[Back to top ↑](#table-of-contents)

We will enable Ubuntu firewall in order to prevent remote access to our machine. We will only allow SSH (for remote SSH access) and Apache2 (for remote web access). **Careful, you need to allow SSH before enabling the firewall, if not, you may lose access to your machine.**

Ubuntu 18.04 Server:

```bash
# Add rules and activate firewall
sudo ufw allow OpenSSH
sudo ufw allow in "Apache Full"
echo 'y' | sudo ufw enable
```

## Manual configuration: deploy a new app

*Note: you first need to add a A or AAAA record on your domain name poiting to this machine IP address.*

### Set up variables

[Back to top ↑](#table-of-contents)

We need to configure some variables in order to reduce repetitions/replacements in the next commands.

Ubuntu 18.04 Server:

```bash
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
```

### Download our app

[Back to top ↑](#table-of-contents)

Ubuntu 18.04 Server:

```bash
# Clone app repository
git clone ${apprepositoryurl} /var/www/${appname}

# Go inside the app directory
cd /var/www/${appname}
```

### Set up the database and the production mode

[Back to top ↑](#table-of-contents)

Ubuntu 18.04 Server:

```bash
# Generate a random password for the new mysql user
mysqlpassword=$(openssl rand -hex 15)

# Create database and related user for the app and grant permissions (copy and paste all stuffs from "sudo mysql" to "EOF" in your terminal)
sudo mysql <<EOF
CREATE DATABASE ${appname};
CREATE USER ${appname}@localhost IDENTIFIED BY '${mysqlpassword}';
GRANT ALL ON ${appname}.* TO ${appname}@localhost;
EOF

# Create .env.local file
cp ./.env ./.env.local

# Set APP_ENV to "prod"
sed -e 's/APP_ENV=dev/APP_ENV=prod/g' ./.env.local > ./.env.local.tmp
mv ./.env.local.tmp ./.env.local

# Set mysql credentials
sed -e 's,DATABASE_URL=mysql://db_user:db_password@127.0.0.1:3306/db_name,DATABASE_URL=mysql://'${appname}':'${mysqlpassword}'@127.0.0.1:3306/'${appname}',g' ./.env.local > ./.env.local.tmp
mv ./.env.local.tmp ./.env.local
```

### Set permissions

[Back to top ↑](#table-of-contents)

Ubuntu 18.04 Server:

```bash
# Set ownership to Apache
sudo chown -R www-data:www-data /var/www/${appname}

# Set files permissions to 644
sudo find /var/www/${appname} -type f -exec chmod 644 {} \;

# Set folders permissions to 755
sudo find /var/www/${appname} -type d -exec chmod 755 {} \;
```

### Install dependencies and build assets

[Back to top ↑](#table-of-contents)

Ubuntu 18.04 Server:

```bash
# Install PHP dependencies
composer install

# Install JS dependencies
yarn install

# Build assets
yarn build
```

### Execute database migrations

[Back to top ↑](#table-of-contents)

```bash
# Execute database migrations
php bin/console doctrine:migrations:diff
php bin/console doctrine:migrations:migrate -n
```

### Set up the web server

[Back to top ↑](#table-of-contents)

Ubuntu 18.04 Server:

```bash
# Create an Apache conf file for the app (copy and paste all stuffs from "cat" to "EOF" in your terminal)
cat > /etc/apache2/sites-available/${appname}.conf <<EOF
# Listen on port 80 (HTTP)
<VirtualHost ${appdomain}:80>
    # Set up server name
    ServerName ${appdomain}

    # Set up document root
    DocumentRoot /var/www/${appname}/public

    # Configure separate log files
    ErrorLog /var/log/apache2/error.${appname}.log
    CustomLog /var/log/apache2/access.${appname}.log combined
</VirtualHost>
EOF

# Activate Apache conf
sudo a2ensite ${appname}.conf

# Restart Apache to make changes available
sudo service apache2 restart
```

### Enabling HTTPS & configure for Symfony

[Back to top ↑](#table-of-contents)

Ubuntu 18.04 Server:

```bash
# Get a new HTTPS certficate
sudo certbot certonly --webroot -w /var/www/${appname}/public -d ${appdomain}

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
    ErrorLog /var/log/apache2/error.${appname}.log
    CustomLog /var/log/apache2/access.${appname}.log combined

    # Configure HTTPS
    SSLEngine on
    SSLCertificateFile /etc/letsencrypt/live/${appdomain}/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/${appdomain}/privkey.pem
</VirtualHost>
EOF

# Restart Apache to make changes available
sudo service apache2 restart
```

## Manual configuration: deploy updates of an existing app

[Back to top ↑](#table-of-contents)

### Set up variable

Ubuntu 18.04 Server:

```bash
# Get app name from parameter or ask user for it (copy and paste all code between "if" and "fi" in your terminal)
if [[ -z ${1} ]] && [[ -z "${appname}" ]]; then
    read -p "Enter the name of your app without hyphens (eg. myawesomeapp):" appname
else
    appname=${1:-${appname}}
fi
```

### Download updates of our app

[Back to top ↑](#table-of-contents)

Ubuntu 18.04 Server:

```bash
# Go inside the app directory
cd /var/www/${appname}

# Pull the latest changes
git pull
```

### Update dependencies and rebuild assets

[Back to top ↑](#table-of-contents)

Ubuntu 18.04 Server:

```bash
# Install PHP dependencies
composer install

# Install JS dependencies
yarn install

# Build assets
yarn build
```

### Update database structure & clear cache

[Back to top ↑](#table-of-contents)

Ubuntu 18.04 Server:

```bash
# Execute database migrations
php bin/console doctrine:migrations:diff
php bin/console doctrine:migrations:migrate -n

# Clear the cache
php bin/console cache:clear
```
