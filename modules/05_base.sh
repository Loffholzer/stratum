#!/usr/bin/env bash

# =========================================
# 📦 Funktion: Globaler Header / Info
# -----------------------------------------
# Zweck: Bootstrapping des Grundsystems (05_base.sh)
# Aufgabe: Pacstrap ausführen, Kern-Pakete laden, FSTAB generieren
# =========================================

# =========================================
# 📦 Funktion: base_pacstrap
# -----------------------------------------
# Zweck: Installation des Kernsystems
# Aufgabe: Lädt Base, Kernel und elementare Tools ins Zielsystem
# =========================================
base_pacstrap() {
    phase_header "Pacstrap: Grundsystem installieren"

    local base_pkgs=(
        base base-devel
        linux linux-headers linux-lts linux-lts-headers
        linux-firmware "$MICROCODE_PKG"
        btrfs-progs
        networkmanager
        sudo neovim git curl wget
        cryptsetup lvm2
        terminus-font
    )

    log "Installiere folgende Pakete in /mnt:"
    echo -e "${CYAN}${base_pkgs[*]}${NC}\n"

    if [[ "${DRY_RUN:-true}" == true ]]; then
        warn "[DRY-RUN] pacstrap wird übersprungen."
        return 0
    fi

    # Verhindere den 'vconsole.conf not found' Fehler beim automatischen mkinitcpio-Lauf
    log "Bereite Dummy-Configs für pacstrap-Hooks vor..."
    mkdir -p /mnt/etc
    touch /mnt/etc/vconsole.conf

    # pacstrap ausführen
    pacstrap -K /mnt "${base_pkgs[@]}" || {
        error "Pacstrap fehlgeschlagen. Netzwerkverbindung oder Mirrorlist prüfen."
        exit 1
    }

    success "Grundsystem erfolgreich installiert."
}

# =========================================
# 📦 Funktion: base_fstab
# -----------------------------------------
# Zweck: Generiert die Dateisystem-Tabelle
# Aufgabe: Nutzt UUIDs und patcht subvolid für Snapper heraus
# =========================================
base_fstab() {
    phase_header "FSTAB generieren & patchen"

    if [[ "${DRY_RUN:-true}" == true ]]; then
        warn "[DRY-RUN] genfstab wird übersprungen."
        return 0
    fi

    log "Generiere fstab (UUID-basiert)..."
    genfstab -U /mnt > /mnt/etc/fstab || {
        error "FSTAB konnte nicht generiert werden."
        exit 1
    }

    log "Optimiere fstab für BTRFS-Rollbacks (Entferne subvolid)..."
    sed -i 's/subvolid=[0-9]*,//g' /mnt/etc/fstab
    sed -i 's/,subvolid=[0-9]*//g' /mnt/etc/fstab

    # FSTAB-Ausgabe ins Log zur Validierung
    echo
    cat /mnt/etc/fstab
    echo

    success "FSTAB erfolgreich erstellt und gepatcht."
}

# =========================================
# 📦 Funktion: run_base
# -----------------------------------------
# Zweck: Sequenzielle Ausführung
# Aufgabe: Installiert Pakete und generiert fstab
# =========================================
run_base() {
    header "Phase 5: Base System (Pacstrap)"

    base_pacstrap
    base_fstab
}
