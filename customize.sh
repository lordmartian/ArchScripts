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
# Usage (as user, from non-lts kernel):
# - bash customize.sh
# ====================================================================

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

# change to home directory
cd ~

# check internet connectivity
printf "====== CHECKING INTERNET CONNECTION ====== \n"
ping -c 5 archlinux.org
printf "====== DONE ====== \n"
printf "\n"
sleep 5s

# enabling time sync
printf "====== ENABLING TIME SYNC ====== \n"
sudo timedatectl set-ntp true
printf "====== DONE ====== \n"
printf "\n"
sleep 5s

ufw enable

# updating packages
printf "====== UPDATING PACKAGES ====== \n"
sudo pacman --noconfirm -Syu
printf "====== DONE ====== \n"
printf "\n"
sleep 5s

# ========================= for pure Arch ============================

cd /home/$USER_NAME
printf "$BYELLOW ====== CHROOT: INSTALLING YAY ====== $NOCOLOR\n"
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -sicr
cd ..
rm -rf yay
printf "$BGREEN ====== DONE ====== $NOCOLOR\n"
printf "\n"
sleep 5s

printf "$BYELLOW ====== CHROOT: INSTALLING ESSENTIAL AUR PACKAGES ====== $NOCOLOR\n"
yay -S rtl8821ce-dkms-git pamac-aur nerd-fonts-hack nerd-fonts-fira-code nerd-fonts-jetbrains-mono nerd-fonts-source-code-pro
printf "$BGREEN ====== DONE ====== $NOCOLOR\n"
printf "\n"
sleep 5s

# create dirs
printf "====== CREATING EMPTY REQUIRED DIRS ====== \n"
mkdir -p ~/Downloads/Wallpapers
mkdir -p ~/Downloads/Github
sudo mkdir -p /mnt/Windows
sudo mkdir -p /mnt/Data
printf "====== DONE ====== \n"
printf "\n"
sleep 5s

# set up git
printf "====== SETTING UP GIT ====== \n"
git config --global user.email "smeetrs@gmail.com"
git config --global user.name "lordmartian"
git config --global credential.helper store
printf "====== DONE ====== \n"
printf "\n"
sleep 5s

# zsh
printf "====== INSTALLING ZSH AND OH-MY-ZSH ====== \n"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
printf "====== DONE ====== \n"
printf "\n"
sleep 5s

# ============================ GUI ===================================

# github repos
printf "====== CLONING/DOWNLOADING STUFF FROM GITHUB ====== \n"
git clone https://github.com/dracula/alacritty.git Downloads/Github/alacritty-dracula
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git .oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/tmux-plugins/tpm .tmux/plugins/tpm
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
printf "====== DONE ====== \n"
printf "\n"
sleep 5s

# dotfiles
printf "====== ADDING MY DOTFILES ====== \n"
git clone https://github.com/lordmartian/dotfiles.git
cd dotfiles
for DIR in *
do
    if [[ -d $DIR ]]
    then
        cd $DIR
        find . -type f | sed -e "s/^\.\///" | xargs -i rm -f $HOME/{}
        cd ..
        stow -t ~ -S $DIR
    fi
done
cd ~
printf "====== DONE ====== \n"
printf "\n"
sleep 5s

printf "====== CUSTOMIZATION COMPLETE. REBOOTING. ====== \n"
sleep 5s
sudo reboot
