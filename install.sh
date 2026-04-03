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

updatePkgManager() {
    case "$DISTRO" in
    ubuntu | debian) sudo apt update ;;
    fedora) sudo dnf check-update || true ;; # dnf returns exit 100 when updates exist, not an error
    arch) sudo pacman -Sy ;;
    darwin) brew update ;;
    esac
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
updatePkgManager

if command -v pacman >/dev/null; then
    PKG="pacman -S --noconfirm"
    eval "$PKG base-devel"

elif command -v apt >/dev/null; then
    PKG="apt install -y"
    eval "$PKG build-essential"

elif command -v dnf >/dev/null; then
    PKG="dnf install -y"
    eval 'dnf groupinstall "Development Tools"'

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

# Downloading basic things first

declare -A deps

deps[ubuntu]="git curl wget manpages manpages-dev libstdc++-docs"
deps[fedora]="git curl wget man-pages man-pages-devel"
deps[arch]="git curl wget man-pages man-db gcc-docs"
deps[darwin]=''
eval "$PKG ${deps[$DISTRO]}"

#lets start with the zsh and it's dependencies
# zsh dependencies

while true; do
    read -r -p "Do you want to install zsh and its plugins? [y/N] " zsh_choice

    case "${zsh_choice,,}" in
    y | yes | "")
        printf "Downloading zsh...\n"
        eval "$PKG zsh"

        ZSH_CUSTOM="${HOME}/.zsh"
        mkdir -p "$ZSH_CUSTOM"

        zsh_plugins=(
            "zsh-autosuggestions:https://github.com/zsh-users/zsh-autosuggestions"
            "zsh-syntax-highlighting:https://github.com/zsh-users/zsh-syntax-highlighting"
            "fzf-tab:https://github.com/Aloxaf/fzf-tab"
            "powerlevel10k:https://github.com/romkatv/powerlevel10k"
        )

        for entry in "${zsh_plugins[@]}"; do
            plugin="${entry%%:*}"
            url="${entry#*:}"
            target="$ZSH_CUSTOM/$plugin"

            if [[ -d "$target" ]]; then
                printf 'Updating %s...\n' "$plugin"
                git -C "$target" pull
            else
                printf 'Cloning %s...\n' "$plugin"
                git clone --depth=1 "$url" "$target"
            fi
        done
        break
        ;;
    n | no)
        printf "Skipping zsh installation.\n"
        break
        ;;
    *)
        printf "Invalid input. Please enter y or n.\n"
        ;;
    esac
done
# set it to default shell
while true; do
    read -r -p "Do you want to set zsh as your default shell? [y/N] " toSet
    case "${toSet,,}" in
    y | yes | "")
        if ! command -v zsh >/dev/null; then
            printf 'zsh is not installed, skipping...\n'
            break
        fi

        zsh_path="$(command -v zsh)"

        if ! grep -qF "$zsh_path" /etc/shells; then
            printf 'adsding %s to /etc/shells\n' "$zsh_path"
            echo "$zsh_path" | sudo tee -a /etc/shells
        fi

        chsh -s "$zsh_path"

        break
        ;;
    n | no)
        printf 'Skipping settinh zsh as default\n'
        break
        ;;
    *)
        printf "Invalid input. Please enter y or n.\n"
        ;;
    esac
done

#########STEP-III###################
# Place them on to the specific part
####################################
