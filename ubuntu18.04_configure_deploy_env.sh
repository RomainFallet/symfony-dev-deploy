#!/bin/bash

# Update packages list
sudo apt update || exit 1

# Install
sudo apt install-y apache2 || exit 1

# Enable modules
sudo a2enmod ssl || exit 1
sudo a2enmod rewrite || exit 1

# Copy php.ini CLI configuration
phpinipath=$(php -r "echo php_ini_loaded_file();")
sudo mv "${phpinipath}" /etc/php/7.3/apache2/php.ini || exit 1
apache2 -v || exit 1

# Add Certbot official repositories
sudo add-apt-repository universe || exit 1
sudo add-apt-repository -y ppa:certbot/certbot || exit 1

# Install
sudo apt install -y certbot || exit 1

# Add rules and activate firewall
sudo ufw allow OpenSSH || exit 1
sudo ufw allow in "Apache Full" || exit 1
echo 'y' | sudo ufw enable || exit 1

# Install
sudo apt install -y fail2ban || exit 1

# Add SSH configuration
echo "
[sshd]
enabled = true
port = 22
filter = sshd
logpath = /var/log/auth.log
maxretry = 3" | sudo tee -a /etc/fail2ban/jail.local > /dev/null || exit 1

# Add Apache configuration
echo "
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
logpath = /var/log/apache*/*access.log " | sudo tee -a /etc/fail2ban/jail.local > /dev/null || exit 1

# Restart Fail2ban
sudo service fail2ban restart || exit 1
