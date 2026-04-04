#!/usr/bin/env bash

set -euo pipefail
PS4='\n[DEBUG] line ${LINENO}: '

DEBUG=0
DRY_RUN=0
NON_INTERACTIVE=0
AUTO_YES=0

OS_NAME="$(uname -s)"
DISTRO=''
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
PROMPT_FD=''
PROMPT_MODE_NOTIFIED=0
BREW_FONT_TAP_READY=0

FORMULA_CMD=()
CASK_CMD=()
FONT_CMD=()
UPDATE_CMD=()
BUILD_TOOLS_CMD=()

FAILED_PACKAGES=()
SKIPPED_LINKS=()

USER_INPUT=''
array_copy=()
selected_packages=()

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
    "firefox"
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
    "virt-manager"
    "openrgb"
    "timeshift"
    "pdfarranger"
    "rofi"
)

arch_manual_apps=(
    "visual-studio-code-bin"
    "brave-bin"
    "zen-browser-bin"
    "heroic-games-launcher-bin"
    "mullvad-vpn"
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

dotfile_links=(
    ".config/kitty|$HOME/.config/kitty"
    ".config/nvim|$HOME/.config/nvim"
    ".config/fastfetch|$HOME/.config/fastfetch"
    ".fastfetch|$HOME/.fastfetch"
    ".config/cava|$HOME/.config/cava"
    ".config/htop|$HOME/.config/htop"
    ".config/bashtop|$HOME/.config/bashtop"
    ".config/rofi|$HOME/.config/rofi"
    ".config/Code/User/settings.json|$HOME/.config/Code/User/settings.json"
    ".config/Code/User/keybindings.json|$HOME/.config/Code/User/keybindings.json"
    ".config/VSCodium/User/settings.json|$HOME/.config/VSCodium/User/settings.json"
    ".zsh|$HOME/.zsh"
)

kde_dotfile_links=(
    ".config/Kvantum|$HOME/.config/Kvantum"
    ".config/dolphinrc|$HOME/.config/dolphinrc"
    ".config/kdeglobals|$HOME/.config/kdeglobals"
    ".config/kglobalshortcutsrc|$HOME/.config/kglobalshortcutsrc"
    ".config/konsolerc|$HOME/.config/konsolerc"
    ".config/kwinrc|$HOME/.config/kwinrc"
    ".config/kwinrulesrc|$HOME/.config/kwinrulesrc"
    ".config/plasma-org.kde.plasma.desktop-appletsrc|$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
    ".config/plasmashellrc|$HOME/.config/plasmashellrc"
    ".config/systemsettingsrc|$HOME/.config/systemsettingsrc"
    ".local/share/kwin/scripts|$HOME/.local/share/kwin/scripts"
)

usage() {
    cat <<EOF
Usage: $(basename "$0") [options]

Options:
  --debug                 Enable shell tracing.
  --dry-run               Print commands without making changes.
  --yes, -y               Accept every optional prompt.
  --non-interactive       Use defaults instead of prompting.
  --dotfiles-dir PATH     Override the dotfiles directory.
  --help, -h              Show this help text.
EOF
}

die() {
    printf 'Error: %s\n' "$1" >&2
    exit 1
}

info() {
    printf '%s\n' "$1"
}

warn() {
    printf 'Warning: %s\n' "$1" >&2
}

print_section() {
    printf '\n== %s ==\n' "$1"
}

print_command() {
    local arg
    for arg in "$@"; do
        printf '%q ' "$arg"
    done
    printf '\n'
}

run_cmd() {
    if [[ "$DRY_RUN" -eq 1 ]]; then
        printf '[dry-run] '
        print_command "$@"
        return 0
    fi

    "$@"
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
        --debug)
            DEBUG=1
            ;;
        --dry-run)
            DRY_RUN=1
            ;;
        --yes | -y)
            AUTO_YES=1
            ;;
        --non-interactive)
            NON_INTERACTIVE=1
            ;;
        --dotfiles-dir)
            [[ $# -ge 2 ]] || die "--dotfiles-dir requires a path."
            DOTFILES_DIR="$2"
            shift
            ;;
        --help | -h)
            usage
            exit 0
            ;;
        *)
            die "Unknown option: $1"
            ;;
        esac
        shift
    done

    if [[ "$DEBUG" -eq 1 ]]; then
        set -x
    fi
}

