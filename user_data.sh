#!/bin/bash

sudo amazon-linux-extras install nginx1.12 -y
sudo systemctl enable nginx
sudo systemctl start nginx