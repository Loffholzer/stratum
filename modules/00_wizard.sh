#!/bin/bash
# ==============================================================================
# STRATUM - ARCH LINUX DEPLOYMENT FRAMEWORK
# Modul: Wizard (Interaktive Datenerfassung)
# ==============================================================================

wizard_run() {
    echo "[ PHASE ] Interaktive Systemkonfiguration"
    echo "[ INFO ] Bitte definieren Sie die Zielparameter für das Deployment."
    echo "------------------------------------------------------------------------------"

    # Ziellaufwerk
    echo "[ INFO ] Verfügbare Datenträger:"
    lsblk -d -p -n -l -o NAME,SIZE,MODEL | grep -v "loop"
    echo "------------------------------------------------------------------------------"
    read -rp "Ziel-Datenträger (z.B. /dev/nvme0n1 oder /dev/sda): " WIZ_DISK
    if [[ ! -b "$WIZ_DISK" ]]; then
        echo "[ ERROR ] Datenträger $WIZ_DISK nicht gefunden. Abbruch."
        exit 1
    fi
    export DISK="$WIZ_DISK"

    # Verschlüsselung (LUKS)
    read -rp "Vollverschlüsselung (LUKS2) aktivieren? [j/N]: " WIZ_LUKS
    case "$WIZ_LUKS" in
        [jJ]*|[yY]*)
            export USE_LUKS="yes"
            while true; do
                read -rsp "LUKS Passwort festlegen: " WIZ_LUKS_PASS1; echo
                read -rsp "LUKS Passwort wiederholen: " WIZ_LUKS_PASS2; echo
                if [[ "$WIZ_LUKS_PASS1" == "$WIZ_LUKS_PASS2" && -n "$WIZ_LUKS_PASS1" ]]; then
                    export LUKS_PASSWORD="$WIZ_LUKS_PASS1"
                    echo "[ OK ] LUKS-Passwort validiert."
                    break
                else
                    echo "[ ERROR ] Passwörter fehlerhaft. Wiederholung."
                fi
            done
            ;;
        *)
            export USE_LUKS="no"
            ;;
    esac

    # System- & Benutzerdaten
    read -rp "Hostname [Standard: stratum-pc]: " WIZ_HOST
    export HOSTNAME="${WIZ_HOST:-stratum-pc}"

    read -rp "Hauptbenutzer [Standard: admin]: " WIZ_USER
    export USERNAME="${WIZ_USER:-admin}"

    while true; do
        read -rsp "Passwort für Benutzer '$USERNAME': " WIZ_USER_PASS1; echo
        read -rsp "Passwort wiederholen: " WIZ_USER_PASS2; echo
        if [[ "$WIZ_USER_PASS1" == "$WIZ_USER_PASS2" && -n "$WIZ_USER_PASS1" ]]; then
            export USER_PASSWORD="$WIZ_USER_PASS1"
            echo "[ OK ] Benutzer-Passwort validiert."
            break
        else
            echo "[ ERROR ] Passwörter fehlerhaft. Wiederholung."
        fi
    done

    echo "------------------------------------------------------------------------------"
    echo "[ WARNUNG ] ALLE DATEN AUF $DISK WERDEN NUN UNWIDERRUFLICH GELÖSCHT!"
    read -rp "Deployment jetzt starten? [j/N]: " WIZ_START
    case "$WIZ_START" in
        [jJ]*|[yY]*) echo "[ INFO ] Zero-Touch Deployment gestartet." ;;
        *) echo "[ INFO ] Abbruch durch Benutzer."; exit 0 ;;
    esac
}
