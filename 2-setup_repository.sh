#!/bin/bash

########################################################################################
# Set-up git and clone our repository into place.
########################################################################################
# Install git and clone our repository
sudo apt-get -y install git-core
git clone https://github.com/ronnyvdbr/Raspberry-Wifi-Router.git /home/pi/Raspberry-Wifi-Router

########################################################################################
# Set-up nginx with php support and enable our Raspberry-Wifi-Router website.
########################################################################################
# Install nginx with php support.
sudo apt-get -y install nginx php5-fpm
# Disable the default nginx website.
sudo rm /etc/nginx/sites-enabled/default
# Copy our siteconf into place
sudo cp /home/pi/Raspberry-Wifi-Router/defconfig/RaspberryWifiRouter.Nginx.Siteconf /etc/nginx/sites-available/RaspberryWifiRouter.Nginx.Siteconf
# Lets enable our website
sudo ln -s /etc/nginx/sites-available/RaspberryWifiRouter.Nginx.Siteconf /etc/nginx/sites-enabled/RaspberryWifiRouter.Nginx.Siteconf
# Disable output buffering in php.
sudo sed -i 's/output_buffering = 4096/;output_buffering = 4096/g' /etc/php5/fpm/php.ini
# Set permissions for our router's config file
sudo chgrp www-data /home/pi/Raspberry-Wifi-Router/www/routersettings.ini
sudo chmod g+w /home/pi/Raspberry-Wifi-Router/www/routersettings.ini
# enable file uploads
sudo sed -i 's/;file_uploads = On/file_uploads = On/g' /etc/php5/fpm/php.ini

########################################################################################
# Set-up hostapd.
########################################################################################
# Install some required libraries for hostapd.
sudo apt-get install -y libnl-3-dev libnl-genl-3-dev libssl-dev
# Download and extract the hostapd source files.
wget -O /home/pi/hostapd-2.5.tar.gz http://w1.fi/releases/hostapd-2.5.tar.gz
tar -zxvf /home/pi/hostapd-2.5.tar.gz -C /home/pi
# Prepare for compiling hostapd, create .config and modify some variables.
cp /home/pi/hostapd-2.5/hostapd/defconfig /home/pi/hostapd-2.5/hostapd/.config
sed -i 's/#CONFIG_LIBNL32=y/CONFIG_LIBNL32=y/g' /home/pi/hostapd-2.5/hostapd/.config
sed -i 's/#CFLAGS += -I$<path to libnl include files>/CFLAGS += -I\/usr\/include\/libnl3/g' /home/pi/hostapd-2.5/hostapd/.config
sed -i 's/#LIBS += -L$<path to libnl library files>/LIBS += -L\/lib\/arm-linux-gnueabihf/g' /home/pi/hostapd-2.5/hostapd/.config
sed -i 's/#CONFIG_IEEE80211N=y/CONFIG_IEEE80211N=y/g' /home/pi/hostapd-2.5/hostapd/.config
# Create some links to fix some bugs while compiling
sudo ln -s /lib/arm-linux-gnueabihf/libnl-genl-3.so.200.5.2 /lib/arm-linux-gnueabihf/libnl-genl.so
sudo ln -s /lib/arm-linux-gnueabihf/libnl-3.so.200.5.2 /lib/arm-linux-gnueabihf/libnl.so
# Compile hostapd.
make -C /home/pi/hostapd-2.5/hostapd
# Ok, now install hostapd.
sudo make install -C /home/pi/hostapd-2.5/hostapd
# Create config folder and copy our default hostapd config file into place.
sudo mkdir /etc/hostapd
sudo cp /home/pi/Raspberry-Wifi-Router/defconfig/hostapd.conf /etc/hostapd/hostapd.conf
sudo chgrp www-data /etc/hostapd/hostapd.conf
sudo chmod g+w /etc/hostapd/hostapd.conf
# Set permissions on config file so our router can modify it.
sudo chgrp www-data /etc/hostapd/hostapd.conf
sudo chmod g+w /etc/hostapd/hostapd.conf
# Copy our own systemd service unit into place for starting hostapd during boot time and load it in systemd.
sudo cp /home/pi/Raspberry-Wifi-Router/defconfig/hostapd.service /etc/systemd/system/hostapd.service
sudo chgrp www-data /etc/systemd/system/hostapd.service
sudo chmod g+w /etc/systemd/system/hostapd.service

sudo systemctl daemon-reload
sudo systemctl enable hostapd.service

sudo reboot




