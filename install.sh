#!/bin/bash

# ==========================================================
# Bash script for Arch Linux installation
#
# Pre-requisites:
# - Working internet connection
#
# Notes:
# - Creates EXT4 file system for root
# - Assumes AMD cpu
# - Creates swap file instead of partition
#
# Usage (as root):
# - bash install.sh
# - Pass -v option for vbox installation
# ==========================================================

NOCOLOR="\033[0m"
BRED="\033[1;31m"
BGREEN="\033[1;32m"
BYELLOW="\033[1;33m"
BBLUE="\033[1;34m"
BPURPLE="\033[1;35m"
BCYAN="\033[1;36m"

# parse arguments
VBOX_INSTALL=false
while getopts ":v" OPT
do
    case $OPT in
        v) VBOX_INSTALL=true;;
        \?) printf "Invalid Option: -$OPTARG \n";;
    esac
done
printf "\n"

# notify vbox or machine installation
if [ "$VBOX_INSTALL" = "true" ]
then
    printf "$BBLUE => VBOX INSTALLATION $NOCOLOR\n"
else
    printf "$BBLUE => MACHINE INSTALLATION $NOCOLOR\n"
fi
printf "\n"

# change to home directory
cd ~

# check internet connectivity
printf "$BYELLOW ====== CHECKING INTERNET CONNECTION ====== $NOCOLOR\n"
ping -c 5 archlinux.org
printf "$BGREEN ====== DONE ====== $NOCOLOR\n"
printf "\n"
sleep 5s

# sync live usb time
printf "$BYELLOW ====== SYNCING TIME-DATE ====== $NOCOLOR\n"
timedatectl set-ntp true
printf "$BGREEN ====== DONE ====== $NOCOLOR\n"
printf "\n"
sleep 5s

# create partition, format them and mount
printf "$BYELLOW ====== DISK PARTITIONING, FORMATTING AND MOUNTING ====== $NOCOLOR\n"
fdisk -l
printf "$BBLUE => ENTER PATH OF DISK TO BE PARTITIONED $BRED [!] $NOCOLOR\n"
read DISK
if [ "$VBOX_INSTALL" = "true" ]
then
    printf "$BBLUE => STARTING FDISK UTILITY. CREATE EFI AND ROOT PARTITIONS. $NOCOLOR\n"
else
    printf "$BBLUE => STARTING FDISK UTILITY. CREATE ROOT PARTITION. $NOCOLOR\n"
fi
sleep 5s
fdisk $DISK
printf "$BBLUE => ENTER EFI PARTITION PATH $BRED [!] $NOCOLOR\n"
read EFI_PARTITION
printf "$BBLUE => ENTER ROOT PARTITION PATH $BRED [!] $NOCOLOR\n"
read ROOT_PARTITION
mkfs.ext4 $ROOT_PARTITION
mount $ROOT_PARTITION /mnt
if [ "$VBOX_INSTALL" = "true" ]
then
    mkfs.fat -F 32 $EFI_PARTITION
fi
mkdir -p /mnt/boot/efi
mount $EFI_PARTITION /mnt/boot/efi
printf "$BGREEN ====== DONE ====== $NOCOLOR\n"
printf "\n"
sleep 5s

# create swap file
printf "$BYELLOW ====== CREATING SWAP FILE ====== $NOCOLOR\n"
printf "$BBLUE => ENTER DESIRED SWAP SIZE IN MB $NOCOLOR\n"
read SWAP_SIZE
dd if=/dev/zero of=/mnt/swapfile bs=1M count=$SWAP_SIZE status=progress
chmod 600 /mnt/swapfile
mkswap /mnt/swapfile
swapon /mnt/swapfile
printf "$BGREEN ====== DONE ====== $NOCOLOR\n"
printf "\n"
sleep 5s

# install all required packages
printf "$BYELLOW ====== INSTALLING REQUIRED PACKAGES ====== $NOCOLOR\n"
pacstrap /mnt base linux linux-lts linux-headers linux-lts-headers linux-firmware amd-ucode grub efibootmgr os-prober sudo vim git base-devel ntfs-3g networkmanager xorg xf86-input-libinput lightdm lightdm-gtk-greeter i3 rofi ttf-dejavu brightnessctl nitrogen kitty thunar firefox ufw tlp zsh stow neofetch ctags tmux starship noto-fonts-emoji archlinux-wallpaper
if [ "$VBOX_INSTALL" = "true" ]
then
    pacstrap /mnt virtualbox-guest-utils xf86-video-vmware
else
    pacstrap /mnt xf86-video-amdgpu mesa
fi
printf "$BGREEN ====== DONE ====== $NOCOLOR\n"
printf "\n"
sleep 5s

# generate fstab file
printf "$BYELLOW ====== GENERATING FSTAB FILE ====== $NOCOLOR\n"
genfstab -U /mnt | tee -a /mnt/etc/fstab > /dev/null
printf "$BBLUE => FSTAB CONTENTS: $NOCOLOR\n"
cat /mnt/etc/fstab
sleep 15s
printf "$BGREEN ====== DONE ====== $NOCOLOR\n"
printf "\n"
sleep 5s

