#!/bin/bash

sudo yum update -y
sudo yum install -y httpd php php-mysqlnd
sudo service httpd start
sudo chkconfig httpd on
cd /var/www/html/
sudo wget http://wordpress.org/latest.tar.gz
sudo tar xfz latest.tar.gz
sudo mv wordpress/* ./
sudo rmdir ./wordpress/
sudo rm -f latest.tar.gz
sudo curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
php wp-cli.phar --info
sudo chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp
sudo cp wp-config-sample.php wp-config.php
sudo chmod 777 wp-config.php
wp config set DB_NAME db_name
wp config set DB_USER db_user
wp config set DB_PASSWORD db_password
wp config set DB_HOST db_host
