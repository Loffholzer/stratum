#!/bin/bash
# ==============================================================================
# STRATUM - ARCH LINUX DEPLOYMENT FRAMEWORK
# Modul: Preflight (System-Checks)
# ==============================================================================

preflight_checks() {
    echo "[ PHASE ] System-Prüfung (Preflight Checks)"

    # Root-Check
    if [[ "$EUID" -ne 0 ]]; then
        echo "[ ERROR ] Dieses Skript muss mit Root-Rechten ausgeführt werden."
        exit 1
    fi

    # UEFI-Check
    if [[ ! -d "/sys/firmware/efi/efivars" ]]; then
        echo "[ ERROR ] System wurde nicht im UEFI-Modus gestartet. BIOS/Legacy wird nicht unterstützt."
        exit 1
    fi
    echo "[ OK ] UEFI-Boot-Modus bestätigt."

    # Netzwerk-Check
    echo "[ INFO ] Prüfe Internetverbindung..."
    if ! ping -c 1 archlinux.org >/dev/null 2>&1; then
        echo "[ ERROR ] Keine Internetverbindung. Bitte Netzwerk konfigurieren."
        exit 1
    fi
    echo "[ OK ] Netzwerkverbindung aktiv."

    # Zeitsynchronisation
    timedatectl set-ntp true
    echo "[ OK ] Systemzeit (NTP) synchronisiert."
}
