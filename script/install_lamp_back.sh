#!/bin/bash

#Para mostrar los comandos que son ejecutables con -x, si se pone -ex nos muestra que comando falla
set -ex 

source .env

#Poner sudo cuando se vaya a lanzar el script
apt update

#Actualizar los paquetes del sistema
apt upgrade -y

#Instalamos el servidor web apache y poniendo -y no hace falta escribir nada
apt install apache2 -y

#Instalamos MySQL server
apt install mysql-server -y

#configuramos el config de mysql
sed -i s/127.0.0.1/$BACKEND_MYSQL_PRIVATE_IP/ /etc/mysql/mysql.conf.d/mysqld.cnf

#reiniciamos el servicio
systemctl restart mysql

systemctl daemon-reload

