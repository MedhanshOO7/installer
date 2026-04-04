# lazy-installer

`lazy-installer` An interactive setup script for macOS, Arch Linux, Ubuntu or Debian, and Fedora. It installs common CLI tools, optional GUI apps and fonts, optional `zsh` plugins, and can symlink dotfiles from a directory you choose.

## Run locally

```bash
bash installer/install.sh
```

## Useful options

Preview the work without changing anything:

```bash
bash installer/install.sh --dry-run
```

Enable debug logging:

```bash
bash installer/install.sh --debug
```

Use a custom dotfiles directory:

```bash
bash installer/install.sh --dotfiles-dir "$HOME/path/to/dotfiles"
```

Run without prompts and use the safe defaults:

```bash
bash installer/install.sh --non-interactive
```

Accept every optional prompt automatically:

```bash
bash installer/install.sh --yes
```

## Remote execution

If you publish the script at a raw URL, pass options after `-s --`:

```bash
curl -fsSL <raw-script-url> | bash -s -- --dry-run
```

## Notes

- Run the installer from a real terminal. It reads prompts from `/dev/tty`, which also makes `curl | bash` style usage behave correctly.
- On macOS, GUI apps and fonts are installed through Homebrew casks.
- On Arch, packages that usually require an AUR helper are listed for manual installation instead of failing mid-run.
- Dotfile linking is skipped when the source directory or source file does not exist.