# get info
printf "$BYELLOW ====== OBTAINING USER INFO ====== $NOCOLOR\n"
printf "$BBLUE => ENTER DESIRED USERNAME $NOCOLOR\n"
read USER_NAME
printf "$BBLUE => ENTER DESIRED HOSTNAME $NOCOLOR\n"
read HOST_NAME
printf "$BBLUE => ENTER DESIRED PASSWORD $NOCOLOR\n"
read PASS_WORD
printf "$BGREEN ====== DONE ====== $NOCOLOR\n"
printf "\n"
sleep 5s

# chroot commands:
# 1.timedate/locale/hostname, 2.root/user password, 3.grub, 4.enable services, 5. environment
arch-chroot /mnt /bin/bash << EOC
printf "$BYELLOW ====== CHROOT: SETTING UP TIME-DATE, LOCALE AND HOSTNAME ====== $NOCOLOR\n"
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc
sed -i "s/#en_IN UTF-8/en_IN UTF-8/;s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/" /etc/locale.gen
locale-gen
printf "LANG=en_IN\n" | tee -a /etc/locale.conf > /dev/null
printf "$BBLUE => /ETC/LOCALE.CONF CONTENTS: $NOCOLOR\n"
cat /etc/locale.conf
sleep 15s
printf "$HOST_NAME\n" | tee -a /etc/hostname > /dev/null
printf "$BBLUE => /ETC/HOSTNAME CONTENTS: $NOCOLOR\n"
cat /etc/hostname
sleep 15s
printf "127.0.0.1\tlocalhost\n" | tee -a /etc/hosts > /dev/null
printf "::1\tlocalhost\n" | tee -a /etc/hosts > /dev/null
printf "$BBLUE => /ETC/HOSTS CONTENTS: $NOCOLOR\n"
cat /etc/hosts
sleep 15s
printf "$BGREEN ====== DONE ====== $NOCOLOR\n"
printf "\n"
sleep 5s

printf "$BYELLOW ====== CHROOT: CREATING NEW USER AND SET PASSWORDS ====== $NOCOLOR\n"
printf "root:$PASS_WORD\n" | chpasswd
useradd -m -s /usr/bin/zsh -G wheel $USER_NAME
printf "$USER_NAME:$PASS_WORD\n" | chpasswd
EDITOR="sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/'" visudo
printf "$BGREEN ====== DONE ====== $NOCOLOR\n"
printf "\n"
sleep 5s

printf "$BYELLOW ====== CHROOT: SETTING UP GRUB BOOTLOADER ====== $NOCOLOR\n"
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Arch
sed -i "s/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/" /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
printf "$BGREEN ====== DONE ====== $NOCOLOR\n"
printf "\n"
sleep 5s

printf "$BYELLOW ====== CHROOT: ENABLING REQUIRED SERVICES ====== $NOCOLOR\n"
mkdir -p /etc/systemd/system/multi-user.target.wants
mkdir -p /etc/systemd/system/network-online.target.wants
mkdir -p /etc/systemd/system/sysinit.target.wants
ln -sf /usr/lib/systemd/system/lightdm.service /etc/systemd/system/display-manager.service
ln -sf /usr/lib/systemd/system/NetworkManager.service /etc/systemd/system/multi-user.target.wants/NetworkManager.service
ln -sf /usr/lib/systemd/system/NetworkManager-dispatcher.service /etc/systemd/system/dbus-org.freedesktop.nm-dispatcher.service
ln -sf /usr/lib/systemd/system/NetworkManager-wait-online.service /etc/systemd/system/network-online.target.wants/NetworkManager-wait-online.service
ln -sf /usr/lib/systemd/system/systemd-timesyncd.service /etc/systemd/system/dbus-org.freedesktop.timesync1.service
ln -sf /usr/lib/systemd/system/systemd-timesyncd.service /etc/systemd/system/sysinit.target.wants/systemd-timesyncd.service
ln -sf /usr/lib/systemd/system/ufw.service /etc/systemd/system/multi-user.target.wants/ufw.service
ln -sf /usr/lib/systemd/system/tlp.service /etc/systemd/system/multi-user.target.wants/tlp.service
if [ "$VBOX_INSTALL" = "true" ]
then
    ln -sf /usr/lib/systemd/system/vboxservice.service /etc/systemd/system/multi-user.target.wants/vboxservice.service
fi
printf "$BGREEN ====== DONE ====== $NOCOLOR\n"
printf "\n"
sleep 5s

printf "$BYELLOW ====== CHROOT: SETTING ENVIRONMENT VARIABLES ====== $NOCOLOR\n"
if [ "$VBOX_INSTALL" = "true" ]
then
    printf "LIBGL_ALWAYS_SOFTWARE=true\n" | tee -a /etc/environment > /dev/null
fi
printf "$BBLUE => /ETC/ENVIRONMENT CONTENTS: $NOCOLOR\n"
cat /etc/environment
sleep 15s
printf "$BGREEN ====== DONE ====== $NOCOLOR\n"
printf "\n"
sleep 5s
EOC

# shut down
printf "$BBLUE ====== INSTALLATION COMPLETE. SHUTTING DOWN. REMOVE INSTALLATION DRIVE. ====== $NOCOLOR\n"
umount -R /mnt
sleep 5s
shutdown now

