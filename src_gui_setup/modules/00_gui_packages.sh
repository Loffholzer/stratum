#!/usr/bin/env bash

# =========================================
# 📄 DATEI: 00_gui_packages.sh
# 💡 ZWECK: Zentrale Paketlisten für das GUI Setup
# =========================================

# --- Audio & Gaming (Desktop-übergreifend) ---
export AUDIO_PKGS=(pipewire pipewire-alsa pipewire-audio pipewire-jack pipewire-pulse gst-plugin-pipewire wireplumber)
export GAMING_PKGS=(steam lutris wine-staging gamemode lib32-gamemode mangohud lib32-mangohud protonup-qt)

# --- KDE Plasma ---
# plasma-meta zieht die gesamte Umgebung.
export KDE_PKGS=(plasma-meta sddm konsole dolphin dolphin-plugins ark kate okular gwenview kdegraphics-thumbnailers kimageformats ffmpegthumbs xdg-desktop-portal-kde)
export KDE_OOTB_PKGS=(firefox thunderbird ufw gufw)

# --- COSMIC Desktop ---
# COSMIC ist sehr modular, wir brauchen Session, Greeter, Applets und Core-Apps.
export COSMIC_PKGS=(cosmic-session cosmic-greeter cosmic-applets cosmic-workspaces cosmic-bg cosmic-comp cosmic-panel cosmic-osd cosmic-term cosmic-files cosmic-edit cosmic-randr xdg-desktop-portal-cosmic)
export COSMIC_OOTB_PKGS=(firefox thunderbird gnome-keyring evince file-roller ufw gufw)