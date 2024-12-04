# Practica 01-09

Usaremos el mismo repositorio para las 2 instancias: el **Frontend** y el **Backend**.
Usaremos el **Frontend** para instalar el servidor web **Apache Server** y el **Backend** instalaremos un servidor **MySQL**.
Tendremos los siguientes directorios:

    ├── README.md
    	├── conf
    	│   └── 000-default.conf
    	└── scripts
    		├── .env
            ├── install_load_frontend.sh
    		├── install_lamp_frontend.sh
    		├── install_lamp_backend.sh
    		├── setup_letsencrypt_https.sh    
    		└── deploys.sh

-   `.env`: Este archivo contiene todas las variables de configuración que se utilizarán en los scripts de Bash.
    
-   `install_lamp_frontend.sh`:  Automatización del proceso de instalación de la pila **LAMP** en la máquina de **Frontend**.
    
-   `install_lamp_frontend.sh`:  Automatización del proceso de instalación de la pila **LAMP** en la máquina de **Backend**.
    
-   `setup_letsencrypt_https.sh`:  Automatización del proceso de solicitar un certificado **SSL/TLS** de **Let’s Encrypt** y configurarlo en el servidor web **Apache**.
    
-   `deploy.sh`:  Automatización del proceso de instalación de **WordPress** sobre el directorio raíz  `/var/www/html`.

## Contenido archivo ".env"
Configuramos las variables de todos los Scripts

    LE_EMAIL=PRACTICA1.9@prueba.com
    LE_DOMAIN=practica-wordpress.ddnsking.com
    #variables wordpress
    WORDPRESS_DB_NAME=wordpress
    WORDPRESS_DB_USER=alex
    WORDPRESS_DB_PASSWORD=1234
    WORDPRESS_DB_HOST=172.31.26.16
    WORDPRESS_EMAIL=demo@demo.es
    WORDPRESS_TITTLE="Sitio Web de IAW"
    WORDPRESS_ADMIN_USER=admin
    WORDPRESS_ADMIN_PASS=admin
    WORDPRESS_ADMIN_EMAIL=demo@demo.es
    ###PAGINA
    WORDPRESS_DIRECTORY="/var/www/html"
    WORDPRESS_HIDE_LOGIN_URL="alex"
    BACKEND_MYSQL_PRIVATE_IP=172.31.26.16
    FRONTEND_PRIVATE_IP=172.31.23.20

## Contenido archivo "setup_loadbalancer.sh"

## Contenido archivo `setup_loadbalancer.sh`

1. `set -ex`: Configura el modo de ejecución del script. La opción `-e` hace que el script se detenga si algún comando falla, y `-x` muestra los comandos ejecutados con sus argumentos.

2. `source .env`: Importa las variables de entorno desde el archivo `.env` para ser utilizadas durante la ejecución del script.

3. `apt update`: Actualiza la lista de repositorios disponibles.

4. `apt upgrade -y`: Actualiza los paquetes instalados a sus versiones más recientes.

5. `apt install nginx -y`: Instala el servidor web Nginx.

6. **Deshabilitar el virtualhost por defecto**  
   Comprueba si existe el archivo predeterminado de configuración de Nginx y lo elimina.  
   ```bash
   if [ -f "/etc/nginx/sites-enabled/default" ]; then
       unlink /etc/nginx/sites-enabled/default
   fi

7. **Copiar el archivo de configuración del balanceador de carga**  
   Copia la configuración personalizada del balanceador de carga a la ruta adecuada.  
   ```bash
   cp ../conf/load-balancer.conf /etc/nginx/sites-available

8. **Sustituir valores en el archivo de configuración**  
   Reemplaza las variables `IP_FRONTEND_1` y `IP_FRONTEND_2` con los valores correspondientes del archivo `.env`.  
   ```bash
   sed -i "s/IP_FRONTEND_1/$IP_FRONTEND_1/" /etc/nginx/sites-available/load-balancer.conf
   sed -i "s/IP_FRONTEND_2/$IP_FRONTEND_2/" /etc/nginx/sites-available/load-balancer.conf


9. **Habilitar el virtualhost del balanceador de carga**  
   Crea un enlace simbólico para habilitar la configuración del balanceador de carga si aún no existe.  
   ```bash
   if [ ! -f "/etc/nginx/sites-enabled/load-balancer.conf" ]; then 
       ln -s /etc/nginx/sites-available/load-balancer.conf /etc/nginx/sites-enabled
   fi


10. **Reiniciar el servicio Nginx**  
    Reinicia el servicio de Nginx para aplicar los cambios de configuración.  
    ```bash
    systemctl restart nginx
    ```




