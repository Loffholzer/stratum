#!/usr/bin/env bash

# =========================================
# 📄 DATEI: 00_packages.sh
# 💡 ZWECK: Zentrale Paketlisten für den Base-Installer
# =========================================

# =========================================
# 📦 Funktion: load_base_packages
# -----------------------------------------
# Zweck: Exportiert globale Arrays für die Paketinstallation
# Aufgabe: Trennt die reine Datenhaltung von der Installationslogik
# =========================================
load_base_packages() {
    # --- Kernsystem (08_base.sh) ---
    export BASE_PKGS=(
        base base-devel linux linux-lts linux-headers linux-lts-headers
        linux-firmware btrfs-progs micro git wget curl networkmanager
        terminus-font memtest86+-efi pciutils rust
    )

    # --- Bootloader (09_chroot_env.sh) ---
    export BOOTLOADER_PKGS=(limine efibootmgr)

    # --- Benutzer, UX & Tools (10_chroot_users.sh) ---
    export SUDO_PKGS=(sudo)
    export UX_PKGS=(fish starship zoxide fastfetch)
    export CLI_TOOLS_PKGS=(eza bat btop dialog)
    export SSH_PKGS=(openssh)
    export FONTS_XDG_PKGS=(noto-fonts noto-fonts-emoji ttf-liberation xdg-user-dirs)

    # --- Dienste & Wartung (11_chroot_services.sh) ---
    export ZRAM_PKGS=(zram-generator)
    export SNAPPER_PKGS=(snapper)
    export NETWORK_SERVICES_PKGS=(avahi nss-mdns firewalld)
}