#!/bin/bash
IPADD=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/')
NCVERSION=12.0.4
NCDB="ncdb"
NCUSER="ncuser"
NCUSERPASS="$(openssl rand -base64 12)"
clear
#----------------------------- User Input --------------------------------------------------
echo "Please enter root user MySQL password... (Password type prompt is hidden)"
read -s rootpasswd
echo "Entering custom parameters..."
read -e -p "Desired database name for NextCloud... default is [$NCDB]: " -i "$NCDB" NCDB
read -e -p "Desired user name for NextCloud... default is [$NCUSER]: " -i "$NCUSER" NCUSER
read -e -p "Desired password for NextCloud user... default is [$NCUSERPASS]: " -i "$NCUSERPASS" NCUSERPASS
#-------------------------------------------------------------------------------------------
clear
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install php-gd php-json php-mysql php-curl php-intl php-mcrypt php-imagick php-zip php-dom php7.0-xml php-mbstring wget unzip -y
sudo apt-get install apache2 mariadb-server -y
sudo apt-get install phpmyadmin -y
sudo cp php.ini /etc/php/7.0/apache2/
sudo systemctl restart apache2
clear
echo "" &>> ./NextCloudLog.log
echo "Database name chosen is: $NCDB" &>> ./NextCloudLog.log
echo "Database user chosen is: $NCUSER" &>> ./NextCloudLog.log
echo "Database password chosen is: $NCUSERPASS" &>> ./NextCloudLog.log
mysql -uroot -p${rootpasswd} -e "DROP DATABASE IF EXISTS ${NCDB};"
mysql -uroot -p${rootpasswd} -e "DROP USER IF EXISTS ${NCUSER}@localhost ;"
mysql -uroot -p${rootpasswd} -e "FLUSH PRIVILEGES;"
mysql -uroot -p${rootpasswd} -e "CREATE DATABASE ${NCDB} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
mysql -uroot -p${rootpasswd} -e "CREATE USER ${NCUSER}@localhost IDENTIFIED BY '${NCUSERPASS}';"
mysql -uroot -p${rootpasswd} -e "GRANT ALL PRIVILEGES ON ${NCDB}.* TO '${NCUSER}'@'localhost' IDENTIFIED BY '${NCUSERPASS}';"
mysql -uroot -p${rootpasswd} -e "FLUSH PRIVILEGES;"
echo "MYSQL finished..."
echo ""
echo "Downloading NextCloud Binaries..."
if [ -f "nextcloud-$NCVERSION.zip" ]
then
	if [ -d "/var/www/html/nextcloud/" ]
		then
		sudo mv /var/www/html/nextcloud/ /var/www/html/nextcloud.old/
	fi
else
	wget https://download.nextcloud.com/server/releases/nextcloud-$NCVERSION.zip
	echo "Finished."
	echo "Unzipping NextCloud Binaries..."
	unzip nextcloud-$NCVERSION.zip
fi
sudo cp -r nextcloud/ /var/www/html/
sudo chown -R www-data:www-data /var/www/html/nextcloud/
if [ -f "/etc/apache2/sites-available/nextcloud.conf" ]
then
	echo "NextCloud conf already exists. Moving on."
else
	sudo cat nexcloud.conf >> /etc/apache2/sites-available/nextcloud.conf
fi
clear
sudo chmod 755 /etc/apache2/sites-available/nextcloud.conf
sudo ln -s /etc/apache2/sites-available/nextcloud.conf /etc/apache2/sites-enabled/nextcloud.conf
sudo chmod -R 755 /var/www/html/nextcloud/
sudo a2enmod rewrite
sudo a2enmod headers
sudo a2enmod env
sudo a2enmod dir
sudo a2enmod mime
sudo systemctl restart apache2
echo "Open up your web browser and navigate to URL: http://$IPADD/nextcloud." 
echo "Use MySQL database $NCDB, with user $NCUSER password $NCUSERPASS"
exit 0
