#!/usr/bin/env bash

# =========================================
# 📄 Modul: 00_gui_packages.sh
# -----------------------------------------
# Zweck: Zentrale Konfiguration aller Software-Pakete für die GUI
# Aufgabe: Ermöglicht dem User ein einfaches Anpassen der Installation
# =========================================

load_gui_packages() {

    # =========================================
    # 🌍 GEMEINSAME PAKETE (Für alle Desktops)
    # =========================================
    declare -g -a AUDIO_PKGS=(
        "pipewire"
        "pipewire-audio"
        "pipewire-pulse"
        "pipewire-alsa"
        "pipewire-jack"
        "wireplumber"
    )

    declare -g -a GAMING_PKGS=(
        "steam"
        "lutris"
        "wine-staging"
        "winetricks"
        "gamemode"
        "lib32-gamemode"
        "mangohud"
        "lib32-mangohud"
        "protonup-qt"
        "vulkan-tools"
    )

    # =========================================
    # 🔵 KDE PLASMA PAKETE
    # =========================================
    declare -g -a KDE_PKGS=(
        "plasma-desktop"            # Minimales Plasma-Desktop-Metapaket
        "sddm"                      # Empfohlener Display-Manager
        "konsole"                   # Standard-Terminal
        "dolphin"                   # Standard-Dateimanager
        "power-profiles-daemon"     # Energieprofile
        "networkmanager-qt"         # GUI-Applet für NetworkManager
        "xdg-desktop-portal-kde"    # Portal für Flatpaks
        "xorg-xwayland"             # X11-Kompatibilitätsschicht
        "qt6-wayland"               # Wayland-Unterstützung für Qt6
    )

    declare -g -a KDE_OOTB_PKGS=(
        "firefox" "thunderbird" "noto-fonts" "noto-fonts-emoji" "ttf-liberation" 
        "ttf-jetbrains-mono-nerd" "ark" "unzip" "unrar" "zip" "p7zip" "okular" 
        "gwenview" "kimageformats" "qt6-imageformats" "haruna" "ffmpeg" 
        "gst-plugins-good" "gst-plugins-bad" "gst-plugins-ugly" "gst-libav" 
        "discover" "packagekit-qt6" "flatpak" "flatseal" "kcalc" "spectacle" 
        "kinfocenter" "partitionmanager" "isoimagewriter" "cups" "print-manager" 
        "gnome-keyring" "seahorse"
    )

    # =========================================
    # 🟠 COSMIC DESKTOP PAKETE
    # =========================================
    declare -g -a COSMIC_PKGS=(
        "cosmic"                    # Metapaket für alle COSMIC-Komponenten
        "cosmic-greeter"            # Offizieller Login-Manager
        "xdg-desktop-portal-cosmic" # Portal für Flatpaks
        "xdg-desktop-portal-gtk"    # Fallback-Portal für GTK
        "xorg-xwayland"             # X11-Kompatibilitätsschicht
        "polkit"                    # Rechteverwaltung
        "power-profiles-daemon"     # Energieprofile
    )

    declare -g -a COSMIC_OOTB_PKGS=(
        "firefox" "thunderbird" "noto-fonts" "noto-fonts-emoji" "ttf-liberation" 
        "ttf-jetbrains-mono-nerd" "file-roller" "unzip" "unrar" "zip" "p7zip" 
        "evince" "loupe" "celluloid" "ffmpeg" "gst-plugins-good" "gst-plugins-bad" 
        "gst-plugins-ugly" "gst-libav" "flatpak" "flatseal" "gnome-calculator" 
        "gnome-disk-utility" "popsicle" "cups" "system-config-printer" 
        "gnome-keyring" "seahorse"
    )
}