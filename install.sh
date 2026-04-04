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

    read -r -t 60 -p $'\nExclude numbers or Enter for all: ' excludes || {
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
            [[ $pkg_status -ne 0 ]] && printf 'Failed: %s\n' "$pkg"
            set -e
        else
            printf 'Skipping %s\n' "$pkg"
        fi
    done
}

breakage() {
    printf '\n=============================\n'
    printf 'Packages will be installed.\n'
    read -r -t 60 -p 'Press ENTER to continue or Ctrl+C to exit.....' || true
    printf '\n'
}

#printf 'package manager is %s\n' "$PKG"

#📐 CHECK:- Detects os and the manager correctly

#########STEP-II#########################################
# Based on the system i need to download the dependencies
#########################################################

# Downloading basic things first

declare -A deps

deps[ubuntu]="git curl wget manpages manpages-dev gpg"
# "gpg" #this is required for eza to be installed on debian based sysntems

deps[debian]="${deps[ubuntu]}"
deps[fedora]="git curl wget man-pages"
deps[arch]="git curl wget man-pages man-db"
deps[darwin]=''

if [[ -n "${deps[$DISTRO]:-}" ]]; then
    read -ra base_deps <<< "${deps[$DISTRO]}"
    printList base_deps
    installList base_deps
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

        if [[ ! -d "${HOME}/.oh-my-zsh" ]]; then
            printf 'Installing oh-my-zsh...\n'
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        else
            printf 'oh-my-zsh already installed\n'
        fi

        # plugins
        if [[ -d "${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]]; then
            printf 'zsh-autosuggestions already installed, skipping...\n'
        else
            git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
                "${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
        fi

        if [[ -d "${HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]]; then
            printf 'zsh-syntax-highlighting already installed, skipping...\n'
        else
            git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting \
                "${HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
        fi

        if [[ -d "${HOME}/.oh-my-zsh/custom/plugins/fzf-tab" ]]; then
            printf 'fzf-tab already installed, skipping...\n'
        else
            git clone --depth=1 https://github.com/Aloxaf/fzf-tab \
                "${HOME}/.oh-my-zsh/custom/plugins/fzf-tab"
        fi

        if [[ -d "${HOME}/.oh-my-zsh/custom/themes/powerlevel10k" ]]; then
            printf 'powerlevel10k already installed, skipping...\n'
        else
            git clone --depth=1 https://github.com/romkatv/powerlevel10k \
                "${HOME}/.oh-my-zsh/custom/themes/powerlevel10k"
        fi
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
        printf 'Skipping setting zsh as default\n'
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
    "curl"
    "wget"
    "ripgrep"
    "bat"
    "htop"
    "ffmpeg"
    "yt-dlp"
)
cli_arch=(
    "eza"
    "fd"
    "btop"
    "fastfetch"
    "zoxide"
    "glow"
    "tldr"
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
    "snapd"
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
    "obsidian"
    "visual-studio-code-bin"
    "brave-bin"
    "firefox"
    "zen-browser-bin"
    "telegram-desktop"
    "obs-studio"
    "vlc"
    "kdenlive"
    "inkscape"
    "okular"
    "gwenview"
    "spectacle"
    "flameshot"
    "easyeffects"
    "pavucontrol"
    "virt-manager"
    "timeshift"
    "pdfarranger"
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

installEZA(){
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor --yes -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    sudo apt update
    sudo apt install -y eza
}



# call based on distro
case "$DISTRO" in
arch)
    printList cli_common
    breakage
    installList cli_common

    printList cli_arch
    breakage
    installList cli_arch

    printList gui_arch
    breakage
    installList gui_arch

    printList fonts_arch
    breakage
    installList fonts_arch
    ;;
ubuntu | debian)
    printList cli_common
    breakage
    installList cli_common
    installEZA

    printList cli_ubuntu
    breakage
    installList cli_ubuntu

    printList gui_ubuntu
    breakage
    installList gui_ubuntu

    printList fonts_ubuntu
    breakage
    installList fonts_ubuntu
    ;;
fedora)
    printList cli_common
    breakage
    installList cli_common

    printList cli_fedora
    breakage
    installList cli_fedora

    printList gui_fedora
    breakage
    installList gui_fedora

    printList fonts_fedora
    breakage
    installList fonts_fedora
    ;;
darwin)
    printList cli_common
    breakage
    installList cli_common

    printList cli_darwin
    breakage
    installList cli_darwin

    printList gui_darwin
    breakage
    installList gui_darwin

    printList fonts_darwin
    breakage
    installList fonts_darwin
    ;;
esac

printf 'Reached till here'

#### NOW-EVERYTHING-IS-INSTALLED########
###NOW-COPYING-THE-CONFIG-FILES#########

