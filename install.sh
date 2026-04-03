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

#shopts
set -euo pipefail
PS4='\n[DEBUG] ${LINENO} :- '

if [[ "${1:-}" == "--debug" ]]; then
    set -x
fi

# get the uname first and then `cat /etc/os-release`
OS_VAR="$(uname)" #this variable will be either Linux or Darwin
DISTRO=''
PKG=''

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
if command -v pacman >/dev/null; then
    PKG="pacman -S --noconfirm"
elif command -v apt >/dev/null; then
    PKG="apt install -y"
elif command -v dnf >/dev/null; then
    PKG="dnf install -y"
elif [[ "$OS_VAR" == "Darwin" ]]; then
    PKG="brew install"
else
    echo "Unsupported system"
    exit 1
fi

#printf 'package manager is %s\n' "$PKG"

#📐 CHECK:- Detects os and the manager correctly

#########STEP-II#########################################
# Based on the system i need to download the dependencies
#########################################################

dependencies=(zsh git curl wget neovim fastfetch vim fzf tmux)

for pkg_name in "${dependencies[@]}"; do
    if ! eval "$PKG $pkg_name"; then
        printf "Failed to install $pkg_name\n"
    fi
done

#lets start with the zsh and it's dependencies
# set it to default shell
#########STEP-III###################
# Place them on to the specific part
####################################