setup_prompt_fd() {
    if [[ "$NON_INTERACTIVE" -eq 1 || "$AUTO_YES" -eq 1 ]]; then
        return
    fi

    if exec 3</dev/tty 2>/dev/null; then
        PROMPT_FD=3
    fi
}

close_prompt_fd() {
    if [[ -n "$PROMPT_FD" ]]; then
        exec 3<&-
    fi
}

prompt_line() {
    local prompt="$1"
    local default_value="$2"
    local input=''

    if [[ "$NON_INTERACTIVE" -eq 1 || "$AUTO_YES" -eq 1 ]]; then
        USER_INPUT="$default_value"
        return 0
    fi

    if [[ -n "$PROMPT_FD" ]]; then
        if ! read -r -u "$PROMPT_FD" -t 120 -p "$prompt" input; then
            printf '\n' >&2
            input="$default_value"
        fi
    elif [[ -t 0 ]]; then
        if ! read -r -t 120 -p "$prompt" input; then
            printf '\n' >&2
            input="$default_value"
        fi
    else
        if [[ "$PROMPT_MODE_NOTIFIED" -eq 0 ]]; then
            warn "No interactive terminal detected. Optional steps will use safe defaults."
            PROMPT_MODE_NOTIFIED=1
        fi
        input="$default_value"
    fi

    USER_INPUT="${input:-$default_value}"
}

confirm() {
    local prompt="$1"
    local default_answer="${2:-N}"
    local default_value='no'

    if [[ "$default_answer" == "Y" || "$default_answer" == "y" ]]; then
        default_value='yes'
    fi

    if [[ "$AUTO_YES" -eq 1 ]]; then
        return 0
    fi

    if [[ "$NON_INTERACTIVE" -eq 1 ]]; then
        [[ "$default_value" == "yes" ]]
        return
    fi

    if [[ -z "$PROMPT_FD" && ! -t 0 ]]; then
        if [[ "$PROMPT_MODE_NOTIFIED" -eq 0 ]]; then
            warn "No interactive terminal detected. Optional steps will use safe defaults."
            PROMPT_MODE_NOTIFIED=1
        fi
        [[ "$default_value" == "yes" ]]
        return
    fi

    prompt_line "$prompt" "$default_value"

    case "$USER_INPUT" in
    y | Y | yes | YES | Yes)
        return 0
        ;;
    *)
        return 1
        ;;
    esac
}

copy_array() {
    local array_name="$1"
    eval "array_copy=(\"\${${array_name}[@]}\")"
}

contains_number() {
    local needle="$1"
    shift

    while [[ $# -gt 0 ]]; do
        if [[ "$1" == "$needle" ]]; then
            return 0
        fi
        shift
    done

    return 1
}

print_package_list() {
    local array_name="$1"
    local i

    copy_array "$array_name"

    if [[ ${#array_copy[@]} -eq 0 ]]; then
        return
    fi

    for i in "${!array_copy[@]}"; do
        printf '  [%d] %s\n' "$((i + 1))" "${array_copy[$i]}"
    done
}

select_packages() {
    local array_name="$1"
    local excludes="$2"
    local token
    local i
    local excluded_numbers=''
    local package=''
    local package_number=0

    selected_packages=()
    copy_array "$array_name"

    for token in $excludes; do
        case "$token" in
        '' | *[!0-9]*)
            warn "Ignoring invalid exclusion: $token"
            ;;
        *)
            excluded_numbers+=" $token"
            ;;
        esac
    done

    for i in "${!array_copy[@]}"; do
        package="${array_copy[$i]}"
        package_number=$((i + 1))
        if contains_number "$package_number" $excluded_numbers; then
            info "Skipping $package"
        else
            selected_packages+=("$package")
        fi
    done
}

detect_linux_distro() {
    local detected_id=''
    local detected_like=''

    [[ -r /etc/os-release ]] || die "Unable to read /etc/os-release."

    # shellcheck disable=SC1091
    . /etc/os-release

    detected_id="${ID:-}"
    detected_like="${ID_LIKE:-}"

    case "$detected_id" in
    ubuntu | debian | fedora | arch)
        DISTRO="$detected_id"
        ;;
    *)
        case " $detected_like " in
        *" ubuntu "* | *" debian "*)
            DISTRO='ubuntu'
            ;;
        *" fedora "*)
            DISTRO='fedora'
            ;;
        *" arch "*)
            DISTRO='arch'
            ;;
        *)
            die "Unsupported Linux distribution: ${detected_id:-unknown}"
            ;;
        esac
        ;;
    esac
}

