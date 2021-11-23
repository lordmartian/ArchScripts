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

# time sync, system update, firewall enable
printf "$BYELLOW ====== POST-INSTALL TASKS ====== $NOCOLOR\n"
sudo timedatectl set-ntp true
sudo pacman --noconfirm -Syu
sudo ufw enable
printf "$BGREEN ====== DONE ====== $NOCOLOR\n"
printf "\n"
sleep 5s

# create dirs
printf "$BYELLOW ====== CREATING EMPTY REQUIRED DIRS ====== $NOCOLOR\n"
mkdir -p ~/Downloads/Wallpapers
mkdir -p ~/Downloads/Github
sudo mkdir -p /mnt/Windows
sudo mkdir -p /mnt/Data
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
yay -S rtl8821ce-dkms-git pamac-aur nerd-fonts-hack nerd-fonts-fira-code nerd-fonts-jetbrains-mono nerd-fonts-source-code-pro
printf "$BGREEN ====== DONE ====== $NOCOLOR\n"
printf "\n"
sleep 5s

# set up git
printf "$BYELLOW ====== SETTING UP GIT ====== $NOCOLOR\n"
git config --global user.email "smeetrs@gmail.com"
git config --global user.name "lordmartian"
git config --global credential.helper store
printf "$BGREEN ====== DONE ====== $NOCOLOR\n"
printf "\n"
sleep 5s

# zsh
printf "$BYELLOW ====== INSTALLING OH-MY-ZSH ====== $NOCOLOR\n"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
printf "$BGREEN ====== DONE ====== $NOCOLOR\n"
printf "\n"
sleep 5s

# github repos
printf "$BYELLOW ====== CLONING/DOWNLOADING STUFF FROM GITHUB ====== $NOCOLOR\n"
git clone https://github.com/dracula/alacritty.git Downloads/Github/alacritty-dracula
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git .oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/tmux-plugins/tpm .tmux/plugins/tpm
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
printf "$BGREEN ====== DONE ====== $NOCOLOR\n"
printf "\n"
sleep 5s

# dotfiles
printf "$BYELLOW ====== ADDING MY DOTFILES ====== $NOCOLOR\n"
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
printf "$BGREEN ====== DONE ====== $NOCOLOR\n"
printf "\n"
sleep 5s

printf "$BBLUE ====== CUSTOMIZATION COMPLETE. REBOOTING. ====== $NOCOLOR\n"
sleep 5s
sudo reboot now
