#!/usr/bin/env bash

# =========================================
# 📄 DATEI: 99_cleanup.sh
# 💡 ZWECK: Abschluss, Unmount & Reboot
# =========================================

# =========================================
# 📦 Funktion: cleanup_system
# -----------------------------------------
# Zweck: Dateisysteme aushängen und aufräumen
# =========================================
cleanup_system() {
    if [[ "${DRY_RUN:-true}" == true ]]; then
        warn "$STR_WARN_DRY_CLEANUP"
        return 0
    fi

    log "$STR_LOG_FINAL_UNMOUNT"
    umount -R /mnt 2>/dev/null || true

    if [[ "$USE_LUKS" == "yes" && -b /dev/mapper/cryptroot ]]; then
        log "$STR_LOG_FINAL_LUKS"
        cryptsetup close cryptroot 2>/dev/null || true
    fi
    
    success "$STR_OK_INSTALL_DONE"
}

# =========================================
# 📦 Funktion: prompt_reboot
# -----------------------------------------
# Zweck: Benutzer nach Neustart fragen
# =========================================
prompt_reboot() {
    if [[ "${DRY_RUN:-true}" == true ]]; then
        return 0
    fi

    echo
    local answer
    answer="$(ask_yes_no "$STR_ASK_REBOOT")"
    
    if [[ "$answer" == "yes" ]]; then
        log "$STR_LOG_REBOOTING"
        reboot
    else
        log "$STR_LOG_EXIT"
    fi
}

# =========================================
# 📦 Funktion: run_cleanup
# -----------------------------------------
# Zweck: Einstiegspunkt Modul 99
# =========================================
run_cleanup() {
    header "$STR_CLN_PHASE_HEADER"
    cleanup_system
    prompt_reboot
}