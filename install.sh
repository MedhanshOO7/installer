#!/usr/bin bash

############################################################
#dotfiles i need to add to a system
# -> before anything I do i need to install dependencies
# -> zsh configs
# -> kitty configs (Mac/linux)
# -> fastfetch configs
# -> obsidian configs
# -> .p10k.zsh
# -> neovim
# -> vim configs
# -> vs-code
# -> fonts
# -> special kde setup
# -> installing basic tools (something like a tui)
############################################################

#########SOME SETTINGS#######################################
# set default shell
# set
#############################################################
##

#echo "Hello World"

#########STEP-I####################
# Get information about the system
###################################

####################PART-A###########################################
# get the uname first and then `cat /etc/os-release`
OS_VAR="$(uname)" #this variable will be either Linux or Darwin
DISTRO=''
PKG=''
#shopts
set -euo pipefail

getDistro() {
    if [[ -r /etc/os-release ]]; then
        DISTRO=$(grep -i '^NAME=' /etc/os-release | cut -d= -f2 | tr -d '"')
    fi
}

if [[ "$OS_VAR" == "Darwin" ]]; then
    printf 'Detected OS is Darwin\n'
    DISTRO='Mac'
    printf '%s\n' "$DISTRO"

elif [[ "$OS_VAR" == "Linux" ]]; then
    printf 'Detected OS is Linux...\n'
    getDistro
    printf '%s\n' "$DISTRO"

fi

#📐 CHECK:- works on fedora arch ubuntu

####################PART-B###########################################
#Detect the correct pacakage manager
if command -v pacman >/dev/null; then
    PKG="pacman -S --noconfirm"
elif command -v apt >/dev/null; then
    PKG="apt install -y"
elif command -v dnf >/dev/null; then
    PKG="dnf install -y"
elif command -v brew >/dev/null; then
    PKG="brew install"
else
    echo "Unsupported system"
    exit 1
fi

printf 'package manager is %s\n' "$PKG"

#########STEP-II#############################################
# Based on the system i need to download the depending files
#############################################################

#########STEP-III###################
# Place them on to the specific part
####################################
