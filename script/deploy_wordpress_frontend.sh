#!/bin/bash

#Muestra todos los comandos que se van ejecutadno
set -ex

# Actualizamos los repositorios
apt update

# Actualizamos los paquetes 
apt upgrade -y

# Ponemos las variables del archivo .env
source .env

# Borramos instalaciones previas de wp-cli
rm -rf /tmp/wp-cli.phar

# Descargamos el archivo wp-cli.phar del repositorio oficial de WP-CLI. 
wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar 

# Le asignamos permisos de ejecución al archivo wp-cli.phar.
chmod +x wp-cli.phar

# Movemos el archivo wp-cli.phar al directorio /usr/local/bin/ con el nombre wp para poder utilizarlo sin necesidad de escribir la ruta completa donde se encuentra.
mv wp-cli.phar /usr/local/bin/wp

# Eliminamos instalaciones revias de WordPress
rm -rf /var/www/html/*

# Descargamos el código fuente de WordPress en /var/www/html
wp core download --locale=es_ES --path=/var/www/html --allow-root

# Creamos el archivo wp-config
wp config create \
  --dbname=$WORDPRESS_DB_NAME \
  --dbuser=$WORDPRESS_DB_USER \
  --dbpass=$WORDPRESS_DB_PASSWORD \
  --dbhost=$WORDPRESS_DB_HOST \
  --path=$WORDPRESS_DIRECTORY \
  --allow-root

wp core install \
  --url=practica-wordpress.ddns.net \
  --title="$WORDPRESS_TITLE" \
  --admin_user=$WORDPRESS_USER \
  --admin_password=$WORDPRESS_PASSWORD \
  --admin_email=$WORDPRESS_EMAIL \
  --path=$WORDPRESS_DIRECTORY \
  --allow-root  

cp ../htaccess/.htaccess $WORDPRESS_DIRECTORY --allow-root

wp plugin install wps-hide-login --activate --path=$WORDPRESS_DIRECTORY --allow-root

wp option update whl_page "$WORDPRESS_HIDE_LOGIN_URL" --path=$WORDPRESS_DIRECTORY --allow-root

wp rewrite structure '/%postname%/' --path=$WORDPRESS_DIRECTORY --allow-root

wp rewrite flush --allow-root

sudo chown -R www-data:www-data $WORDPRESS_DIRECTORY --allow-root
