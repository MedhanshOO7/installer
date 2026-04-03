#!/usr/bin/env bash

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
PS4='\n[DEBUG] ${LINENO} :- '

if [[ "${1:-}" == "--debug" ]]; then
    set -x
fi

getDistro() {
    if [[ -r /etc/os-release ]]; then
        . /etc/os-release
        DISTRO="$ID"
    fi
}
brewInstalled() {
    # approach
    # if installed the good else install it
    if command -v brew >/dev/null; then
        printf 'Brew is insatlled\n'
    else
        printf 'Insatlling home brew from the official repo\n'
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # add to path
        if [[ -d /opt/homebrew/bin ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    fi

    if ! command -v brew >/dev/null; then
        printf 'Homebrew installation failed\n'
        return 1
    fi

    PKG="brew install"

}

if [[ "$OS_VAR" == "Darwin" ]]; then
    printf 'Detected OS is Darwin\n'
    DISTRO='darwin'
    #printf '%s\n' "$DISTRO"

    #check for the brew installation
    brewInstalled

elif [[ "$OS_VAR" == "Linux" ]]; then
    printf 'Detected OS is Linux...\n'
    getDistro
    #printf '%s\n' "$DISTRO"

fi

#📐 CHECK:- works on fedora arch ubuntu

####################PART-B###########################################
#Detect the correct pacakage manager
if command -v pacman --noconfirm >/dev/null; then
    PKG="pacman -S"
elif command -v apt >/dev/null; then
    PKG="apt install -y"
elif command -v dnf >/dev/null; then
    PKG="dnf install -y"
else
    echo "Unsupported system"
    exit 1
fi

#printf 'package manager is %s\n' "$PKG"

#########STEP-II#############################################
# Based on the system i need to download the depending files
#############################################################

#########STEP-III###################
# Place them on to the specific part
####################################
