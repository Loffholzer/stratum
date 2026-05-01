#!/bin/bash
# ==============================================================================
# STRATUM - ARCH LINUX DEPLOYMENT FRAMEWORK
# Main Deployment Script
# ==============================================================================

set -e

if [[ ! -f "config.sh" ]]; then
    echo "[ ERROR ] config.sh fehlt. Abbruch."
    exit 1
fi
source "config.sh"

for mod_file in modules/*.sh; do
    if [[ -f "$mod_file" ]]; then
        source "$mod_file"
    else
        echo "[ ERROR ] Modulverzeichnis unvollständig. Abbruch."
        exit 1
    fi
done

clear
echo "=============================================================================="
echo " $FRAMEWORK_NAME v$VERSION - Deployment Framework"
echo "=============================================================================="
echo "[ INFO ] Initialisierung gestartet."

# 0. Datenerfassung via Wizard
wizard_run

# 1. Preflight-Checks
preflight_checks

# 2. Festplatten-Setup
disk_setup

# 3. Dateisystem und Mounts
mount_btrfs

# 4. Basis-System (Pacstrap)
base_pacstrap

# 5. Bootloader-Umgebung (Limine)
env_bootloader

# 6. Benutzerverwaltung und AUR
users_setup
users_aur

# 7. Systemd-Dienste
services_enable

echo "[ INFO ] Erstelle GUI-Handoff-Skript für den finalen Nutzer..."
cp arch_desktop_setup.sh /mnt/home/$USERNAME/
arch-chroot /mnt chown $USERNAME:$USERNAME /home/$USERNAME/arch_desktop_setup.sh
arch-chroot /mnt chmod +x /home/$USERNAME/arch_desktop_setup.sh

echo "=============================================================================="
echo "[ OK ] Stratum Deployment erfolgreich abgeschlossen."
echo "=============================================================================="
read -p "Systemneustart erforderlich. Fortfahren? [J/n] " reboot_choice
case "$reboot_choice" in
    [nN]*) echo "[ INFO ] Neustart übersprungen. System verbleibt in chroot." ;;
    *) echo "[ INFO ] Neustart initiiert..."; umount -R /mnt; reboot ;;
esac
