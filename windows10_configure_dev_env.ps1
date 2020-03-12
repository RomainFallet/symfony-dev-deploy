# Install
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Reload your $PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

choco -v

# Install
choco install git -y

# Reload $PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

git --version

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

symfony -V

# Install
choco install php --version=7.3.12 -y

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

php -v

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

composer -V

# Install
choco install mariadb --version=10.4.8 -y

# Reload $PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Install
choco install nodejs --version=12.13.1 -y

# Reload $PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

node -v
npm -v

# Install
choco install yarn --version=1.21.1 -y

# Reload $PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

yarn -v
