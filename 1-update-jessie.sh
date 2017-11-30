#!/bin/bash

# update raspbian
sudo apt-get update && sudo apt-get -y upgrade

########################################################################################
# Update Firmware - Making sure that your Raspbian firmware is the latest version.
########################################################################################
sudo apt-get -y install rpi-update
sudo rpi-update
sudo reboot
