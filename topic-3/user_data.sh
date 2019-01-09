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
sudo cp wp-config-sample.php wp-config.php
sudo chmod 777 wp-config.php
wp config set DB_NAME ${db_name}
wp config set DB_USER ${db_user}
wp config set DB_PASSWORD ${db_password}
wp config set DB_HOST ${db_endpoint}
wp core install --url=${alb_dns}  --title="${owner} Website Title" --admin_user=admin --admin_password=admin --admin_email="admin@example.com"
