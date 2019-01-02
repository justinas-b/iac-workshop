#!/bin/bash

echo "DB_ENDPOINT=${db_endpoint}" >> /tmp/rds_endpoint
sudo amazon-linux-extras install nginx1.12 -y
sudo systemctl enable nginx
sudo systemctl start nginx