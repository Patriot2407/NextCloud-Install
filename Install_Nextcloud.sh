#!/bin/bash
#---- executable --------
IPADD=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/')
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install php-gd php-json php-mysql php-curl php-intl php-mcrypt php-imagick php-zip php-dom php7.0-xml php-mbstring wget unzip -y
sudo apt-get install apache2 mariadb-server -y
sudo apt-get install phpmyadmin -y
sudo cp php.ini /etc/php/7.0/apache2/
sudo systemctl restart apache2
clear
echo "Please run this snippet inside mysql after you have typed in the password highlight this snippet and right click, it will automatically paste and run inside this script"
echo "Or just hit enter to make it later. It is not necessary to install NextCloud."
echo ""
echo "
CREATE DATABASE ncdb;
CREATE USER 'ncuser'@'localhost' IDENTIFIED BY 'ubuntu!!1234567';
GRANT ALL PRIVILEGES ON ncdb.* TO 'ncuser'@'localhost' IDENTIFIED BY 'ubuntu!!1234567';
FLUSH PRIVILEGES;
\q
"
echo ""
mysql -u root -p
wget https://download.nextcloud.com/server/releases/nextcloud-12.0.4.zip
unzip nextcloud*
sudo cp -r nextcloud/ /var/www/html/
sudo chown -R www-data:www-data /var/www/html/nextcloud/
sudo echo "
Alias /nextcloud "/var/www/html/nextcloud/"

<Directory /var/www/html/nextcloud/>
  Options +FollowSymlinks
  AllowOverride All

 <IfModule mod_dav.c>
  Dav off
 </IfModule>

 SetEnv HOME /var/www/html/nextcloud
 SetEnv HTTP_HOME /var/www/html/nextcloud

</Directory>
" >> /etc/apache2/sites-available/nextcloud.conf
clear
sudo ln -s /etc/apache2/sites-available/nextcloud.conf /etc/apache2/sites-enabled/nextcloud.conf
sudo a2enmod rewrite
sudo a2enmod headers
sudo a2enmod env
sudo a2enmod dir
sudo a2enmod mime
sudo systemctl restart apache2
echo "Open up your web browser and navigate to URL: http://$IPADD/nextcloud. Use MySQL database, with user ncuser password ubuntu!!1234567"
exit 0
