#!/usr/bin/env bash

PASSWORD='franzela'
PROJECT_FOLDER='Deep-Skies-Symfony'

# update / upgrade
sudo apt-get update
sudo apt-get -y upgrade

# install apache 2.5 and php 5.5
sudo apt-get install -y apache2
sudo apt-get install -y php5

# install mysql and give password to installer
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $PASSWORD"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $PASSWORD"
sudo apt-get -y install mysql-server
sudo apt-get install php5-mysql

# setup hosts file
VHOST=$(cat <<EOF
<VirtualHost *:80>
    DocumentRoot "/var/www/html/${PROJECT_FOLDER}"
    <Directory "/var/www/html/${PROJECT_FOLDER}">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF
)
echo "${VHOST}" > /etc/apache2/sites-available/000-default.conf

# enable mod_rewrite
sudo a2enmod rewrite

echo 'date.timezone = "UTC"' >> /etc/php5/cli/php.ini
echo 'date.timezone = "UTC"' >> /etc/php5/apache2/php.ini

# restart apache
service apache2 restart

# install git
sudo apt-get -y install git

# install node and npm
curl -sL https://deb.nodesource.com/setup_5.x | bash -
apt-get install nodejs --yes
npm install -g less

# install Composer
curl -s https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# get zsh tar file and uncompress its Doc folder to /usr/share/man/man1
wget -qO- "http://downloads.sourceforge.net/project/zsh/zsh/5.0.2/zsh-5.0.2.tar.gz?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fzsh%2Ffiles%2Fzsh%2F5.0.2%2F&ts=1407408881&use_mirror=superb-dca3" | sudo tar xvz -C /usr/share/man/man1/ --wildcards "zsh-5.0.2/Doc/*.1" --strip-components=2

# fix permissions
sudo chown root:root /usr/share/man/man1/zsh*.1
sudo chmod 0644 /usr/share/man/man1/zsh*.1

# gzip the new zsh man pages (all others are gzipped as well)
sudo gzip /usr/share/man/man1/zsh*.1

# renew the man database (so that man -k or apropos finds the newly installed man pages)
sudo mandb

# show installed zsh man pages
man -k zsh

# install zsh and change the default shell.
sudo apt-get install zsh --yes
sudo curl -L http://install.ohmyz.sh > install.sh
sudo sh install.sh

# update the mlocate database.
sudo updatedb
