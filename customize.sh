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

# updating packages
printf "====== UPDATING PACKAGES ====== \n"
sudo pacman --noconfirm -Syu
printf "====== DONE ====== \n"
printf "\n"
sleep 5s

# ========================= for pure Arch ============================

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
