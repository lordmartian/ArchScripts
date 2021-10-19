#!/bin/bash

# ====================================================================
# Bash script to setup a fresh Arch Linux installation (Part 1)
# [No internet]
#
# Pre-requisites:
# - User account with sudo permission
#
# Notes:
# - Sets up systemd-networkd/resolved for network management
# - Timezone and locale as per India
#
# Usage (in user account, using non-lts kernel):
# - bash setup_arch_1.sh
# - Pass -v option for vbox installation
# ====================================================================

HOST_NAME=MyArch
VBOX_INSTALL=false

while getopts ":v" opt
do
    case $opt in
        v) VBOX_INSTALL=true;;
        \?) printf "Invalid Option: -$OPTARG \n";;
    esac
done
printf '\n'

if $VBOX_INSTALL
then
    printf '=> VBOX INSTALLATION \n'
else
    printf '=> MACHINE INSTALLATION \n'
fi
printf '\n'

# change to home directory
cd ~

# enable vbox service
if $VBOX_INSTALL
then
    printf '====== ENABLING VBOX SERVICE ====== \n'
    sudo systemctl enable vboxservice
    printf '====== DONE ====== \n'
    printf '\n'
    sleep 5s
fi

# set up network
printf '====== SETTING UP NETWORK ====== \n'
# wired
ETHER_INTERFACE=$(ls /sys/class/net | grep '^e')
printf '[Match]\n' | sudo tee /etc/systemd/network/20-wired.network > /dev/null
printf "Name=$ETHER_INTERFACE\n" | sudo tee -a /etc/systemd/network/20-wired.network > /dev/null
printf '\n' | sudo tee -a /etc/systemd/network/20-wired.network > /dev/null
printf '[Network]\n' | sudo tee -a /etc/systemd/network/20-wired.network > /dev/null
printf 'DHCP=yes\n' | sudo tee -a /etc/systemd/network/20-wired.network > /dev/null
printf '\n' | sudo tee -a /etc/systemd/network/20-wired.network > /dev/null
printf '=> 20-WIRED.NETWORK CONTENTS: \n'
cat /etc/systemd/network/20-wired.network
sleep 15s
# wireless
WIFI_INTERFACE=$(ls /sys/class/net | grep '^w')
printf '[Match]\n' | sudo tee /etc/systemd/network/25-wireless.network > /dev/null
printf "Name=$WIFI_INTERFACE\n" | sudo tee -a /etc/systemd/network/25-wireless.network > /dev/null
printf '\n' | sudo tee -a /etc/systemd/network/25-wireless.network > /dev/null
printf '[Network]\n' | sudo tee -a /etc/systemd/network/25-wireless.network > /dev/null
printf 'DHCP=yes\n' | sudo tee -a /etc/systemd/network/25-wireless.network > /dev/null
printf '\n' | sudo tee -a /etc/systemd/network/25-wireless.network > /dev/null
printf '=> 25-WIRELESS.NETWORK CONTENTS: \n'
cat /etc/systemd/network/25-wireless.network
sleep 15s
sudo rm -f /etc/resolv.conf
sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
sudo systemctl enable systemd-networkd
sudo systemctl enable systemd-resolved
sudo systemctl enable iwd
printf '====== DONE ====== \n'
printf '\n'
sleep 5s

# set up time-date, locale, hostname
printf '====== SETTING UP TIME-DATE, LOCALE AND HOSTNAME ====== \n'
sudo timedatectl set-timezone Asia/Kolkata
sudo localectl set-locale en_IN.UTF-8
sudo locale-gen
sudo hostnamectl set-hostname $HOST_NAME
printf '127.0.0.1\tlocalhost\n' | sudo tee -a /etc/hosts > /dev/null
printf '::1\tlocalhost\n' | sudo tee -a /etc/hosts > /dev/null
printf '=> /ETC/HOSTS CONTENTS: \n'
cat /etc/hosts
sleep 15s
printf '====== DONE ====== \n'
printf '\n'
sleep 5s

# create dirs
printf '====== CREATING EMPTY REQUIRED DIRS ====== \n'
sudo mkdir -p /mnt/Windows
sudo mkdir -p /mnt/Data
printf '====== DONE ====== \n'
printf '\n'
sleep 5s

# set up git
printf '====== SETTING UP GIT ====== \n'
git config --global user.email 'smeetrs@gmail.com'
git config --global user.name 'lordmartian'
printf '====== DONE ====== \n'
printf '\n'
sleep 5s

printf '====== SETUP COMPLETE. REBOOTING. ====== \n'
sleep 5s
sudo reboot
