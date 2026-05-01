#!/usr/bin/env bash

# =========================================
# 📦 Funktion: Globaler Header / Info
# -----------------------------------------
# Zweck: Installer Hauptsteuerung
# Aufgabe: Lädt Module sequenziell, verwaltet DRY_RUN State
# =========================================

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || { echo "Fehler bei der Pfadermittlung."; exit 1; }
readonly BASE_DIR

MOD_DIR="${BASE_DIR}/modules"
readonly MOD_DIR

export DRY_RUN=false

# =========================================
# 📦 Funktion: load_module
# -----------------------------------------
# Zweck: Sicheres Laden von Teilskripten
# Aufgabe: Prüft Modul-Existenz und triggert die Hauptfunktion
# =========================================
load_module() {
    local mod_file="$1"
    local func_name="$2"

    if [[ -f "${MOD_DIR}/${mod_file}" ]]; then
        # shellcheck disable=SC1090
        source "${MOD_DIR}/${mod_file}"
        "$func_name"
    else
        echo -e "\033[1;31m[FEHLER]\033[0m Modul ${mod_file} nicht gefunden. Abbruch."
        exit 1
    fi
}

# =========================================
# 📦 Funktion: main
# -----------------------------------------
# Zweck: Sequenzielle Abarbeitung der Phasen
# Aufgabe: Triggert alle Module in der logischen Architektur-Folge
# =========================================
main() {
    # 0. Utils & UI (muss zwingend als erstes geladen werden für Logging)
    load_module "00_utils.sh" "run_utils"

    # 1. Konfigurationsphase (aufgeteilt in Sys und Disk)
    load_module "01_config_sys.sh" "run_config_sys"
    load_module "02_config_disk.sh" "run_config_disk"

    # 2. Ausführung der Installationsphasen
    load_module "03_prep.sh" "run_prep"
    load_module "04_disk.sh" "run_disk"
    load_module "05_base.sh" "run_base"
    load_module "06_chroot_env.sh" "run_chroot_env"
    load_module "07_chroot_users.sh" "run_chroot_users"
    load_module "08_chroot_services.sh" "run_chroot_services"

    # 3. Abschluss
    load_module "99_cleanup.sh" "run_cleanup"
}

# Start
main "$@"