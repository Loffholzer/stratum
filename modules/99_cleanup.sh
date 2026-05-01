#!/usr/bin/env bash

# =========================================
# 📦 Funktion: Globaler Header / Info
# -----------------------------------------
# Zweck: Sicherer Systemabschluss (99_cleanup.sh)
# Aufgabe: System aushängen, LUKS verschließen, Reboot
# =========================================

# =========================================
# 📦 Funktion: run_cleanup
# -----------------------------------------
# Zweck: Zentraler Aufrufpunkt des Moduls
# Aufgabe: Führt den finalen Cleanup-Prozess durch
# =========================================
run_cleanup() {
    header "Phase 99: Cleanup & Abschluss"

    if [[ "${DRY_RUN:-true}" == true ]]; then
        success "DRY-RUN erfolgreich beendet. Keine Änderungen vorgenommen."
        return 0
    fi

    log "Hänge Dateisysteme unter /mnt rekursiv aus..."
    umount -R /mnt 2>/dev/null || true

    if [[ "$USE_LUKS" == "yes" ]]; then
        log "Schließe LUKS Container (cryptroot)..."
        cryptsetup close cryptroot 2>/dev/null || true
    fi

    echo -e "\n${BOLD}${GREEN}=========================================${NC}"
    echo -e "${BOLD}${GREEN} 🎉 INSTALLATION ERFOLGREICH ABGESCHLOSSEN 🎉${NC}"
    echo -e "${BOLD}${GREEN}=========================================${NC}\n"

    echo -e "Die neue Arch Linux Umgebung ist bereit."
    echo -e "Bitte entferne das Installationsmedium und starte das System neu.\n"

    local reboot_choice
    read -rp "$(echo -e "${BLUE}[INPUT]${NC} Jetzt neu starten? (j/n): ")" reboot_choice
    if [[ "${reboot_choice,,}" =~ ^(j|ja|y|yes)$ ]]; then
        log "System wird neu gestartet..."
        reboot
    else
        log "Kein automatischer Neustart. Du befindest dich weiterhin im Live-System."
    fi
}
