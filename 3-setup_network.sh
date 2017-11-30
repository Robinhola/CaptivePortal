#!/bin/bash

########################################################################################
# Set-up other network requirements
########################################################################################
sudo apt-get -y install iw bridge-utils dnsmasq iptables
# disable dnsmasq?
sudo sed -i 's/netdev:x:108:pi/netdev:x:108:pi,www-data/g' /etc/group
# Copy some config files into place
sudo cp /home/pi/Raspberry-Wifi-Router/defconfig/interfaces /etc/network/interfaces
sudo chgrp www-data /etc/network/interfaces
sudo chmod g+w /etc/network/interfaces

sudo cp /home/pi/Raspberry-Wifi-Router/defconfig/dhcpcd.conf /etc/dhcpcd.conf

sudo cp /home/pi/Raspberry-Wifi-Router/defconfig/wr_commands /etc/sudoers.d/wr_commands
sudo chmod 644 /etc/sudoers.d/wr_commands

sudo cp /home/pi/Raspberry-Wifi-Router/defconfig/ntp.conf /etc/ntp.conf
sudo chgrp www-data /etc/ntp.conf
sudo chmod g+w /etc/ntp.conf

sudo cp /home/pi/Raspberry-Wifi-Router/defconfig/dnsmasq.conf /etc/dnsmasq.conf
sudo chgrp www-data /etc/dnsmasq.conf
sudo chmod g+w /etc/dnsmasq.conf

# modify some shit in existing config files
sudo chgrp www-data /etc/dhcp/dhclient.conf
sudo chmod g+w /etc/dhcp/dhclient.conf

sudo chgrp www-data /etc/timezone
sudo chmod g+w /etc/timezone

sudo cp /home/pi/Raspberry-Wifi-Router/defconfig/routersettings.ini /home/pi/Raspberry-Wifi-Router/www/routersettings.ini

sudo mount -o remount rw /boot
sudo cp /home/pi/Raspberry-Wifi-Router/defconfig/cmdline.txt /boot/cmdline.txt

# disable ntp in default config
sudo systemctl stop ntp
sudo systemctl disable ntp

# fix a bug in which dnsmasq overwrites our resolv.conf file's dns servers
echo "DNSMASQ_EXCEPT=lo" | sudo tee -a /etc/default/dnsmasq

# set security rights on /etc/rc.local
sudo chgrp www-data /etc/rc.local
sudo chmod g+w /etc/rc.local

# create empty /etc/resolv.conf.head file for dns override
sudo touch /etc/resolv.conf.head
sudo chgrp www-data /etc/resolv.conf.head
sudo chmod g+w /etc/resolv.conf.head

# set permissions on temp folder for router
sudo chgrp -R www-data /home/pi/Raspberry-Wifi-Router/www/temp
sudo chmod -R 775 /home/pi/Raspberry-Wifi-Router/www/temp

sudo reboot