## Contenido archivo "deploy_wordpress_backend.sh"

1.  `set -ex`: Configura el modo de ejecución del script. `-e` hace que el script se detenga si algún comando devuelve un código de error, y `-x` muestra los comandos ejecutados con sus argumentos y resultados.
    
2.  `apt update`: Actualiza la lista de paquetes disponibles para su instalación.
    
3.  `apt upgrade -y`: Realiza la actualización del sistema operativo y paquetes instalados.
    
4.  `source .env`: Carga las variables de entorno desde el archivo `.env` al script.
    
5.  `systemctl restart mysql`: Reinicia el servicio **MySQL** para aplicar los cambios.
    
6.  `mysql -u root <<< "DROP DATABASE IF EXISTS $WORDPRESS_DB_NAME"`: Elimina la base de datos de **WordPress** si ya existe.
    
7.  `mysql -u root <<< "CREATE DATABASE $WORDPRESS_DB_NAME"`: Crea una nueva base de datos de **WordPress**.
    
8.  `mysql -u root <<< "DROP USER IF EXISTS $WORDPRESS_DB_USER@$FRONTEND_PRIVATE_IP"`: Elimina el usuario de la base de datos si ya existe.
    
9.  `mysql -u root <<< "CREATE USER $WORDPRESS_DB_USER@$FRONTEND_PRIVATE_IP IDENTIFIED BY '$WORDPRESS_DB_PASSWORD'"`: Crea un nuevo usuario de base de datos con la contraseña especificada.
    
10.  `mysql -u root <<< "GRANT ALL PRIVILEGES ON $WORDPRESS_DB_NAME.* TO $WORDPRESS_DB_USER@$FRONTEND_PRIVATE_IP"`: Concede todos los privilegios al nuevo usuario sobre la nueva base de datos.
    
11.  `mysql -u root <<< "FLUSH PRIVILEGES"`: Recarga los privilegios de **MySQL** para aplicar los cambios.

## Contenido archivo "deploy_wordpress_frontend.sh"

1.  `set -ex`: Configura el modo de ejecución del script. `-e` hace que el script se detenga si algún comando devuelve un código de error, y `-x` muestra los comandos ejecutados con sus argumentos y resultados.
    
2.  `apt update`: Actualiza la lista de paquetes disponibles para su instalación.
    
3.  `source .env`: Carga las variables de entorno desde el archivo `.env` al script.
    
4.  `rm -rf /tmp/wp-cli.phar`: Elimina el archivo *wp-cli.phar* en el directorio temporal */tmp*.
    
5.  `wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar`: Descarga el archivo *wp-cli.phar* desde **GitHub**.
    
6.  `chmod +x wp-cli.phar`: Otorga permisos de ejecución al archivo *wp-cli.phar.*
    
7.  `mv /tmp/wp-cli.phar /usr/local/bin/wp`: Mueve el archivo *wp-cli.phar* al directorio */usr/local/bin/* con el nombre '**wp**', haciéndolo ejecutable.
    
8.  `rm -rf /var/www/html/*`: Elimina el contenido del directorio */var/www/html/*.
    
9.  `wp core download --locale=es_ES --path=/var/www/html --allow-root`: Descarga el núcleo de **WordPress** en español al directorio */var/www/html/*.
    
10.  `wp config create ...`: Crea el archivo de configuración de **WordPress** con la información proporcionada.
    
11.  `wp core install ...`: Instala **WordPress** con la configuración y credenciales proporcionadas.
    
12.  `cp ../htaccess/.htaccess /var/www/html/`: Copia el archivo **.htaccess** desde el directorio *../htaccess/* al directorio */var/www/html/.*
    
