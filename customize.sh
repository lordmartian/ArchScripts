#!/bin/bash

# ====================================================================
# Bash script to customize fresh Arch Linux system
#
# Pre-requisites:
# - Working internet connection
#
# Notes:
# -  Settings specific to me
#
# Usage (as user):
# - bash customize.sh
# ====================================================================

NOCOLOR="\033[0m"
BRED="\033[1;31m"
BGREEN="\033[1;32m"
BYELLOW="\033[1;33m"
BBLUE="\033[1;34m"
BPURPLE="\033[1;35m"
BCYAN="\033[1;36m"

# change to home directory
cd ~

# check internet connectivity
printf "$BYELLOW ====== CHECKING INTERNET CONNECTION ====== $NOCOLOR\n"
ping -c 5 archlinux.org
printf "$BGREEN ====== DONE ====== $NOCOLOR\n"
printf "\n"
sleep 5s

# system update, firewall enable
printf "$BYELLOW ====== POST-INSTALL TASKS ====== $NOCOLOR\n"
sudo pacman --noconfirm -Syu
sudo ufw enable
printf "$BGREEN ====== DONE ====== $NOCOLOR\n"
printf "\n"
sleep 5s

# create dirs
printf "$BYELLOW ====== CREATING EMPTY REQUIRED DIRS ====== $NOCOLOR\n"
mkdir -p ~/GitHub
sudo mkdir -p /mnt/System
sudo mkdir -p /mnt/Data
printf "$BGREEN ====== DONE ====== $NOCOLOR\n"
printf "\n"
sleep 5s

# i3 tasks
printf "$BYELLOW ====== I3 SPECIFIC TASKS ====== $NOCOLOR\n"
printf "Xft.dpi: 135\n" | tee ~/.Xresources > /dev/null
printf "$BBLUE => STARTING NITROGEN, SELECT WALLPAPER. $NOCOLOR\n"
sleep 5s
nitrogen /usr/share/backgrounds/archlinux
printf "$BGREEN ====== DONE ====== $NOCOLOR\n"
printf "\n"
sleep 5s

# tap to click and natural scrolling
printf "$BYELLOW ====== ENABLING TAP-TO-CLICK AND NATURAL SCROLLING ====== $NOCOLOR\n"
printf "\tOption \"Tapping\" \"on\"\n" | sudo tee -a /usr/share/X11/xorg.conf.d/40-libinput.conf > /dev/null
printf "\tOption \"NaturalScrolling\" \"true\"\n" | sudo tee -a /usr/share/X11/xorg.conf.d/40-libinput.conf > /dev/null
printf "$BBLUE => OPENING 40-LIBINPUT.CONF FILE. MOVE BOTTOM TWO LINES TO TOUCHPAD SECTION. $NOCOLOR\n"
sleep 5s
sudo vim /usr/share/X11/xorg.conf.d/40-libinput.conf
printf "$BGREEN ====== DONE ====== $NOCOLOR\n"
printf "\n"
sleep 5s

# install yay aur helper
printf "$BYELLOW ====== INSTALLING YAY ====== $NOCOLOR\n"
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -sicr
cd ..
rm -rf yay
printf "$BGREEN ====== DONE ====== $NOCOLOR\n"
printf "\n"
sleep 5s

# install aur packages
printf "$BYELLOW ====== INSTALLING AUR PACKAGES ====== $NOCOLOR\n"
yay -S rtl8821ce-dkms-git pamac-aur nerd-fonts-hack
printf "$BGREEN ====== DONE ====== $NOCOLOR\n"
printf "\n"
sleep 5s

# github repos
printf "$BYELLOW ====== CLONING/DOWNLOADING STUFF FROM GITHUB ====== $NOCOLOR\n"
git clone https://github.com/jandamm/zgenom.git .zgenom
git clone https://github.com/tmux-plugins/tpm.git .tmux/plugins/tpm
curl -fLo .vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
printf "$BGREEN ====== DONE ====== $NOCOLOR\n"
printf "\n"
sleep 5s

# dotfiles
printf "$BYELLOW ====== ADDING MY DOTFILES ====== $NOCOLOR\n"
git clone https://github.com/lordmartian/dotfiles.git
cd dotfiles
for DIR in *
do
    if [ -d $DIR ]
    then
        cd $DIR
        find . -type f | sed -e "s/^\.\///" | xargs -i rm -f ~/{}
        cd ..
        stow -t ~ -S $DIR
    fi
done
cd ..
printf "$BGREEN ====== DONE ====== $NOCOLOR\n"
printf "\n"
sleep 5s

printf "$BBLUE ====== CUSTOMIZATION COMPLETE. REBOOTING. ====== $NOCOLOR\n"
sleep 5s
sudo reboot now