ensure_homebrew() {
    local install_url='https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh'

    if command -v brew >/dev/null 2>&1; then
        info "Homebrew is already installed."
    else
        info "Installing Homebrew from the official repository."
        if [[ "$DRY_RUN" -eq 1 ]]; then
            printf '[dry-run] /bin/bash -c "$(curl -fsSL %s)"\n' "$install_url"
        else
            run_cmd /bin/bash -c "$(curl -fsSL "$install_url")"
        fi
    fi

    if [[ -x /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi

    if ! command -v brew >/dev/null 2>&1; then
        if [[ "$DRY_RUN" -eq 1 ]]; then
            warn "Homebrew is not installed, but dry-run mode will continue."
            return 0
        fi
        die "Homebrew installation failed."
    fi
}

configure_package_manager() {
    case "$OS_NAME" in
    Darwin)
        DISTRO='darwin'
        ensure_homebrew
        UPDATE_CMD=(brew update)
        FORMULA_CMD=(brew install)
        CASK_CMD=(brew install --cask)
        FONT_CMD=(brew install --cask)
        BUILD_TOOLS_CMD=()
        ;;
    Linux)
        detect_linux_distro
        case "$DISTRO" in
        ubuntu | debian)
            UPDATE_CMD=(sudo apt update)
            FORMULA_CMD=(sudo apt install -y)
            CASK_CMD=("${FORMULA_CMD[@]}")
            FONT_CMD=("${FORMULA_CMD[@]}")
            BUILD_TOOLS_CMD=(sudo apt install -y build-essential)
            ;;
        fedora)
            UPDATE_CMD=(sudo dnf makecache)
            FORMULA_CMD=(sudo dnf install -y)
            CASK_CMD=("${FORMULA_CMD[@]}")
            FONT_CMD=("${FORMULA_CMD[@]}")
            BUILD_TOOLS_CMD=(sudo dnf groupinstall -y "Development Tools")
            ;;
        arch)
            UPDATE_CMD=(sudo pacman -Syu --noconfirm)
            FORMULA_CMD=(sudo pacman -S --noconfirm --needed)
            CASK_CMD=("${FORMULA_CMD[@]}")
            FONT_CMD=("${FORMULA_CMD[@]}")
            BUILD_TOOLS_CMD=(sudo pacman -S --noconfirm --needed base-devel)
            ;;
        *)
            die "Unsupported platform: $DISTRO"
            ;;
        esac
        ;;
    *)
        die "Unsupported operating system: $OS_NAME"
        ;;
    esac
}

