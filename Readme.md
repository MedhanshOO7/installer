```text
                        ┌──────────────────────────────────────────────────────┐
                        │                                                      │
                        │   ██████╗ ███████╗                                   │
                        │  ██╔════╝ ██╔════╝                                   │
                        │  ██║      ███████╗                                   │
                        │  ██║      ╚════██║                                   │
                        │  ╚██████╗ ███████║                                   │
                        │   ╚═════╝ ╚══════╝                                   │
                        │                                                      │
                        │               ██╗   ██╗███╗   ██╗██╗██╗  ██╗         │
                        │               ██║   ██║████╗  ██║██║╚██╗██╔╝         │
                        │               ██║   ██║██╔██╗ ██║██║ ╚███╔╝          │
                        │               ██║   ██║██║╚██╗██║██║ ██╔██╗          │
                        │               ╚██████╔╝██║ ╚████║██║██╔╝ ██╗         │
                        │                ╚═════╝ ╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝         │
                        │                                                      │
                        │                      dotfiles & system config        │
                        │                                  — medAnshOO7        │
                        │                                                      │
                        └──────────────────────────────────────────────────────┘
```

# cs's UNIX 

My personal *dotfiles and system* setup — built to get any machine feeling like home as fast as possible. One script, batteries included.

## Overview

**What's this?**  
This is everything I use day-to-day: shell config, editor setup, fonts, CLI tools, GUI apps, the whole thing. Clone it on a fresh machine, run the script, grab a coffee, done. It is managed with a git repo so files live directly in `$HOME` with no extra tooling needed.

**Why?**  
I got tired of spending the first few hours on any new machine just getting my environment to feel right before I could write a single line of code. Tweaking fonts, reinstalling plugins, copy-pasting configs from old machines — exhausting. This exists so I can skip all that and just start building.

---

## Supported Systems

| Distro | Status |
| :--- | :--- |
| **Arch Linux** + derivatives (Manjaro, EndeavourOS, etc.) | ✅ Fully supported | 
| **Ubuntu / Debian** + derivatives | ✅ Supported |
| **Fedora** + derivatives | ✅ Supported |
| **macOS** | ✅ Supported |

---

## What Gets Installed

- **CLI Tools:** `neovim`, `vim`, `tmux`, `fzf`, `ripgrep`, `bat`, `eza`, `btop`, `fastfetch`, `zoxide`, `glow`, `tldr`, and more.
- **Shell:** `zsh` + `oh-my-zsh`, `powerlevel10k`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, `fzf-tab`.
- **GUI Apps:** `kitty`, `obsidian`, `brave`, `firefox`, `zen browser`, `telegram`, `obs`, `vlc`, `kdenlive`, `rofi`, and more.
- **Fonts:** JetBrains Mono, FiraCode, Hack, Meslo, Cascadia Code (all Nerd Font variants).
- **KDE Extras:** Kvantum, Konsole, KWin rules, Plasma config (auto-detected, only runs on KDE).

---

## Installation

**Prerequisites:** Make sure **`git`** and **`curl`** are installed on your system before proceeding.

### 1. One-Line Install

You can install directly from GitHub using the following command:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/MedhanshOO7/installer/main/install.sh)"
```

**The script will:**
- Detect your OS and distro automatically.
- Ask before installing each group of packages (you can exclude things you don't want).
- Clone the dotfiles repository.
- Symlink all config files directly into your `$HOME` directory.

### 2. Run Locally

If you prefer to clone the repository and run it locally:

```bash
# Execute the downloaded script
bash installer/install.sh

# Or pipe it directly
curl -fsSL https://raw.githubusercontent.com/MedhanshOO7/installer/main/install.sh | bash 
```

---

## Useful Options

You can append options to the script to modify its behavior:

- **Enable debug logging:**
  ```bash
  bash installer/install.sh --debug
  
  # Or via curl:
  curl -fsSL https://raw.githubusercontent.com/MedhanshOO7/installer/main/install.sh | bash -s -- --debug
  ```
