#!/bin/bash
apt-get update
apt-get install -y nginx

HOSTNAME=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

echo "<h1>${environment} - nginx - $HOSTNAME</h1>" > /var/www/html/index.html

systemctl enable nginx
systemctl start nginx
