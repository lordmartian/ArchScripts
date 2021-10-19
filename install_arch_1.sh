#!/bin/bash

# ==========================================================
# Bash script for basic Arch Linux installation (Part 1)
# [Inside installation media]
#
# Pre-requisites: 
# - Working internet connection
# 
# Notes:
# - Creates EXT4 file system for root
# - Assumes AMD cpu
# - Creates swap partition
#
# Usage (in root):
# - bash install_arch_1.sh
# - Pass -v option for vbox installation
# ==========================================================

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

# check internet connectivity
printf '====== CHECKING INTERNET CONNECTION ====== \n'
ping -c 5 archlinux.org
printf '====== DONE ====== \n'
printf '\n'
sleep 5s

# partition the disk
printf '====== PARTITIONING THE DISK ====== \n'
fdisk -l
printf '=> ENTER PATH OF DISK TO BE PARTITIONED [!] \n'
read DISK
printf '=> STARTING FDISK UTILITY. CREATE EFI, SWAP AND ROOT PARTITIONS. \n'
sleep 5s
fdisk $DISK
printf '====== DONE ====== \n'
printf '\n'
sleep 5s

# format the partitions
printf '====== FORMATTING THE PARTITIONS ====== \n'
printf '=> ENTER EFI PARTITION PATH [!] \n'
read EFI_PARTITION
printf '=> ENTER SWAP PARTITION PATH [!] \n'
read SWAP_PARTITION
printf '=> ENTER ROOT PARTITION PATH [!] \n'
read ROOT_PARTITION
mkfs.ext4 $ROOT_PARTITION
mount $ROOT_PARTITION /mnt
mkfs.fat -F32 $EFI_PARTITION
mkdir /mnt/boot
mount $EFI_PARTITION /mnt/boot
mkswap $SWAP_PARTITION
swapon $SWAP_PARTITION
printf '====== DONE ====== \n'
printf '\n'
sleep 5s

# install base, linux and other essential packages
printf '====== INSTALLING BASE SYSTEM, LINUX AND ESSENTIAL PKGS ====== \n'
pacstrap /mnt base linux linux-lts linux-headers linux-lts-headers linux-firmware
pacstrap /mnt amd-ucode sudo vim iwd ntfs-3g git base-devel
if $VBOX_INSTALL
then
    pacstrap /mnt virtualbox-guest-utils
fi
printf '====== DONE ====== \n'
printf '\n'
sleep 5s

# generate fstab file
printf '====== GENERATING FSTAB FILE ====== \n'
genfstab -U /mnt | tee -a /mnt/etc/fstab > /dev/null
printf '=> FSTAB CONTENTS: \n'
cat /mnt/etc/fstab
sleep 15s
printf '====== DONE ====== \n'
printf '\n'
sleep 5s

# chroot into new system
printf '====== CHANGING ROOT TO NEW INSTALLED SYSTEM ====== \n'
sleep 5s
arch-chroot /mnt
printf '====== DONE ====== \n'
printf '\n'
sleep 5s

# shut down
printf '====== INSTALLATION COMPLETE. SHUTTING DOWN. REMOVE INSTALLATION DRIVE. ====== \n'
umount -R /mnt
sleep 5s
shutdown now
