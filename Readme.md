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
my personal *dotfiles and system* setup — built to get any machine feeling like home as fast as possible. one script, batteries included.

# what's this?
this is everything i use day to day — shell config, editor setup, fonts, CLI tools, GUI apps, the whole thing. clone it on a fresh machine, run the script, grab a coffee, done.
managed with a git repo so files live directly in $HOME with no extra tooling needed.

# why?
i got tired of spending the first few hours on any new machine just getting my environment to feel right before i could write a single line of code. tweaking fonts, reinstalling plugins, copy-pasting configs from old machines — exhausting.
this exists so i can skip all that and just start building.

# supported systems
|distro |status|
|:--|:--|
|arch linux + derivatives (manjaro, endeavourOS etc.)|✅ fully supported| 
|ubuntu / debian + derivatives |✅ supported |
|fedora + derivatives|✅ supported|
|macOS |✅ supported|

# what gets installed

- **CLI tools** — neovim, vim, tmux, fzf, ripgrep, bat, eza, btop, fastfetch, zoxide, glow, tldr and more
- **shell** — zsh + oh-my-zsh, powerlevel10k, autosuggestions, syntax highlighting, fzf-tab
- **GUI apps (linux only)** — kitty, obsidian, brave, firefox, zen browser, telegram, obs, vlc, kdenlive, rofi and more
- **fonts** — JetBrains Mono, FiraCode, Hack, Meslo, Cascadia Code (all nerd font variants)
- **KDE extras** — kvantum, konsole, kwin rules, plasma config (auto-detected, only runs on KDE)


# install

make sure nstall

make sure **git** and **curl** are installed first

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/MedhanshOO7/installer/main/install.sh 
```
the script will:

- detect your OS and distro automatically
- ask before installing each group of packages (you can exclude things you don't want)
- clone my dotfiles repo
- check out all config files directly into $HOME and curl are installed first

## Run locally

```bash
bash installer/install.sh
```

```bash
curl -fsSL https://raw.githubusercontent.com/MedhanshOO7/installer/main/install.sh | bash 
```

## Useful options

- Enable debug logging:

```bash
bash installer/install.sh --debug
```

```bash
curl -fsSL https://raw.githubusercontent.com/MedhanshOO7/installer/main/install.sh | bash -s -- --debug
```
