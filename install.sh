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
# - Creates swap partition
#
# Usage (as root):
# - bash install.sh
# - Pass -v option for vbox installation
# - Use Ctrl+Z to suspend script. Then use 'kill -9 PID'.
# ==========================================================

NOCOLOR="\033[0m"
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"
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
if [[ "$VBOX_INSTALL" == "true" ]]
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

# create partition, format them and mount
printf "$BYELLOW ====== DISK PARTITIONING, FORMATTING AND MOUNTING ====== $NOCOLOR\n"
fdisk -l
printf "$BBLUE => ENTER PATH OF DISK TO BE PARTITIONED $BRED [!] $NOCOLOR\n"
read DISK
printf "$BBLUE => STARTING FDISK UTILITY. CREATE EFI, SWAP AND ROOT PARTITIONS. $NOCOLOR\n"
sleep 5s
fdisk $DISK
printf "$BBLUE => ENTER EFI PARTITION PATH $BRED [!] $NOCOLOR\n"
read EFI_PARTITION
printf "$BBLUE => ENTER SWAP PARTITION PATH $BRED [!] $NOCOLOR\n"
read SWAP_PARTITION
printf "$BBLUE => ENTER ROOT PARTITION PATH $BRED [!] $NOCOLOR\n"
read ROOT_PARTITION
mkfs.ext4 $ROOT_PARTITION
mount $ROOT_PARTITION /mnt
mkfs.fat -F 32 $EFI_PARTITION
mkdir -p /mnt/boot/efi
mount $EFI_PARTITION /mnt/boot/efi
mkswap $SWAP_PARTITION
swapon $SWAP_PARTITION
printf "$BGREEN ====== DONE ====== $NOCOLOR\n"
printf "\n"
sleep 5s

# install all required packages
printf "$BYELLOW ====== INSTALLING REQUIRED PACKAGES ====== $NOCOLOR\n"
pacstrap /mnt base linux linux-lts linux-headers linux-lts-headers linux-firmware amd-ucode sudo grub efibootmgr vim git base-devel ntfs-3g xorg plasma konsole dolphin firefox ufw tlp zsh stow neofetch ctags tmux starship noto-fonts-emoji
if [[ "$VBOX_INSTALL" == "true" ]]
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
# 1.timedate/locale/hostname, 2.root/user password, 3.grub, 4.AUR packages, 5.enable services
arch-chroot /mnt /bin/bash << EOC
printf "$BYELLOW ====== CHROOT: SETTING UP TIME-DATE, LOCALE AND HOSTNAME ====== $NOCOLOR\n"
ln -s /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc
sed -i "s/#en_IN UTF-8/en_IN UTF-8/;s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/" /etc/locale.gen
locale-gen
printf "LANG=en_IN\n" | tee /etc/locale.conf > /dev/null
printf "$BBLUE => /ETC/LOCALE.CONF CONTENTS: $NOCOLOR\n"
cat /etc/locale.conf
sleep 15s
printf "$HOST_NAME\n" | tee /etc/hostname > /dev/null
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
EDITOR="sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL'" visudo
printf "$BGREEN ====== DONE ====== $NOCOLOR\n"
printf "\n"
sleep 5s

printf "$BYELLOW ====== CHROOT: SETTING UP GRUB BOOTLOADER ====== $NOCOLOR\n"
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Linux
grub-mkconfig -o /boot/grub/grub.cfg
printf "$BGREEN ====== DONE ====== $NOCOLOR\n"
printf "\n"
sleep 5s

su $USER_NAME -c "
cd /home/$USER_NAME
printf "$BYELLOW ====== CHROOT: INSTALLING YAY ====== $NOCOLOR\n"
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -sicr
cd ..
rm -r yay
printf "$BGREEN ====== DONE ====== $NOCOLOR\n"
printf "\n"
sleep 5s

printf "$BYELLOW ====== CHROOT: INSTALLING ESSENTIAL AUR PACKAGES ====== $NOCOLOR\n"
yay -S rtl8821ce-dkms-git pamac-aur nerd-fonts-hack nerd-fonts-fira-code nerd-fonts-jetbrains-mono nerd-fonts-source-code-pro
printf "$BGREEN ====== DONE ====== $NOCOLOR\n"
printf "\n"
sleep 5s
"

printf "$BYELLOW ====== CHROOT: ENABLING REQUIRED SERVICES ====== $NOCOLOR\n"
ufw enable
ln -s /usr/lib/systemd/system/sddm.service /etc/systemd/system/display-manager.service
ln -s /usr/lib/systemd/system/NetworkManager.service /etc/systemd/system/multi-user.target.wants/NetworkManager.service
ln -s /usr/lib/systemd/system/NetworkManager-dispatcher.service /etc/systemd/system/dbus-org.freedesktop.nm-dispatcher.service
ln -s /usr/lib/systemd/system/NetworkManager-wait-online.service /etc/systemd/system/network-online.target.wants/NetworkManager-wait-online.service
ln -s /usr/lib/systemd/system/ufw.service /etc/systemd/system/multi-user.target.wants/ufw.service
ln -s /usr/lib/systemd/system/tlp.service /etc/systemd/system/multi-user.target.wants/tlp.service
if [[ "$VBOX_INSTALL" == "true" ]]
then
    ln -s /usr/lib/systemd/system/vboxservice.service /etc/systemd/system/multi-user.target.wants/vboxservice.service
fi
printf "$BGREEN ====== DONE ====== $NOCOLOR\n"
printf "\n"
sleep 5s
EOC

# shut down
printf "$BBLUE ====== INSTALLATION COMPLETE. SHUTTING DOWN. REMOVE INSTALLATION DRIVE. ====== $NOCOLOR\n"
umount -R /mnt
sleep 5s
shutdown now
