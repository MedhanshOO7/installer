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
    PKG="sudo pacman -S --noconfirm"
    eval "$PKG base-devel"

elif command -v apt >/dev/null; then
    PKG="sudo apt install -y"
    eval "$PKG build-essential"

elif command -v dnf >/dev/null; then
    PKG="sudo dnf install -y"
    eval 'sudo dnf groupinstall -y "Development Tools"'

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

deps[ubuntu]="git curl wget manpages manpages-dev "
deps[debian]="${deps[ubuntu]}"
deps[fedora]="git curl wget man-pages"
deps[arch]="git curl wget man-pages man-db"
deps[darwin]=''

if [[ -n "${deps[$DISTRO]:-}" ]]; then
    eval "$PKG ${deps[$DISTRO]}"
fi

#lets start with the zsh and it's dependencies
# zsh dependencies

while true; do

    read -r -t 30 -p "Do you want to install zsh and its plugins? [y/N] " zsh_choice || {
        printf '\nNo input or timeout, skipping...\n'
        break
    }

    case "$zsh_choice" in
    [Yy] | [Yy][Ee][Ss])
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
    [Nn] | [Nn][Oo] | "")
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
    read -r -t 30 -p "Do you want to set zsh as your default shell? [y/N] " toSet || {
        printf '\nNo input or timeout, skipping...\n'
        break
    }
    case "$toSet" in
    [Yy] | [Yy][Ee][Ss])
        if ! command -v zsh >/dev/null; then
            printf 'zsh is not installed, skipping...\n'
            break
        fi

        zsh_path="$(command -v zsh)"

        if ! grep -qF "$zsh_path" /etc/shells; then
            printf 'adsding %s to /etc/shells\n' "$zsh_path"
            echo "$zsh_path" | sudo tee -a /etc/shells
        fi

        set +e
        chsh -s "$zsh_path"
        chsh_status=$?
        set -e

        if [[ $chsh_status -ne 0 ]]; then
            printf 'chsh failed — run manually: chsh -s %s\n' "$zsh_path"
        fi

        break
        ;;
    [Nn] | [Nn][Oo] | "")
        printf 'Skipping settinh zsh as default\n'
        break
        ;;
    *)
        printf "Invalid input. Please enter y or n.\n"
        ;;
    esac
done
#####################ZSH AND PLUGINS ARE DONE#########

cli_common=(
    "neovim"
    "vim"
    "tmux"
    "fzf"
    "git"
    "curl"
    "wget"
    "ripgrep"
    "bat"
    "htop"
    "ffmpeg"
    "yt-dlp"
)
# format → "name:arch_pkg:ubuntu_pkg:fedora_pkg:brew_pkg"

cli_arch=(
    "eza"
    "fd"
    "btop"
    "fastfetch"
    "starship"
    "zoxide"
    "glow"
    "tldr"
    "yq"
    "aria2"
    "tty-clock"
    "cmatrix"
    "cbonsai"
    "cava"
    "wl-clipboard"
    "playerctl"
    "brightnessctl"
    "powertop"
    "tlp"
    "inotify-tools"
)

cli_ubuntu=(
    "eza"
    "fd-find"
    "btop"
    "fastfetch"
    "starship"
    "zoxide"
    "aria2"
    "wl-clipboard"
    "playerctl"
    "brightnessctl"
    "powertop"
    "tlp"
    "inotify-tools"
)

cli_fedora=(
    "eza"
    "fd-find"
    "btop"
    "fastfetch"
    "zoxide"
    "aria2"
    "wl-clipboard"
    "playerctl"
    "brightnessctl"
    "powertop"
    "tlp"
    "inotify-tools"
)

cli_darwin=(
    "eza"
    "fd"
    "btop"
    "fastfetch"
    "starship"
    "zoxide"
    "glow"
    "tldr"
    "go-yq"
    "aria2"
    "cmatrix"
    "cava"
)

gui_arch=(
    "kitty"
    "alacritty"
    "obsidian"
    "visual-studio-code-bin"
    "brave-bin"
    "firefox"
    "zen-browser-bin"
    "telegram-desktop"
    "obs-studio"
    "vlc"
    "mpv"
    "kdenlive"
    "inkscape"
    "okular"
    "gwenview"
    "spectacle"
    "flameshot"
    "easyeffects"
    "pavucontrol"
    "heroic-games-launcher-bin"
    "virt-manager"
    "openrgb"
    "timeshift"
    "pdfarranger"
    "mullvad-vpn"
    "rofi"
)

