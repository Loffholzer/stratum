#!/usr/bin/env bash

# =========================================
# 📄 DATEI: 02_templates.sh
# 💡 ZWECK: Zentrale Konfigurations-Templates
# =========================================

# =========================================
# 📦 Funktion: load_templates
# -----------------------------------------
# Zweck: Lädt große Textblöcke und Configs in den Speicher
# Aufgabe: Hält die Logik-Module sauber und wartbar
# =========================================
load_templates() {
    # =========================================
    # 📄 Template: ZRAM Configuration
    # =========================================
    export TPL_ZRAM_CONF="[zram0]
zram-size = ram / 2
compression-algorithm = zstd"

    # =========================================
    # 📄 Template: Fish Shell Configuration
    # =========================================
    export TPL_FISH_CONFIG="set -g fish_greeting

if status is-interactive
    if type -q fastfetch; fastfetch; end
end

if type -q starship; starship init fish | source; end
if type -q zoxide; zoxide init fish | source; end

alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first'
alias la='eza -laa --icons --group-directories-first'
alias cat='bat --theme=\"Monokai Extended\"'
alias top='btop'
alias cd='z'
alias update='sudo pacman -Syu'"

    # =========================================
    # 📄 Template: Nano Virtuoso Configuration
    # =========================================
    export TPL_NANO_CONFIG="
set linenumbers
set mouse
set autoindent
set tabsize 4
set tabstospaces
set softwrap
set indicator
set minibar

include \"/usr/share/nano/*.nanorc\""

    # =========================================
    # 📄 Template: Desktop Handoff Skript
    # =========================================
    export TPL_DESKTOP_HANDOFF="#!/usr/bin/env bash

BLUE='\033[1;34m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
NC='\033[0m'

clear
echo -e \"\${BLUE}=========================================\${NC}\"
echo -e \"\${CYAN} 🚀 Willkommen in deinem neuen Arch Linux!\${NC}\"
echo -e \"\${BLUE}=========================================\${NC}\n\"

echo \"Dies ist das Post-Install-Skript für die grafische Oberfläche (GUI).\"
echo

read -rp \"Möchtest du das Desktop-Setup jetzt starten? (j/n): \" start_choice
if [[ \"\${start_choice,,}\" =~ ^(j|ja|y|yes)$ ]]; then
    echo -e \"\n\${GREEN}[OK] Desktop-Setup wird geladen...\${NC}\"
    sleep 2

    echo
    read -rp \"Setup abgeschlossen. Skript löschen? (j/n): \" del_choice
    if [[ \"\${del_choice,,}\" =~ ^(j|ja|y|yes)$ ]]; then
        rm -- \"\$0\"
        echo -e \"\${GREEN}[OK] Skript entfernt.\${NC}\"
    fi
else
    echo -e \"\nSetup übersprungen.\"
fi"

    # =========================================
    # 📄 Template: Sudoers AUR Build (Temporär)
    # =========================================
    export TPL_SUDOERS_AUR_BUILD="%wheel ALL=(ALL) NOPASSWD: ALL"

    # =========================================
    # 📄 Template: Limine Config (LUKS)
    # =========================================
    export TPL_LIMINE_LUKS="timeout: 3
remember_last_entry: yes
default_entry: 1

/Arch Linux (Mainline)
    protocol: linux
    kernel_path: boot():/vmlinuz-linux
    module_path: boot():/initramfs-linux.img
    cmdline: cryptdevice=UUID={{ROOT_UUID}}:cryptroot root=/dev/mapper/cryptroot rootflags=subvol=@ rw quiet loglevel=3 udev.log_level=3

/Arch Linux (LTS)
    protocol: linux
    kernel_path: boot():/vmlinuz-linux-lts
    module_path: boot():/initramfs-linux-lts.img
    cmdline: cryptdevice=UUID={{ROOT_UUID}}:cryptroot root=/dev/mapper/cryptroot rootflags=subvol=@ rw quiet loglevel=3 udev.log_level=3"

    # =========================================
    # 📄 Template: Limine Config (Standard)
    # =========================================
    export TPL_LIMINE_STD="timeout: 3
remember_last_entry: yes
default_entry: 1

/Arch Linux (Mainline)
    protocol: linux
    kernel_path: uuid({{ROOT_UUID}}):/@/boot/vmlinuz-linux
    module_path: uuid({{ROOT_UUID}}):/@/boot/initramfs-linux.img
    cmdline: root=UUID={{ROOT_UUID}} rootflags=subvol=@ rw quiet splash

/Arch Linux (LTS)
    protocol: linux
    kernel_path: uuid({{ROOT_UUID}}):/@/boot/vmlinuz-linux-lts
    module_path: uuid({{ROOT_UUID}}):/@/boot/initramfs-linux-lts.img
    cmdline: root=UUID={{ROOT_UUID}} rootflags=subvol=@ rw quiet splash"

    # =========================================
    # 📄 Template: Hosts File
    # =========================================
    export TPL_HOSTS="127.0.0.1   localhost
::1         localhost
127.0.1.1   {{HOSTNAME}}.localdomain {{HOSTNAME}}"

    # =========================================
    # 📄 Template: Snapper Pacman Hook
    # =========================================
    export TPL_PACMAN_SNAPPER="[Trigger]
Operation = Install
Operation = Upgrade
Operation = Remove
Type = Package
Target = *

[Action]
Description = Erstelle BTRFS Snapshot (Pre-Transaction)...
Depends = snapper
When = PreTransaction
Exec = /usr/bin/snapper -c root create -d \"Pacman Pre-Transaction\""
}

