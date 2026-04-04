# lazy-installer

`lazy-installer` An interactive setup script for macOS, Arch Linux, Ubuntu or Debian, and Fedora. It installs common CLI tools, optional GUI apps and fonts, optional `zsh` plugins, and can symlink dotfiles from a directory you choose.

## Run locally

```bash
bash installer/install.sh
```

```bash
curl -fsSL https://raw.githubusercontent.com/MedhanshOO7/installer/main/install.sh | bash 
```

## Useful options

- Preview the work without changing anything:

```bash
bash installer/install.sh --dry-run
```

```bash
curl -fsSL https://raw.githubusercontent.com/MedhanshOO7/installer/main/install.sh | bash -s -- --dry-run
```

- Enable debug logging:

```bash
bash installer/install.sh --debug
```

```bash
curl -fsSL https://raw.githubusercontent.com/MedhanshOO7/installer/main/install.sh | bash -s -- --debug
```

- Use a custom dotfiles directory:

```bash
bash installer/install.sh --dotfiles-dir "$HOME/path/to/dotfiles"
```

```bash
curl -fsSL https://raw.githubusercontent.com/MedhanshOO7/installer/main/install.sh | bash -s -- --debug
  
```

- Run without prompts and use the safe defaults:

```bash
bash installer/install.sh --non-interactive
```

```bash
curl -fsSL https://raw.githubusercontent.com/MedhanshOO7/installer/main/install.sh | bash -s -- --debug
```

- Accept every optional prompt automatically:

```bash
bash installer/install.sh --yes
```

```bash
curl -fsSL https://raw.githubusercontent.com/MedhanshOO7/installer/main/install.sh | bash -s -- --yes
```

## Remote execution

- If you publish the script at a raw URL, pass options after `-s --`:

```bash
curl -fsSL https://raw.githubusercontent.com/MedhanshOO7/installer/main/install.sh | bash -s -- --dry-run
```

## Notes

- Run the installer from a real terminal. It reads prompts from `/dev/tty`, which also makes `curl | bash` style usage behave correctly.
- On macOS, GUI apps and fonts are installed through Homebrew casks.
- On Arch, packages that usually require an AUR helper are listed for manual installation instead of failing mid-run.
- Dotfile linking is skipped when the source directory or source file does not exist.