update_package_manager() {
    if [[ ${#UPDATE_CMD[@]} -eq 0 ]]; then
        return
    fi

    if [[ "$DISTRO" == "arch" ]]; then
        print_section "Synchronizing package databases and upgrading the system"
    else
        print_section "Updating package metadata"
    fi
    run_cmd "${UPDATE_CMD[@]}"
}

install_build_tools() {
    if [[ ${#BUILD_TOOLS_CMD[@]} -eq 0 ]]; then
        return
    fi

    print_section "Installing build tools"
    run_cmd "${BUILD_TOOLS_CMD[@]}"
}

install_bootstrap_packages() {
    local -a packages=()

    case "$DISTRO" in
    ubuntu | debian)
        packages=("git" "curl" "wget" "manpages" "manpages-dev")
        ;;
    fedora)
        packages=("git" "curl" "wget" "man-pages")
        ;;
    arch)
        packages=("git" "curl" "wget" "man-pages" "man-db")
        ;;
    darwin)
        packages=()
        ;;
    esac

    if [[ ${#packages[@]} -eq 0 ]]; then
        return
    fi

    print_section "Installing required bootstrap packages"
    run_cmd "${FORMULA_CMD[@]}" "${packages[@]}"
}

ensure_brew_font_tap() {
    if [[ "$DISTRO" != "darwin" || "$BREW_FONT_TAP_READY" -eq 1 ]]; then
        return
    fi

    info "Ensuring Homebrew font casks are available."
    run_cmd brew tap homebrew/cask-fonts
    BREW_FONT_TAP_READY=1
}

install_package() {
    local kind="$1"
    local package="$2"

    case "$kind" in
    formula)
        run_cmd "${FORMULA_CMD[@]}" "$package"
        ;;
    cask)
        run_cmd "${CASK_CMD[@]}" "$package"
        ;;
    font)
        ensure_brew_font_tap
        run_cmd "${FONT_CMD[@]}" "$package"
        ;;
    *)
        die "Unknown package install kind: $kind"
        ;;
    esac
}

install_group() {
    local title="$1"
    local array_name="$2"
    local kind="$3"
    local default_answer="${4:-N}"
    local prompt_suffix='y/N'
    local excludes=''
    local package=''

    copy_array "$array_name"

    if [[ ${#array_copy[@]} -eq 0 ]]; then
        return
    fi

    if [[ "$default_answer" == "Y" || "$default_answer" == "y" ]]; then
        prompt_suffix='Y/n'
    fi

    print_section "$title"
    print_package_list "$array_name"

    if ! confirm "Install this group? [${prompt_suffix}] " "$default_answer"; then
        info "Skipping $title."
        return
    fi

    prompt_line "Enter package numbers to exclude, or press Enter to install everything in this group: " ""
    excludes="$USER_INPUT"
    select_packages "$array_name" "$excludes"

    if [[ ${#selected_packages[@]} -eq 0 ]]; then
        warn "Nothing selected for $title."
        return
    fi

    for package in "${selected_packages[@]}"; do
        info "Installing $package"
        if ! install_package "$kind" "$package"; then
            FAILED_PACKAGES+=("$package")
            warn "Failed to install $package"
        fi
    done
}

install_zsh_and_plugins() {
    local plugin_dir=''
    local zsh_path=''
    local plugin=''
    local url=''
    local target=''
    local desktop_data_home=''
    local -a zsh_plugins=(
        "zsh-autosuggestions|https://github.com/zsh-users/zsh-autosuggestions"
        "zsh-syntax-highlighting|https://github.com/zsh-users/zsh-syntax-highlighting"
        "fzf-tab|https://github.com/Aloxaf/fzf-tab"
        "powerlevel10k|https://github.com/romkatv/powerlevel10k"
    )
    local entry=''

    print_section "Optional zsh setup"

    if ! confirm "Install zsh and common plugins? [y/N] " "N"; then
        info "Skipping zsh setup."
        return
    fi

    if ! install_package formula "zsh"; then
        FAILED_PACKAGES+=("zsh")
        warn "Failed to install zsh. Skipping plugin setup."
        return
    fi

    desktop_data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
    plugin_dir="${desktop_data_home}/zsh/plugins"
    run_cmd mkdir -p "$plugin_dir"

    for entry in "${zsh_plugins[@]}"; do
        plugin="${entry%%|*}"
        url="${entry#*|}"
        target="${plugin_dir}/${plugin}"

        if [[ -d "$target/.git" ]]; then
            info "Updating $plugin"
            if ! run_cmd git -C "$target" pull --ff-only; then
                warn "Failed to update $plugin"
            fi
        elif [[ -e "$target" ]]; then
            warn "Skipping $plugin because $target already exists and is not a Git repository."
        else
            info "Cloning $plugin"
            if ! run_cmd git clone --depth=1 "$url" "$target"; then
                warn "Failed to clone $plugin"
            fi
        fi
    done

    if ! confirm "Set zsh as your default shell now? [y/N] " "N"; then
        info "Leaving the default shell unchanged."
        return
    fi

    if ! command -v zsh >/dev/null 2>&1; then
        warn "zsh is not installed, so the default shell cannot be changed."
        return
    fi

    zsh_path="$(command -v zsh)"

    if [[ -r /etc/shells ]] && ! grep -qF "$zsh_path" /etc/shells; then
        info "Adding $zsh_path to /etc/shells"
        if [[ "$DRY_RUN" -eq 1 ]]; then
            printf '[dry-run] printf %q | sudo tee -a /etc/shells >/dev/null\n' "${zsh_path}\n"
        else
            printf '%s\n' "$zsh_path" | sudo tee -a /etc/shells >/dev/null
        fi
    fi

    if ! run_cmd chsh -s "$zsh_path"; then
        warn "Failed to change the default shell. Run this manually later: chsh -s $zsh_path"
    fi
}

create_symlink() {
    local src="$1"
    local dst="$2"
    local backup_path=''
    local current_target=''

    if [[ ! -e "$src" && ! -L "$src" ]]; then
        warn "Skipping $dst because the source does not exist: $src"
        SKIPPED_LINKS+=("$dst")
        return
    fi

    run_cmd mkdir -p "$(dirname "$dst")"

    if [[ -L "$dst" ]]; then
        current_target="$(readlink "$dst" 2>/dev/null || true)"
        if [[ "$current_target" == "$src" ]]; then
            info "Link already exists: $dst"
            return
        fi
    fi

    if [[ -e "$dst" && ! -L "$dst" ]]; then
        backup_path="${dst}.bak.$(date +%Y%m%d%H%M%S)"
        info "Backing up $dst to $backup_path"
        run_cmd mv "$dst" "$backup_path"
    fi

    run_cmd ln -sfn "$src" "$dst"
    info "Linked $dst -> $src"
}

link_group() {
    local array_name="$1"
    local entry=''
    local src_rel=''
    local dst=''

    copy_array "$array_name"

    for entry in "${array_copy[@]}"; do
        src_rel="${entry%%|*}"
        dst="${entry#*|}"
        create_symlink "${DOTFILES_DIR}/${src_rel}" "$dst"
    done
}

link_dotfiles() {
    local desktop_name="${XDG_CURRENT_DESKTOP:-}"

    print_section "Optional dotfile linking"

    if [[ ! -d "$DOTFILES_DIR" ]]; then
        warn "Dotfiles directory not found: $DOTFILES_DIR"
        warn "Skipping symlink setup."
        return
    fi

    if ! confirm "Create symlinks from $DOTFILES_DIR? [y/N] " "N"; then
        info "Skipping dotfile linking."
        return
    fi

    link_group "dotfile_links"

    if [[ "$OS_NAME" == "Linux" && "$desktop_name" =~ ([Kk][Dd][Ee]|[Pp]lasma) ]]; then
        info "KDE or Plasma desktop detected. Linking KDE-specific files."
        link_group "kde_dotfile_links"
    fi
}

print_arch_manual_apps_note() {
    if [[ "$DISTRO" != "arch" || ${#arch_manual_apps[@]} -eq 0 ]]; then
        return
    fi

    print_section "Arch manual installs"
    info "These packages usually require an AUR helper and are not installed automatically:"
    print_package_list "arch_manual_apps"
    info "Install them later with yay, paru, or your preferred AUR workflow."
}

print_summary() {
    local package=''
    local link=''

    print_section "Summary"
    printf 'Platform: %s\n' "$DISTRO"

    if [[ "$DRY_RUN" -eq 1 ]]; then
        printf 'Mode: dry-run only, no changes were made.\n'
    fi

    if [[ ${#FAILED_PACKAGES[@]} -eq 0 ]]; then
        printf 'Package install failures: none\n'
    else
        printf 'Package install failures:\n'
        for package in "${FAILED_PACKAGES[@]}"; do
            printf '  - %s\n' "$package"
        done
    fi

    if [[ ${#SKIPPED_LINKS[@]} -gt 0 ]]; then
        printf 'Skipped links:\n'
        for link in "${SKIPPED_LINKS[@]}"; do
            printf '  - %s\n' "$link"
        done
    fi
}

main() {
    parse_args "$@"
    setup_prompt_fd
    trap close_prompt_fd EXIT

    print_section "Environment"
    info "Detected OS: $OS_NAME"
    info "Dotfiles directory: $DOTFILES_DIR"

    configure_package_manager

    print_section "Platform"
    info "Using distro profile: $DISTRO"

    update_package_manager
    install_build_tools
    install_bootstrap_packages
    install_zsh_and_plugins

    install_group "Shared CLI tools" "cli_common" "formula" "Y"

    case "$DISTRO" in
    arch)
        install_group "Arch CLI extras" "cli_arch" "formula" "Y"
        install_group "Arch GUI apps" "gui_arch" "formula" "N"
        install_group "Arch fonts" "fonts_arch" "font" "N"
        print_arch_manual_apps_note
        ;;
    ubuntu | debian)
        install_group "Ubuntu and Debian CLI extras" "cli_ubuntu" "formula" "Y"
        install_group "Ubuntu and Debian GUI apps" "gui_ubuntu" "formula" "N"
        install_group "Ubuntu and Debian fonts" "fonts_ubuntu" "font" "N"
        ;;
    fedora)
        install_group "Fedora CLI extras" "cli_fedora" "formula" "Y"
        install_group "Fedora GUI apps" "gui_fedora" "formula" "N"
        install_group "Fedora fonts" "fonts_fedora" "font" "N"
        ;;
    darwin)
        install_group "macOS CLI extras" "cli_darwin" "formula" "Y"
        install_group "macOS GUI apps" "gui_darwin" "cask" "N"
        install_group "macOS fonts" "fonts_darwin" "font" "N"
        ;;
    esac

    link_dotfiles
    print_summary
}

main "$@"
