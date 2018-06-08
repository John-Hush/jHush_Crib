sudo a2dismod php7.0;
sudo a2enmod php5;
sudo service apache2 restart

sudo a2dismod proxy_fcgi proxy;
sudo service apache2 restart
sudo update-alternatives --set php /usr/bin/php5