#########STEP-III###################
# Place them on to the specific part
# NOw i like the chatgpt's logic of creating symlinks rather that going and copyonh fils
# so we create a directory dotfiles
# we create symlinks (i need to read about thoes first)
####################################
# reusing the old assignment logic to execute the same

#directory
DOTFILES_DIR="${HOME}/.dotfiles"
DOTFILES_REPO="https://github.com/MedhanshOO7/dotfiles.git"

# clone or update
if [[ -d "$DOTFILES_DIR" ]]; then
    printf 'Dotfiles already exist, pulling latest...\n'
    git -C "$DOTFILES_DIR" pull
else
    printf 'Cloning dotfiles...\n'
    git clone --depth=1 "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

if [[ ! -d "$DOTFILES_DIR" ]]; then
    printf 'Failed to clone dotfiles, exiting...\n'
    exit 1
fi

symlink() {
    local src="$1"
    local dst="$2"

    # create directory
    mkdir -p "$(dirname "$dst")"

    # backup if exists and is not already a symlink(chatgpt)
    if [[ -e "$dst" && ! -L "$dst" ]]; then
        mv "$dst" "${dst}.bak"
        printf 'baked up %s -> %s.bak\n' "$dst" "${dst}.bak"
    fi

    ln -sf "$src" "$dst"
    printf 'linked %s -> %s\n' "$src" "$dst"
}

############EVRYTHING HERE BY IS GENERATED BY `gemini`
# Because i find it exhausting to map each and everythign
# .p10k.zsh
# CLI tools
symlink "$DOTFILES_DIR/.zshrc" "${HOME}/.zshrc"
symlink "$DOTFILES_DIR/.zsh" "${HOME}/.zsh"
symlink "$DOTFILES_DIR/.p10k.zsh" "${HOME}/.p10k.zsh"

symlink "$DOTFILES_DIR/.vimrc" "${HOME}/.vimrc"
symlink "$DOTFILES_DIR/.vim" "${HOME}/.vim"

symlink "$DOTFILES_DIR/.config/kitty" "${HOME}/.config/kitty"
symlink "$DOTFILES_DIR/.config/nvim" "${HOME}/.config/nvim"
symlink "$DOTFILES_DIR/.config/fastfetch" "${HOME}/.config/fastfetch"
symlink "$DOTFILES_DIR/.fastfetch" "${HOME}/.fastfetch"
symlink "$DOTFILES_DIR/.config/cava" "${HOME}/.config/cava"
symlink "$DOTFILES_DIR/.config/htop" "${HOME}/.config/htop"
symlink "$DOTFILES_DIR/.config/bashtop" "${HOME}/.config/bashtop"
symlink "$DOTFILES_DIR/.config/rofi" "${HOME}/.config/rofi"

# vscode / vscodium
symlink "$DOTFILES_DIR/.config/Code/User/settings.json" "${HOME}/.config/Code/User/settings.json"
symlink "$DOTFILES_DIR/.config/Code/User/keybindings.json" "${HOME}/.config/Code/User/keybindings.json"
symlink "$DOTFILES_DIR/.config/VSCodium/User/settings.json" "${HOME}/.config/VSCodium/User/settings.json"

# zsh
symlink "$DOTFILES_DIR/.zsh" "${HOME}/.zsh"

# kde — only on linux
if [[ "$OS_VAR" == "Linux" && "${XDG_CURRENT_DESKTOP:-}" =~ [Kk][Dd][Ee]|[Pp]lasma ]]; then
    symlink "$DOTFILES_DIR/.config/Kvantum" "${HOME}/.config/Kvantum"
    symlink "$DOTFILES_DIR/.config/dolphinrc" "${HOME}/.config/dolphinrc"
    symlink "$DOTFILES_DIR/.config/kdeglobals" "${HOME}/.config/kdeglobals"
    symlink "$DOTFILES_DIR/.config/kglobalshortcutsrc" "${HOME}/.config/kglobalshortcutsrc"
    symlink "$DOTFILES_DIR/.config/konsolerc" "${HOME}/.config/konsolerc"
    symlink "$DOTFILES_DIR/.config/kwinrc" "${HOME}/.config/kwinrc"
    symlink "$DOTFILES_DIR/.config/kwinrulesrc" "${HOME}/.config/kwinrulesrc"
    symlink "$DOTFILES_DIR/.config/plasma-org.kde.plasma.desktop-appletsrc" \
        "${HOME}/.config/plasma-org.kde.plasma.desktop-appletsrc"
    symlink "$DOTFILES_DIR/.config/plasmashellrc" "${HOME}/.config/plasmashellrc"
    symlink "$DOTFILES_DIR/.config/systemsettingsrc" "${HOME}/.config/systemsettingsrc"
    symlink "$DOTFILES_DIR/.local/share/kwin/scripts" "${HOME}/.local/share/kwin/scripts"
fi

printf '\nall symlinks created.\n'