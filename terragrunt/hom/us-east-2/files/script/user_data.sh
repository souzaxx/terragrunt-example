#!/bin/bash

apt update -y
apt install -y nginx
rm /etc/nginx/sites-enabled/*

cat >/etc/nginx/sites-enabled/hello.conf <<EOL
${base64decode(nginx_conf)}
EOL

cat> /usr/share/nginx/html/index.html <<EOL
${base64decode(webpage)}
EOL

systemctl restart nginx
nginx -t
