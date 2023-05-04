#!bin/bash

#variables
USERID=$(id -u)
REPO="The-DevOps-Journey-101"

#comprobación usuario root
if [ "${USERID}" -ne 0 ]; then
    echo -e "\033[33mError: correr con usuario ROOT\033[0m"
exit
fi

echo "============================================================"

#actualizar sistema operativo
sudo apt-get update

echo -e "\e[92mEl Servidor se encuentra Actualizado ...\033[0m\n"

#validar si git esta instalado
if dpkg -s git >/dev/null 2>&1; then
    echo -e "\n\e[96mAGit se encuentra instalado \033[0m\n"

else    
    apt install -y git
fi

#Base de datos
#validar si mariadb esta instalado
if dpkg -s mariadb-server > /dev/null 2>&1; then
    echo -e "\n\e[96mMariaDB se encuentra instalado \033[0m\n"

#instalando mariaDB
else
    echo -e "\n\e[92mInstalando mariadb ...\033[0m\n"
    apt install -y mariadb-server
    systemctl start mariadb
    systemctl enable mariadb
    sleep 1

#creando base de datos ecomdb
mysql -e "
    CREATE DATABASE ecomdb;
    CREATE USER 'ecomuser'@'localhost' IDENTIFIED BY 'ecompassword';
    GRANT ALL PRIVILEGES ON *.* TO 'ecomuser'@'localhost';
    FLUSH PRIVILEGES;"

#creando script de insersion de datos en tablas de BD ecomdb
cat > db-script.sql <<EOF
USE ecomdb;
CREATE TABLE products (id mediumint(8) unsigned NOT NULL auto_increment,Name varchar(255) default NULL,Price varchar(255) default NULL, ImageUrl varchar(255) default NULL,PRIMARY KEY (id)) AUTO_INCREMENT=1;
INSERT INTO products (Name,Price,ImageUrl) VALUES ("Laptop","100","c-1.png"),("Drone","200","c-2.png"),("VR","300","c-3.png"),("Tablet","50","c-5.png"),("Watch","90","c-6.png"),("Phone Covers","20","c-7.png"),("Phone","80","c-8.png"),("Laptop","150","c-4.png");
EOF

#importando script mysql
echo -e "\n\033[33m Script SQL Generado\033[0m\n"
mysql < db-script.sql
echo -e "\n\033[33m Script SQL Ejecutandose\033[0m\n"
fi

#verificar si apache esta instalado
if dpkg -s apache2 > /dev/null 2>&1; then
    echo -e "\n\e[96mApache esta instalado \033[0m\n"
else
    echo -e "\n\e[92mInstalando Apache2 ...\033[0m\n"
    apt install -y apache2
    apt install -y php libapache2-mod-php php-mysql
    systemctl start apache2
    systemctl enable apache2
    mv /var/www/html/index.html /var/www/html/index.html.bkp
fi

#validar si el repositorio existe
if [-d "$REPO"]; then
    echo -e "\n\e[96mLa carpeta $REPO existe \033[0m\n"
    rm -rf $REPO
fi

#Instalando web
echo -e "\n\e[92mInstalando Pagina web ...\033[0m\n"
sleep 1
git clone https://github.com/roxsross/$REPO.git
cp -r $REPO/CLASE-02/lamp-app-ecommerce/* /var/www/html
sed -i 's/172.20.1.101/localhost/g' /var/www/html/index.php
echo "Deploy Finalizado"
echo "==================================="

sleep 1

#recargar Apache
systemctl reload apache2