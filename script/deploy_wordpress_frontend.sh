#!/bin/bash

set -ex

apt update

#apt upgrade -y

source .env

rm -rf /tmp/wp-cli.phar

wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar 

chmod +x wp-cli.phar

mv /tmp/wp-cli.phar /usr/local/bin/wp

rm -rf /var/www/html/*

wp core download --locale=es_ES --path=/var/www/html --allow-root

wp config create \
  --dbname=$WORDPRESS_DB_NAME \
  --dbuser=$WORDPRESS_DB_USER \
  --dbpass=$WORDPRESS_DB_PASSWORD \
  --dbhost=$WORDPRESS_DB_HOST \
  --path=/var/www/html \
  --allow-root

wp core install \
  --url=$CERTIFICATE_DOMAIN \
  --title="$WORDPRESS_TITTLE" \
  --admin_user=$WORDPRESS_ADMIN_USER \
  --admin_password=$WORDPRESS_ADMIN_PASS \
  --admin_email=$WORDPRESS_ADMIN_EMAIL \
  --path=/var/www/html \
  --allow-root

cp ../htaccess/.htaccess /var/www/html/

rm -rf /var/www/html/wp-config.php

wp plugin install wps-hide-login --activate --path=/var/www/html --allow-root

wp rewrite structure '/%postname%/' --path=/var/www/html --allow-root

wp rewrite flush

chown -R www-data:www-data /var/www/html/