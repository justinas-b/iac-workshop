#!/bin/bash

sudo yum update -y
sudo yum install -y httpd php php-mysqlnd
sudo service httpd start
sudo chkconfig httpd on
cd /var
sudo chmod -R 777 www
cd www/html
sudo curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
php wp-cli.phar --info
sudo chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp
wp core download
wp core config --dbname=${db_name} --dbuser=${db_user} --dbpass=${db_password} --dbhost=${db_endpoint} --dbprefix=prfx_
wp core install --url=${alb_dns}  --title="${owner} WordPress Website Title" --admin_user=admin --admin_password=admin --admin_email="admin@example.com"	