gui_ubuntu=(
    "kitty"
    "alacritty"
    "firefox"
    "telegram-desktop"
    "obs-studio"
    "vlc"
    "mpv"
    "inkscape"
    "flameshot"
    "pavucontrol"
    "virt-manager"
    "timeshift"
    "rofi"
)

gui_fedora=(
    "kitty"
    "alacritty"
    "firefox"
    "telegram-desktop"
    "obs-studio"
    "vlc"
    "mpv"
    "inkscape"
    "flameshot"
    "pavucontrol"
    "virt-manager"
    "rofi"
)

gui_darwin=(
    "kitty"
    "obs"
    "vlc"
    "mpv"
    "inkscape"
    "telegram"
    "firefox"
)

fonts_arch=(
    "ttf-jetbrains-mono-nerd"
    "ttf-firacode-nerd"
    "ttf-hack-nerd"
    "ttf-meslo-nerd"
    "ttf-cascadia-code-nerd"
    "ttf-ubuntu-nerd"
    "ttf-roboto"
    "noto-fonts"
    "noto-fonts-emoji"
    "ttf-twemoji"
)

fonts_ubuntu=(
    "fonts-jetbrains-mono"
    "fonts-firacode"
    "fonts-hack"
    "fonts-roboto"
    "fonts-noto"
    "fonts-noto-color-emoji"
)

fonts_fedora=(
    "jetbrains-mono-fonts"
    "fira-code-fonts"
    "hack-fonts"
    "google-roboto-fonts"
    "google-noto-fonts-common"
    "google-noto-emoji-color-fonts"
)

fonts_darwin=(
    "font-jetbrains-mono-nerd-font"
    "font-fira-code-nerd-font"
    "font-hack-nerd-font"
    "font-meslo-lg-nerd-font"
)

printList() {
    local list_name="$1"
    local -n pkg_list="$list_name"

    if [[ ${#pkg_list[@]} -eq 0 ]]; then
        return
    fi

    printf '\n###### %s #########\n' "$list_name"
    for i in "${!pkg_list[@]}"; do
        printf '  [%d] %s\n' "$((i + 1))" "${pkg_list[$i]}"
    done
}

installList() {
    local list_name="$1"
    local -n pkg_list="$list_name"

    if [[ ${#pkg_list[@]} -eq 0 ]]; then
        printf 'no packages in %s, skipping...\n' "$list_name"
        return
    fi

    read -r -t 60 -p $'\neclude numbers or ENTEr for all: ' excludes || {
        printf '\nno input, installing all......\n'
        excludes=""
    }

    for i in "${!pkg_list[@]}"; do
        pkg="${pkg_list[$i]}"
        num=$((i + 1))
        skip=0
        for ex in $excludes; do
            [[ "$ex" == "$num" ]] && skip=1 && break
        done
        if [[ $skip -eq 0 ]]; then
            printf 'Installing %s...\n' "$pkg"
            set +e
            eval "$PKG $pkg"
            pkg_status=$?
            set -e
            [[ $pkg_status -ne 0 ]] && printf 'failed: %s\n' "$pkg"
        else
            printf 'Skiping %s\n' "$pkg"
        fi
    done
}

breakage() {
    printf '\n=============================\n'
    printf 'packages will be installed.\n'
    read -r -t 60 -p 'pres ENTEr to continue or Ctrl+c to exit.....' || true
    printf '\n'
}

printList cli_common
breakage
installList cli_common

# call based on distro

case "$DISTRO" in
arch)
    printList cli_arch
    printList gui_arch
    printList fonts_arch

    breakage

    installList cli_arch
    installList gui_arch
    installList fonts_arch
    ;;
ubuntu | debian)
    printList cli_ubuntu
    printList gui_ubuntu
    printList fonts_ubuntu

    breakage

    installList cli_ubuntu
    installList gui_ubuntu
    installList fonts_ubuntu
    ;;
fedora)
    printList cli_fedora
    printList gui_fedora
    printList fonts_fedora

    breakage

    installList cli_fedora
    installList gui_fedora
    installList fonts_fedora
    ;;
darwin)
    printList cli_darwin
    printList gui_darwin
    printList fonts_darwin

    breakage

    installList cli_darwin
    installList gui_darwin
    installList fonts_darwin
    ;;
esac

#########STEP-III###################
# Place them on to the specific part
####################################
