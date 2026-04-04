#!/usr/bin/env bash
# bootstrap.sh — run inside container before your install script

DISTRO="${1:-}"

case "$DISTRO" in
arch)
    pacman -Syu --noconfirm
    pacman -S --noconfirm sudo passwd curl git base-devel
    ;;
fedora)
    dnf install -y sudo passwd curl git
    ;;
ubuntu)
    apt update
    apt install -y sudo passwd curl git build-essential
    ;;
*)
    printf 'Usage: bootstrap.sh arch|fedora|ubuntu\n'
    exit 1
    ;;
esac

# common setup
useradd -m -s /bin/bash testuser
echo "testuser:password" | chpasswd
echo "testuser ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers
printf 'Bootstrap done. Run: su - testuser\n'
