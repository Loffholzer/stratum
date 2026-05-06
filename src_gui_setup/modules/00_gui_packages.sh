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
export KDE_OOTB_PKGS=(firefox thunderbird cups ufw gufw)

# --- COSMIC Desktop ---
# COSMIC ist sehr modular, wir brauchen Session, Greeter, Applets und Core-Apps.
export COSMIC_PKGS=(cosmic-session cosmic-greeter cosmic-applets cosmic-workspaces cosmic-bg cosmic-comp cosmic-panel cosmic-osd cosmic-files cosmic-randr xdg-desktop-portal-cosmic)
export COSMIC_OOTB_PKGS=(firefox thunderbird cups gnome-keyring evince file-roller alacritty ufw gufw)

# --- GNOME Desktop ---
export GNOME_PKGS=(gnome gdm xdg-desktop-portal-gnome)
export GNOME_OOTB_PKGS=(firefox thunderbird cups ufw gufw)

# --- XFCE Desktop (LowMem) ---
export XFCE_PKGS=(xfce4 xfce4-goodies lightdm lightdm-gtk-greeter xdg-desktop-portal-xapp)
export XFCE_OOTB_PKGS=(firefox thunderbird cups ufw gufw)

# --- Zusätzliche Anwendungen ---
export LIBREOFFICE_PKGS=(libreoffice-still)