13.  `rm -rf /var/www/html/wp-config.php`: Elimina el archivo *wp-config.php* existente en */var/www/html/*.
    
14.  `wp plugin install ...`: Instala y activa el plugin "**wps-hide-login**".
    
15.  `wp rewrite structure '/%postname%/' --path=/var/www/html --allow-root`: Establece la estructura de las **PermaLinks** de **WordPress**.
    
16.  `wp rewrite flush`: Actualiza las reglas de reescritura de URL.
    
17.  `chown -R www-data:www-data /var/www/html/`: Asigna el ownership del directorio */var/www/html/* al usuario y grupo *www-data*.

## Contenido archivo "install_lamp_backend.sh"

1.  `set -ex`: Configura el modo de ejecución del script. `-e` hace que el script se detenga si algún comando devuelve un código de error, y `-x` muestra los comandos ejecutados con sus argumentos y resultados.
    
2.  `apt-get update`: Actualiza la lista de paquetes disponibles para su instalación.
    
3.  `apt-get upgrade -y`: Realiza la actualización del sistema operativo y paquetes instalados.
    
4.  `source .env`: Carga las variables de entorno desde el archivo `.env` al script.
    
5.  `apt-get install mysql-server -y`: Instala el servidor **MySQL**.
    
6.  `sed -i "s/127.0.0.1/$MYSQL_PRIVATE_IP/" /etc/mysql/mysql.conf.d/mysqld.cnf`: Modifica el archivo de configuración de **MySQL** para usar la dirección IP especificada en lugar de 127.0.0.1.
    
7.  `sudo mysql -u root <<< "DROP USER IF EXISTS '$WORDPRESS_DB_USER'@'$FRONTEND_PRIVATE_IP';"`: Elimina el usuario de la base de datos si ya existe.
    
8.  `sudo mysql -u root <<< "CREATE USER '$WORDPRESS_DB_USER'@'$FRONTEND_PRIVATE_IP' IDENTIFIED BY '$WORDPRESS_DB_PASSWORD';"`: Crea un nuevo usuario de base de datos.
    
9.  ```sudo mysql -u root <<< "GRANT ALL PRIVILEGES ON \`$WORDPRESS_DB_NAME`.* TO '$WORDPRESS_DB_USER'@'$FRONTEND_PRIVATE_IP';"```:` Concede todos los privilegios al nuevo usuario sobre la base de datos especificada.
    
10.  `sudo mysql -u root <<< "FLUSH PRIVILEGES;"`: Recarga los privilegios de **MySQL** para aplicar los cambios.
    
11.  `systemctl restart mysql`: Reinicia el servicio **MySQL** para que los cambios en la configuración y privilegios tengan efecto.

## Contenido archivo "install_lamp_frontend.sh"

1.  `set -ex`: Configura el modo de ejecución del script. `-e` hace que el script se detenga si algún comando devuelve un código de error, y `-x` muestra los comandos ejecutados con sus argumentos y resultados.
    
2.  `apt update`: Actualiza la lista de paquetes disponibles para su instalación.
    
3.  `apt upgrade -y`:  Actualiza el sistema operativo y los paquetes instalados.
    
4.  `apt install apache2 -y`: Instala el servidor web **Apache**.
    
5.  `cp ../conf/000-default.conf /etc/apache2/sites-available/000-default.conf`: Copia el archivo de configuración *000-default.conf* desde el directorio *../conf/* al directorio */etc/apache2/sites-available/*.
    
6.  `sudo apt install php libapache2-mod-php php-mysql -y`: Instala **PHP** y el módulo de **Apache** para **PHP**, así como el soporte de **MySQL** para **PHP**.
    
7.  `systemctl restart apache2`: Reinicia el servicio **Apache** para aplicar los cambios en la configuración.
    
8.  `chown -R www-data:www-data /var/www/html`: Asigna el ownership del directorio */var/www/html/* al usuario y grupo *www-data*.


## Contenido archivo "setup_letsencrypt_https.sh"

1.  `set -ex`: Configura el modo de ejecución del script. `-e` hace que el script se detenga si algún comando devuelve un código de error, y `-x` muestra los comandos ejecutados con sus argumentos y resultados.
    
2.  `apt update`: Actualiza la lista de paquetes disponibles para su instalación.
    
3.  `#apt upgrade -y`: Este comando está comentado (precedido por `#`), por lo que no se ejecutará. Por lo general, se utiliza para actualizar el sistema operativo y los paquetes instalados.
    
4.  `source .env`: Carga las variables de entorno desde el archivo `.env` al script.
    
5.  `snap install core`: Instala el paquete core de **Snap**.
    
6.  `snap refresh core`: Actualiza el paquete core de **Snap** a la última versión disponible.
    
7.  `apt remove certbot`: Desinstala el paquete **certbot**.
    
8.  `snap install --classic certbot`: Instala **certbot** como un paquete **Snap** en modo clásico.
    
9.  `ln -sf /snap/bin/certbot /usr/bin/certbot`: Crea un enlace simbólico para que el ejecutable **certbot** en */snap/bin/* esté disponible en */usr/bin/*.
    
10.  `certbot --apache -m $LE_EMAIL --agree-tos --no-eff-email -d $LE_DOMAIN --non-interactive`: Utiliza **certbot** para obtener y configurar certificados **SSL/TLS** para el dominio especificado utilizando el método de autenticación de **Apache**.

