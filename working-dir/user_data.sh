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
