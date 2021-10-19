#!/bin/bash

# ==========================================================
# Bash script for basic Arch Linux installation (Part 2)
# [Inside new installed system]
#
# Pre-requisites:
# - Part 1 script has landed you inside new system
# 
# Notes:
# - Assumes AMD cpu
# - Sets up systemd-boot as bootloader
#
# Usage (in root):
# - bash install_arch_2.sh
# - Pass -v option for vbox installation
# ==========================================================

USERNAME=smeetrs
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

# set root password for new system
printf '====== CREATING ROOT PASSWORD ====== \n'
printf '=> ADD PASSWORD \n'
passwd
printf '====== DONE ====== \n'
printf '\n'
sleep 5s

# setting up bootloader
printf '====== SETTING UP SYSTEMD-BOOT ====== \n'
printf '=> ENTER ROOT PARTITION PATH [!] \n'
read ROOT_PARTITION
bootctl install
# loader.conf file
printf 'default arch-lts.conf\n' | tee /boot/loader/loader.conf > /dev/null
printf 'timeout 5\n' | tee -a /boot/loader/loader.conf > /dev/null
printf 'console-mode max\n' | tee -a /boot/loader/loader.conf > /dev/null
printf 'editor no\n' | tee -a /boot/loader/loader.conf > /dev/null
printf '=> LOADER.CONF CONTENTS: \n'
cat /boot/loader/loader.conf
sleep 15s
# arch-lts.conf file
printf 'title Arch Linux LTS\n' | tee /boot/loader/entries/arch-lts.conf > /dev/null
printf 'linux /vmlinuz-linux-lts\n' | tee -a /boot/loader/entries/arch-lts.conf > /dev/null
printf 'initrd /amd-ucode.img\n' | tee -a /boot/loader/entries/arch-lts.conf > /dev/null
printf 'initrd /initramfs-linux-lts.img\n' | tee -a /boot/loader/entries/arch-lts.conf > /dev/null
printf "options root=$ROOT_PARTITION rw\n" | tee -a /boot/loader/entries/arch-lts.conf > /dev/null
printf '=> ARCH-LTS.CONF CONTENTS: \n'
cat /boot/loader/entries/arch-lts.conf
sleep 15s
# arch.conf file
printf 'title Arch Linux\n' | tee /boot/loader/entries/arch.conf > /dev/null
printf 'linux /vmlinuz-linux\n' | tee -a /boot/loader/entries/arch.conf > /dev/null
printf 'initrd /amd-ucode.img\n' | tee -a /boot/loader/entries/arch.conf > /dev/null
printf 'initrd /initramfs-linux.img\n' | tee -a /boot/loader/entries/arch.conf > /dev/null
printf "options root=$ROOT_PARTITION rw\n" | tee -a /boot/loader/entries/arch.conf > /dev/null
printf '=> ARCH.CONF CONTENTS: \n'
cat /boot/loader/entries/arch.conf
sleep 15s
printf '====== DONE ====== \n'
printf '\n'
sleep 5s

# create user account
printf '====== CREATING NEW USER ACCOUNT ====== \n'
useradd -m -G wheel $USERNAME
printf '=> ADD PASSWORD: \n'
passwd $USERNAME
printf '=> OPENING VISUDO. UNCOMMENT WHEEL LINE. \n'
sleep 5s
EDITOR=vim visudo
printf '====== DONE ====== \n'
printf '\n'
sleep 5s

# finish installation
printf '====== FINISHED INSTALLATION. MOVE SCRIPTS FOLDER TO HOME. EXIT CHROOT. ====== \n'
sleep 5s
