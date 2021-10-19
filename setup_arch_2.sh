#!/bin/bash

# ====================================================================
# Bash script to setup a fresh Arch Linux installation (Part 2)
# [User setup]
#
# Pre-requisites:
# - Successfully completed part 1 script
# - Working internet connection
#
# Notes:
# -  Apps and settings specific to me
#
# Usage (in user account):
# - bash setup_arch_2.sh
# - Pass -v option for vbox installation
# ====================================================================

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

# enabling time sync
printf '====== ENABLING TIME SYNC ====== \n'
sudo timedatectl set-ntp true
printf '====== DONE ====== \n'
printf '\n'
sleep 5s

# updating mirrorlist
printf '====== OPENING PACMAN MIRRORLIST. UPDATE IT IF NEEDED. ====== \n'
sleep 5s
sudo vim /etc/pacman.d/mirrorlist
printf '====== DONE ====== \n'
printf '\n'
sleep 5s

# updating packages
printf '====== UPDATING PACKAGES ====== \n'
sudo pacman --noconfirm -Syu
printf '====== DONE ====== \n'
printf '\n'
sleep 5s

# ========================= for pure Arch ============================

# yay
printf '====== INSTALLING YAY ====== \n'
mkdir -p ~/Downloads/Github
mkdir -p ~/Downloads/AUR
cd Downloads/AUR
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -sicr
cd ~
printf '====== DONE ====== \n'
printf '\n'
sleep 5s

# linux lts wifi drivers
printf '====== INSTALLING WIFI DRIVERS FOR LINUX LTS ====== \n'
yay -S rtl8821ce-dkms-git
printf '====== DONE ====== \n'
printf '\n'
sleep 5s

# firewall
printf '====== INSTALLING FIREWALL ====== \n'
sudo pacman --noconfirm -S ufw
sudo ufw enable
sudo systemctl enable ufw
printf '====== DONE ====== \n'
printf '\n'
sleep 5s

# tlp
printf '====== INSTALLING TLP ====== \n'
sudo pacman --noconfirm -S tlp
sudo systemctl enable tlp
printf '====== DONE ====== \n'
printf '\n'
sleep 5s

# zsh
printf '====== INSTALLING ZSH AND OH-MY-ZSH ====== \n'
sudo pacman --noconfirm -S zsh
sudo chsh -s /bin/zsh $USER
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
rm -f ~/.bash*
printf '====== DONE ====== \n'
printf '\n'
sleep 5s

# ============================ GUI ===================================

# display server, drivers and display manager
printf '====== INSTALLING XORG, DRIVERS AND LIGHTDM ====== \n'
sudo pacman --noconfirm -S xorg
if $VBOX_INSTALL
then
    sudo pacman --noconfirm -S xf86-video-vmware
else
    sudo pacman --noconfirm -S xf86-video-amdgpu mesa
fi
sudo pacman --noconfirm -S lightdm lightdm-gtk-greeter
sudo systemctl enable lightdm
printf '====== DONE ====== \n'
printf '\n'
sleep 5s

# i3 window manager
printf '====== INSTALLING I3 WM ====== \n'
yay -S i3-gaps-rounded-git
sudo pacman --noconfirm -S i3status rofi alacritty ttf-dejavu
sudo pacman --noconfirm -S brightnessctl nitrogen
printf 'Xft.dpi: 150\n' | tee ~/.Xresources > /dev/null
printf '====== DONE ====== \n'
printf '\n'
sleep 5s

# tap to click and natural scrolling
printf '====== ENABLING TAP-TO-CLICK AND NATURAL SCROLLING ====== \n'
sudo pacman --noconfirm -S xf86-input-libinput
printf '\tOption "Tapping" "on"\n' | sudo tee -a /usr/share/X11/xorg.conf.d/40-libinput.conf > /dev/null
printf '\tOption "NaturalScrolling" "true"\n' | sudo tee -a /usr/share/X11/xorg.conf.d/40-libinput.conf > /dev/null
printf '=> OPENING 40-LIBINPUT.CONF FILE. MOVE BOTTOM TWO LINES TO TOUCHPAD SECTION. \n'
sleep 5s
sudo vim /usr/share/X11/xorg.conf.d/40-libinput.conf
printf '====== DONE ====== \n'
printf '\n'
sleep 5s

# necessary apps
printf '====== INSTALLING NECESSARY APPS ====== \n'
sudo pacman --noconfirm -S neofetch firefox
yay -S pamac-aur nerd-fonts-hack
printf '====== DONE ====== \n'
printf '\n'
sleep 5s

# github repos
printf '====== CLONING REQUIRED GITHUB REPOS ====== \n'
cd Downloads/Github
git clone https://github.com/dracula/alacritty.git alacritty-dracula
cd ~
printf '====== DONE ====== \n'
printf '\n'
sleep 5s

# dotfiles
printf '====== ADDING MY DOTFILES ====== \n'
sudo pacman --noconfirm -S stow
git clone https://github.com/lordmartian/dotfiles.git
cd dotfiles
for DIR in *
do
    if [[ -d $DIR ]]
    then
        cd $DIR
        find . -type f | sed -e 's/^\.\///' | xargs -i rm -f $HOME/{}
        cd ..
        stow -t ~ -S $DIR
    fi
done
cd ~
printf '====== DONE ====== \n'
printf '\n'
sleep 5s

# create dirs
printf '====== CREATING EMPTY REQUIRED DIRS ====== \n'
mkdir -p /mnt/Windows
mkdir -p /mnt/Data
mkdir -p ~/Downloads/Wallpapers
printf '====== DONE ====== \n'
printf '\n'
sleep 5s

printf '====== SETUP COMPLETE. REBOOTING. ====== \n'
sleep 5s
sudo reboot
