#!/bin/bash
IP_ADDRESS="127.0.0.1"

APACHE2_DIR="/etc/apache2"

UID_ROOT=0

USER=www-data

MYSQL_PASS="root"


WEB_USER=www-data
LOCAL_USER=hog



if [ $# -eq 3 ]; then
    if [ "$1" != "delete" ]; then
        SITE_NAME=$1
	if [ -d "/var/www/$SITE_NAME" ]; then
	    rm -rf /var/www/$SITE_NAME
	fi
        mkdir /var/www/$SITE_NAME
	chown $LOCAL_USER:$LOCAL_USER /var/www/$SITE_NAME
	chmod -R 755 /var/www/$SITE_NAME
        hostConf="
<VirtualHost *:80>
        ServerName $SITE_NAME.loc
        ServerAlias www.$SITE_NAME.loc
        ServerAdmin webmaster@$SITE_NAME.loc


        DocumentRoot /var/www/$SITE_NAME

        ErrorLog /var/log/apache2/error.log
        DirectoryIndex index.php index.html
	 <Directory />

                Options FollowSymLinks

                AllowOverride All 

        </Directory>


	<Directory /var/www/$SITE_NAME>

        Options Indexes FollowSymLinks MultiViews
        AllowOverride All 
        Order allow,deny
        allow from all
</Directory>

    
    
    
</VirtualHost>
        "
	if test -f "${APACHE2_DIR}/sites-available/${SITE_NAME}.conf"; then rm ${APACHE2_DIR}/sites-available/${SITE_NAME}.conf ;fi
        touch ${APACHE2_DIR}/sites-available/${SITE_NAME}.conf
	echo "$hostConf" > ${APACHE2_DIR}/sites-available/${SITE_NAME}.conf
	echo "127.0.0.1 ${SITE_NAME}.loc" >> /etc/hosts
	cd /var/www/$SITE_NAME
	sudo -u $LOCAL_USER sh -c "cd /var/www/$SITE_NAME;  git init; git remote add origin $2; git pull origin $3; cp sites/default/default.settings.php sites/default/settings.php"
	dbConf="
	 \$databases = array (
	  'default' => 
	  array (
	    'default' => 
	    array (
	      'database' => '${SITE_NAME}',
	      'username' => 'root',
	      'password' => '${MYSQL_PASS}',
	      'host' => 'localhost',
	      'port' => '',
	      'driver' => 'mysql',
	      'prefix' => '',
	    ),
	  ),
	);
	"
	echo "$dbConf" >> sites/default/settings.php
	mkdir sites/default/files
	mkdir sites/default/files/tmp
	chmod -R 777 sites/default/files/tmp
	function is_running(){
	        local result="$(ps -A|grep $1|wc -l)"
	    if [[ $result -eq 0 ]]; then
	     return 1
	    else
	 return 0
	    fi
	}

    echo -n "Check MySQL status: "
    if(is_running mysqld)then
        echo "OK [Running]";
        DB_NAME=$1
	mysql -uroot -p${MYSQL_PASS} --execute="DROP DATABASE IF EXISTS ${SITE_NAME};"
        mysql -uroot -p${MYSQL_PASS} --execute="create database ${SITE_NAME};"
	mysql -u root -p${MYSQL_PASS} ${SITE_NAME} < ${SITE_NAME}.sql
	sudo -u $LOCAL_USER sh -c "cd /var/www/$SITE_NAME; git submodule update --init"
    else
        echo "Error: need start mysql daemon!"
        exit
    fi

	
	
	a2ensite ${SITE_NAME}

	


        service apache2 reload
    fi
fi;

#display information
echo "*****************************************"
echo "* Profit!"
echo "*****************************************"
