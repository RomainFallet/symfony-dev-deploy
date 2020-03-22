# Install
Try { Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) } Catch { throw $_.Exception.Message }
# Reload your $PATH
Try { $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") } Catch { throw $_.Exception.Message }
Try { choco -v } Catch { throw $_.Exception.Message }
# Install
Try { choco install -y git } Catch { throw $_.Exception.Message }
# Reload $PATH
Try { $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") } Catch { throw $_.Exception.Message }
Try { git --version } Catch { throw $_.Exception.Message }
# Create a new folder
Try { New-Item -ItemType Directory -Force -Path C:\tools } Catch { throw $_.Exception.Message }New-Item -ItemType Directory -Force -Path C:\tools\symfony

# Add this folder to $PATH
Try { [Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\tools\symfony", "Machine") } Catch { throw $_.Exception.Message }
# Determine computer architecture
Try { IF ((Get-WmiObject -class Win32_Processor) -like '*Intel*'){$arch="386"} Else {$arch="amd64"} } Catch { throw $_.Exception.Message }
# Enable TLS 1.2 (in order to connect correctly to Github)
Try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; } Catch { throw $_.Exception.Message }
# Download executable from Github depending on computer architecture
Try { (New-Object System.Net.WebClient).DownloadFile("https://github.com/symfony/cli/releases/latest/download/symfony_windows_$arch.exe", "C:\tools\symfony\symfony.exe"); } Catch { throw $_.Exception.Message }
# Reload $PATH
Try { $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") } Catch { throw $_.Exception.Message }
Try { symfony -V } Catch { throw $_.Exception.Message }
# Install
Try { choco install -y php --version=7.3.12 } Catch { throw $_.Exception.Message }
# Install extensions
Try { Invoke-WebRequest -outf C:\tools\php73\ext\php_xdebug.dll http://xdebug.org/files/php_xdebug-2.9.0-7.3-vc15-nts-x86_64.dll } Catch { throw $_.Exception.Message }
# Activate extensions in php.ini
Try { Add-Content c:\tools\php73\php.ini "extension_dir = ext" } Catch { throw $_.Exception.Message }Add-Content c:\tools\php73\php.ini "zend_extension = C:\tools\php73\ext\php_xdebug.dll"
Try { Add-Content c:\tools\php73\php.ini "zend_extension = C:\tools\php73\ext\php_opcache.dll" } Catch { throw $_.Exception.Message }((Get-Content -path C:\tools\php73\php.ini -Raw) -replace ';extension=mbstring','extension=mbstring') | Set-Content -Path C:\tools\php73\php.ini
Try { ((Get-Content -path C:\tools\php73\php.ini -Raw) -replace ';extension=openssl','extension=openssl') | Set-Content -Path C:\tools\php73\php.ini } Catch { throw $_.Exception.Message }((Get-Content -path C:\tools\php73\php.ini -Raw) -replace ';extension=curl','extension=curl') | Set-Content -Path C:\tools\php73\php.ini
Try { ((Get-Content -path C:\tools\php73\php.ini -Raw) -replace ';extension=pdo_mysql','extension=pdo_mysql') | Set-Content -Path C:\tools\php73\php.ini } Catch { throw $_.Exception.Message }((Get-Content -path C:\tools\php73\php.ini -Raw) -replace ';extension=gd2','extension=gd2') | Set-Content -Path C:\tools\php73\php.ini
Try { ((Get-Content -path C:\tools\php73\php.ini -Raw) -replace ';extension=intl','extension=intl') | Set-Content -Path C:\tools\php73\php.ini } Catch { throw $_.Exception.Message }
# Update some configuration in php.ini
Try { ((Get-Content -path C:\tools\php73\php.ini -Raw) -replace 'post_max_size = 8M','post_max_size = 64M') | Set-Content -Path C:\tools\php73\php.ini } Catch { throw $_.Exception.Message }((Get-Content -path C:\tools\php73\php.ini -Raw) -replace 'upload_max_filesize = 2M','upload_max_filesize = 64M') | Set-Content -Path C:\tools\php73\php.ini
Try { ((Get-Content -path C:\tools\php73\php.ini -Raw) -replace 'memory_limit = 128M','memory_limit = -1') | Set-Content -Path C:\tools\php73\php.ini } Catch { throw $_.Exception.Message }
# Reload $PATH
Try { $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") } Catch { throw $_.Exception.Message }
Try { php -v } Catch { throw $_.Exception.Message }
# Download installer
Try { php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" } Catch { throw $_.Exception.Message }
# Create a new folder
Try { New-Item -ItemType Directory -Force -Path C:\tools } Catch { throw $_.Exception.Message }New-Item -ItemType Directory -Force -Path C:\tools\composer

# Add this folder to $PATH
Try { [Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\tools\composer", "Machine") } Catch { throw $_.Exception.Message }
# Install
Try { php composer-setup.php --version=1.9.1 --install-dir=C:\tools\composer } Catch { throw $_.Exception.Message }
# Remove installer
Try { php -r "unlink('composer-setup.php');" } Catch { throw $_.Exception.Message }
# Make it executable globally
Try { New-Item -ItemType File -Path C:\tools\composer\composer.bat } Catch { throw $_.Exception.Message }Add-Content C:\tools\composer\composer.bat '@php "%~dp0composer.phar" %*'

# Reload $PATH
Try { $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") } Catch { throw $_.Exception.Message }
Try { composer -V } Catch { throw $_.Exception.Message }
# Install
Try { choco install -y mariadb --version=10.4.8 } Catch { throw $_.Exception.Message }
# Reload $PATH
Try { $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") } Catch { throw $_.Exception.Message }
Try { mysql -e "SELECT VERSION();" } Catch { throw $_.Exception.Message }
# Install
Try { choco install -y nodejs --version=12.13.1 } Catch { throw $_.Exception.Message }
# Reload $PATH
Try { $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") } Catch { throw $_.Exception.Message }
Try { node -v } Catch { throw $_.Exception.Message }npm -v

# Install
Try { choco install -y yarn --version=1.21.1 } Catch { throw $_.Exception.Message }
# Reload $PATH
Try { $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") } Catch { throw $_.Exception.Message }
Try { yarn -v } Catch { throw $_.Exception.Message }
