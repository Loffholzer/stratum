#!/bin/bash
# ==============================================================================
# STRATUM - ARCH LINUX DEPLOYMENT FRAMEWORK
# Modul: GUI Handoff Script (Desktop Setup)
# ==============================================================================

set -e

echo "=============================================================================="
echo " Stratum Framework - GUI Deployment"
echo "=============================================================================="
echo "[ INFO ] Dieses Skript installiert die finale Desktop-Umgebung."
echo "------------------------------------------------------------------------------"

if [[ "$EUID" -eq 0 ]]; then
    echo "[ ERROR ] Dieses Skript darf nicht als 'root' ausgeführt werden. Bitte nutzen Sie Ihren Standard-Benutzer."
    exit 1
fi

read -rp "Desktop-Setup jetzt starten? [j/N]: " START_GUI
case "$START_GUI" in
    [jJ]*|[yY]*) ;;
    *) echo "[ INFO ] Abbruch."; exit 0 ;;
esac

echo "[ INFO ] Synchronisiere Paketdatenbanken..."
sudo pacman -Sy archlinux-keyring --noconfirm
sudo pacman -Syu --noconfirm

# ------------------------------------------------------------------------------
# PAKET-INSTALLATION (Hier deine Wunsch-Pakete eintragen)
# ------------------------------------------------------------------------------
echo "[ INFO ] Installiere Desktop-Pakete..."
# sudo pacman -S --noconfirm xorg sddm plasma kde-applications

# ------------------------------------------------------------------------------
# DIENSTE AKTIVIEREN
# ------------------------------------------------------------------------------
echo "[ INFO ] Aktiviere Desktop-Dienste..."
# sudo systemctl enable sddm

echo "------------------------------------------------------------------------------"
echo "[ OK ] Desktop-Setup abgeschlossen."
echo "[ INFO ] Entferne Handoff-Skript zur Systembereinigung..."
rm -f "$0"

echo "[ INFO ] Ein Neustart wird empfohlen."
