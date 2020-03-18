#!/bin/bash

# Update packages list
sudo apt update
if [ ! $? = 0 ]; then
    exit 1
fi

# Install
sudo apt install apache2 -y
if [ ! $? = 0 ]; then
    exit 1
fi

# Enable modules
sudo a2enmod ssl
if [ ! $? = 0 ]; then
    exit 1
fi
sudo a2enmod rewrite
if [ ! $? = 0 ]; then
    exit 1
fi

# Copy php.ini CLI configuration
sudo mv $(php -r "echo php_ini_loaded_file();") /etc/php/7.3/apache2/php.ini
if [ ! $? = 0 ]; then
    exit 1
fi
apache2 -v
if [ ! $? = 0 ]; then
    exit 1
fi

# Add Certbot official repositories
sudo add-apt-repository universe
if [ ! $? = 0 ]; then
    exit 1
fi
sudo add-apt-repository ppa:certbot/certbot -y
if [ ! $? = 0 ]; then
    exit 1
fi

# Install
sudo apt install certbot -y
if [ ! $? = 0 ]; then
    exit 1
fi

# Add rules and activate firewall
sudo ufw allow OpenSSH
if [ ! $? = 0 ]; then
    exit 1
fi
sudo ufw allow in "Apache Full"
if [ ! $? = 0 ]; then
    exit 1
fi
echo 'y' | sudo ufw enable
if [ ! $? = 0 ]; then
    exit 1
fi

# Install
sudo apt install -y fail2ban

# Add SSH configuration
echo "
[sshd]
enabled = true
port = 22
filter = sshd
logpath = /var/log/auth.log
maxretry = 3" | sudo tee -a /etc/fail2ban/jail.local > /dev/null

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
logpath = /var/log/apache*/*access.log " | sudo tee -a /etc/fail2ban/jail.local > /dev/null

# Restart Fail2ban
sudo service fail2ban restart
