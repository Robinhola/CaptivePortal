#!/bin/bash

########################################################################################
# Set-up mysql
########################################################################################
sudo apt-get -y install debhelper
echo 'mysql-server mysql-server/root_password password raspberry' | debconf-set-selections
echo 'mysql-server mysql-server/root_password_again password raspberry' | debconf-set-selections
sudo apt-get -y install mysql-server php5-mysql 

########################################################################################
# Set-up freeradius
########################################################################################
sudo apt-get -y install freeradius freeradius-mysql
echo 'create database radius;' | mysql --host=localhost --user=root --password=raspberry
sudo cat /etc/freeradius/sql/mysql/schema.sql | mysql --host=localhost --user=root --password=raspberry radius
sudo cat /etc/freeradius/sql/mysql/admin.sql | mysql --host=localhost --user=root --password=raspberry radius
echo "insert into radcheck (username, attribute, op, value) values ('user', 'Cleartext-Password', ':=', 'password');" | mysql --host=localhost --user=root --password=raspberry radius
sudo sed -i 's/#[[:space:]]$INCLUDE sql.conf/$INCLUDE sql.conf/g' /etc/freeradius/radiusd.conf
sudo cp /home/pi/Raspberry-Wifi-Router/defconfig/sites-available-default /etc/freeradius/sites-available/default
sudo systemctl restart freeradius.service

########################################################################################
# Login Database - Creating a login database and storing our user passwords
########################################################################################
echo 'create database login;' | mysql --host=localhost --user=root --password=raspberry
echo " \
CREATE TABLE users ( \
  id int(11) NOT NULL auto_increment, \
  username varchar(64) NOT NULL default '', \
  password varchar(64) NOT NULL default '', \
  PRIMARY KEY  (id) \
) ;" | mysql --host=localhost --user=root --password=raspberry --database login

echo " \
CREATE TABLE openvpnusers ( \
  id int(11) NOT NULL auto_increment, \
  openvpnservername varchar(64) NOT NULL default '', \
  username varchar(64) NOT NULL default '', \
  firstname varchar(64) NOT NULL default '', \
  lastname varchar(64) NOT NULL default '', \
  country varchar(2) NOT NULL default '', \
  province varchar(64) NOT NULL default '', \
  city varchar(64) NOT NULL default '', \
  organisation varchar(64) NOT NULL default '', \
  email varchar(64) NOT NULL default '', \
  packageurl varchar(64) NOT NULL default '', \
  PRIMARY KEY  (id) \
) ;" | mysql --host=localhost --user=root --password=raspberry --database login

echo "INSERT INTO users (username,password) VALUES('admin','raspberry');" | \
mysql --host=localhost --user=root --password=raspberry --database login

########################################################################################
# OpenVPN - Installing OpenVPN Requirements
########################################################################################
sudo apt-get -y install openvpn
sudo apt-get -y install zip
mkdir /home/pi/Raspberry-Wifi-Router/www/temp
mkdir /home/pi/Raspberry-Wifi-Router/www/temp/OpenVPN_ClientPackages
sudo systemctl disable openvpn.service
########################################################################################
# Reconfigure networking
########################################################################################
sudo iw wlan0 set 4addr on # for bridging the wlan interface


sudo reboot


