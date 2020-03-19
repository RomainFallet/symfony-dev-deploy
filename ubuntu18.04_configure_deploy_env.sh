#!/bin/bash

# Update packages list
if ! sudo apt update; then exit 1; fi

# Install
if ! sudo apt install-y apache2; then exit 1; fi

# Enable modules
if ! sudo a2enmod ssl; then exit 1; fi
if ! sudo a2enmod rewrite; then exit 1; fi

# Copy php.ini CLI configuration
phpinipath=$(php -r "echo php_ini_loaded_file();")
if ! sudo mv "${phpinipath}" /etc/php/7.3/apache2/php.ini; then exit 1; fi
if ! apache2 -v; then exit 1; fi

# Add Certbot official repositories
if ! sudo add-apt-repository universe; then exit 1; fi
if ! sudo add-apt-repository -y ppa:certbot/certbot; then exit 1; fi

# Install
if ! sudo apt install -y certbot; then exit 1; fi

# Add rules and activate firewall
if ! sudo ufw allow OpenSSH; then exit 1; fi
if ! sudo ufw allow in "Apache Full"; then exit 1; fi
if ! echo 'y' | sudo ufw enable; then exit 1; fi

# Install
if ! sudo apt install -y fail2ban; then exit 1; fi

# Add SSH configuration
if ! echo "
[sshd]
enabled = true
port = 22
filter = sshd
logpath = /var/log/auth.log
maxretry = 3" | sudo tee -a /etc/fail2ban/jail.local > /dev/null; then exit 1; fi

# Add Apache configuration
if ! echo "
[apache]
enabled  = true
port     = http,https
filter   = apache-auth
logpath  = /var/log/apache*/*error.log
maxretry = 6

[apache-noscript]
enabled  = true
port     = http,https
filter   = apache-noscript
logpath  = /var/log/apache*/*error.log
maxretry = 6

[apache-overflows]
enabled  = true
port     = http,https
filter   = apache-overflows
logpath  = /var/log/apache*/*error.log
maxretry = 2

[apache-nohome]
enabled  = true
port     = http,https
filter   = apache-nohome
logpath  = /var/log/apache*/*error.log
maxretry = 2

[apache-botsearch]
enabled  = true
port     = http,https
filter   = apache-botsearch
logpath  = /var/log/apache*/*error.log
maxretry = 2

[apache-shellshock]
enabled  = true
port     = http,https
filter   = apache-shellshock
logpath  = /var/log/apache*/*error.log
maxretry = 2

[apache-fakegooglebot]
enabled  = true
port     = http,https
filter   = apache-fakegooglebot
logpath  = /var/log/apache*/*error.log
maxretry = 2

[php-url-fopen]
enabled = true
port    = http,https
filter  = php-url-fopen
logpath = /var/log/apache*/*access.log " | sudo tee -a /etc/fail2ban/jail.local > /dev/null; then exit 1; fi

# Restart Fail2ban
if ! sudo service fail2ban restart; then exit 1; fi
