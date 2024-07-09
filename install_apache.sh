#!/bin/bash
 
# Actualiza los paquetes e instala Apache
sudo yum update -y
sudo yum install -y httpd
 
# Inicia Apache y habilita para que inicie en cada reinicio del sistema
sudo systemctl start httpd
sudo systemctl enable httpd
 
# Crea una página web de ejemplo
echo "<html><h1>Hola desde Terraform!</h1></html>" | sudo tee /var/www/html/index.html

cd /var/www/html
sudo yum install php php-cli php-json php-mbstring -y
sudo php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
sudo php composer-setup.php
sudo php -r "unlink('composer-setup.php');"
sudo php composer.phar require aws/aws-sdk-php
sudo service httpd restart