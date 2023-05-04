#!/bin/bash

#variable
repo="devops-static-web"
USERID=$(id -u)

#validar que el script corra con el usuario root
if [ "${USERID}" -ne 0 ]; then
    echo -e "Debe correr con usuario ROOT"
    exit 
fi

#Actualizando sistema operativo
sudo apt-get update
echo -e "Sistema operativo actualizado"

#validar si git esta instalado
if dpkg -s git >/dev/null 2>&1; then
    echo -e "\n\e[96mAGit se encuentra instalado \033[0m\n"

else    
    apt install -y git
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

if [ -d "$repo" ]; then
    echo -e "la carpeta $repo existe"
    rm -rf $repo
fi

echo -e "Instalando pagina web"
sleep 1
git clone -b devops-mariobros https://github.com/roxsross/$repo.git
cp -r $repo/* /var/www/html

echo -e "Despliegue finalizado"
echo -e "==============================="