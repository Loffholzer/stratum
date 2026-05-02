#!/usr/bin/env bash

# =========================================
# 📄 DATEI: install.sh
# 💡 ZWECK: Hauptsteuerung der Installation
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
# Aufgabe: Prüft Existenz und führt Hauptfunktion aus
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
# Zweck: Sequenzielle Abarbeitung
# Aufgabe: Triggert alle Phasen (00 bis 99)
# =========================================
main() {
    # 0. Core-Framework (Farben, Sprache, Templates)
    load_module "00_utils.sh" "run_utils"
    load_module "01_ui_strings.sh" "load_ui_strings"
    load_module "02_templates.sh" "load_templates"

    # 1. Konfiguration
    load_module "03_config_sys.sh" "run_config_sys"
    load_module "04_config_disk.sh" "run_config_disk"

    # 2. Installation
    load_module "05_prep.sh" "run_prep"
    load_module "06_disk.sh" "run_disk"
    load_module "07_base.sh" "run_base"
    load_module "08_chroot_env.sh" "run_chroot_env"
    load_module "09_chroot_users.sh" "run_chroot_users"
    load_module "10_chroot_services.sh" "run_chroot_services"

    # 3. Abschluss
    load_module "99_cleanup.sh" "run_cleanup"
}

main "$@"
