#!/usr/bin/env bash

# =========================================
# 📦 Funktion: Globaler Header / Info
# -----------------------------------------
# Zweck: Users, Environment & Security (07_chroot_users.sh)
# Aufgabe: User-Setup, ZRAM, Firewalld, Shell-UX und AUR-Helper
# =========================================

# =========================================
# 📦 Funktion: users_accounts
# -----------------------------------------
# Zweck: System-Identitäten einrichten
# Aufgabe: User anlegen, Passwörter setzen, Wheel-Group
# =========================================
users_accounts() {
    phase_header "Chroot: Benutzer & Berechtigungen"

    if [[ "${DRY_RUN:-true}" == true ]]; then
        warn "[DRY-RUN] User-Erstellung übersprungen."
        return 0
    fi

    log "Erstelle Benutzer '$USERNAME'..."
    arch-chroot /mnt useradd -m -G wheel -s /bin/bash "$USERNAME"

    log "Setze Passwörter..."
    echo "$USERNAME:$USER_PASSWORD" | arch-chroot /mnt chpasswd

    if [[ "$DISABLE_ROOT" == "yes" ]]; then
        log "Sichere Root-Account (Passwort-Login deaktiviert)..."
        arch-chroot /mnt passwd -l root >/dev/null
    else
        log "Setze Root-Passwort identisch zum User..."
        echo "root:$USER_PASSWORD" | arch-chroot /mnt chpasswd
    fi

    log "Konfiguriere Sudo (Wheel-Group)..."
    echo "%wheel ALL=(ALL:ALL) ALL" > /mnt/etc/sudoers.d/wheel
    chmod 0440 /mnt/etc/sudoers.d/wheel

    success "Benutzerverwaltung abgeschlossen."
}

# =========================================
# 📦 Funktion: users_security
# -----------------------------------------
# Zweck: System-Härtung und Performance
# Aufgabe: ZRAM und Firewalld (Home Zone)
# =========================================
users_security() {
    phase_header "Chroot: Security & ZRAM"

    if [[ "${DRY_RUN:-true}" == true ]]; then
        warn "[DRY-RUN] Security-Setup übersprungen."
        return 0
    fi

    log "Installiere ZRAM und Firewalld..."
    arch-chroot /mnt pacman -S --noconfirm zram-generator firewalld >/dev/null

    log "Konfiguriere ZRAM (ram / 2)..."
    cat <<EOF > /mnt/etc/systemd/zram-generator.conf
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
EOF

    log "Konfiguriere Firewalld (DefaultZone = home)..."
    sed -i 's/^DefaultZone=.*/DefaultZone=home/' /mnt/etc/firewalld/firewalld.conf
    arch-chroot /mnt systemctl enable firewalld >/dev/null 2>&1

    if [[ "$INSTALL_SSH" == "yes" ]]; then
        log "Installiere und aktiviere OpenSSH..."
        arch-chroot /mnt pacman -S --noconfirm openssh >/dev/null
        arch-chroot /mnt systemctl enable sshd >/dev/null 2>&1
        sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' /mnt/etc/ssh/sshd_config
    fi

    success "Security-Module konfiguriert."
}

# =========================================
# 📦 Funktion: users_pacman_target
# -----------------------------------------
# Zweck: Pacman im Zielsystem optimieren
# Aufgabe: Color, ILoveCandy und ParallelDownloads
# =========================================
users_pacman_target() {
    phase_header "Chroot: Pacman-Optimierung"

    if [[ "${DRY_RUN:-true}" == true ]]; then
        warn "[DRY-RUN] Pacman-Config übersprungen."
        return 0
    fi

    local target_conf="/mnt/etc/pacman.conf"
    log "Optimiere $target_conf..."

    sed -i 's/^#Color/Color/' "$target_conf"
    if ! grep -q "^ILoveCandy" "$target_conf"; then
        sed -i '/^Color/a ILoveCandy' "$target_conf"
    fi
    sed -i 's/^#ParallelDownloads.*/ParallelDownloads = 10/' "$target_conf"
    if ! grep -q "^ParallelDownloads" "$target_conf"; then
        sed -i '/^#Misc options/a ParallelDownloads = 10' "$target_conf"
    fi

    success "Pacman im Zielsystem konfiguriert."
}

# =========================================
# 📦 Funktion: users_shell_ux
# -----------------------------------------
# Zweck: Professional Terminal Environment
# Aufgabe: Fish, Starship und Nerd-Fonts
# =========================================
users_shell_ux() {
    if [[ "$INSTALL_SHELL" != "yes" ]]; then return 0; fi

    phase_header "Chroot: Shell & UX (Fish + Starship)"

    if [[ "${DRY_RUN:-true}" == true ]]; then
        warn "[DRY-RUN] Shell-Setup übersprungen."
        return 0
    fi

    log "Installiere UX-Pakete..."
    arch-chroot /mnt pacman -S --noconfirm \
        fish starship zoxide fastfetch eza bat btop \
        ttf-jetbrains-mono-nerd >/dev/null

    log "Setze Fish als Standard-Shell..."
    arch-chroot /mnt chsh -s /usr/bin/fish "$USERNAME"
    arch-chroot /mnt chsh -s /usr/bin/fish root

    log "Schreibe systemweite Fish-Config..."
    mkdir -p /mnt/etc/fish
    cat <<'EOF' > /mnt/etc/fish/config.fish
set -g fish_greeting

if status is-interactive
    if type -q fastfetch; fastfetch; end
end

if type -q starship; starship init fish | source; end
if type -q zoxide; zoxide init fish | source; end

alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first'
alias la='eza -laa --icons --group-directories-first'
alias cat='bat --theme="Monokai Extended"'
alias top='btop'
alias cd='z'
alias update='sudo pacman -Syu'
EOF

    success "Shell-UX (Fish) eingerichtet."
}

# =========================================
# 📦 Funktion: users_editor
# -----------------------------------------
# Zweck: Nano Virtuoso Setup
# Aufgabe: Line-Numbers, Syntax, Auto-Indent
# =========================================
users_editor() {
    if [[ "$INSTALL_EDITOR" != "yes" ]]; then return 0; fi

    phase_header "Chroot: Editor (Nano)"

    if [[ "${DRY_RUN:-true}" == true ]]; then
        warn "[DRY-RUN] Nano-Config übersprungen."
        return 0
    fi

    log "Installiere Nano..."
    arch-chroot /mnt pacman -S --noconfirm nano syntax-highlighting >/dev/null 2>&1 || true

    log "Konfiguriere /etc/nanorc..."
    cat <<EOF >> /mnt/etc/nanorc

set linenumbers
set mouse
set autoindent
set tabsize 4
set tabstospaces
set softwrap
set indicator
set minibar

include "/usr/share/nano/*.nanorc"
EOF

    success "Nano konfiguriert (Virtuoso-Modus)."
}

# =========================================
# 📦 Funktion: users_aur
# -----------------------------------------
# Zweck: AUR Helper installieren
# Aufgabe: Baut paru-bin sicher als Non-Root
# =========================================
users_aur() {
    if [[ "$INSTALL_AUR" != "yes" ]]; then return 0; fi

    phase_header "Chroot: AUR Helper (Paru)"

    if [[ "${DRY_RUN:-true}" == true ]]; then
        warn "[DRY-RUN] Paru-Build übersprungen."
        return 0
    fi

    log "Erstelle temporäre Sudo-Rechte für den Build-Prozess..."
    echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" > /mnt/etc/sudoers.d/temp_aur_build
    chmod 0440 /mnt/etc/sudoers.d/temp_aur_build

    log "Lade und baue paru-bin via makepkg (als User $USERNAME)..."
    arch-chroot /mnt sudo -u "$USERNAME" bash -c '
        cd ~
        git clone https://aur.archlinux.org/paru-bin.git
        cd paru-bin
        makepkg -si --noconfirm
        cd ..
        rm -rf paru-bin
    ' >/dev/null 2>&1 || warn "Paru Build fehlgeschlagen."

    log "Entferne temporäre Sudo-Rechte..."
    rm -f /mnt/etc/sudoers.d/temp_aur_build

    success "Paru-bin erfolgreich installiert."
}

# =========================================
# 📦 Funktion: users_desktop_handoff
# -----------------------------------------
# Zweck: Post-Install UX / First-Boot Script
# Aufgabe: Erstellt GUI-Installer-Dummy
# =========================================
users_desktop_handoff() {
    phase_header "Chroot: First-Boot Handoff Script"

    if [[ "${DRY_RUN:-true}" == true ]]; then
        warn "[DRY-RUN] Desktop-Handoff Setup übersprungen."
        return 0
    fi

    local script_path="/mnt/home/$USERNAME/arch_desktop_setup.sh"

    log "Erstelle First-Boot-Skript in ~/arch_desktop_setup.sh..."
    cat <<'EOF' > "$script_path"
#!/usr/bin/env bash

BLUE='\033[1;34m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
NC='\033[0m'

clear
echo -e "${BLUE}=========================================${NC}"
echo -e "${CYAN} 🚀 Willkommen in deinem neuen Arch Linux!${NC}"
echo -e "${BLUE}=========================================${NC}\n"

echo "Dies ist das Post-Install-Skript für die grafische Oberfläche (GUI)."
echo

read -rp "Möchtest du das Desktop-Setup jetzt starten? (j/n): " start_choice
if [[ "${start_choice,,}" =~ ^(j|ja|y|yes)$ ]]; then
    echo -e "\n${GREEN}[OK] Desktop-Setup wird geladen...${NC}"
    sleep 2

    echo
    read -rp "Setup abgeschlossen. Skript löschen? (j/n): " del_choice
    if [[ "${del_choice,,}" =~ ^(j|ja|y|yes)$ ]]; then
        rm -- "$0"
        echo -e "${GREEN}[OK] Skript entfernt.${NC}"
    fi
else
    echo -e "\nSetup übersprungen."
fi
EOF

    arch-chroot /mnt chmod +x "/home/$USERNAME/arch_desktop_setup.sh"
    arch-chroot /mnt chown "$USERNAME:$USERNAME" "/home/$USERNAME/arch_desktop_setup.sh"

    log "Registriere Auto-Start Hook..."
    cat <<'EOF' >> "/mnt/home/$USERNAME/.bashrc"
if [ -f "$HOME/arch_desktop_setup.sh" ]; then
    "$HOME/arch_desktop_setup.sh"
fi
EOF

    if [[ "$INSTALL_SHELL" == "yes" ]]; then
        cat <<'EOF' >> "/mnt/etc/fish/config.fish"
if test -f "$HOME/arch_desktop_setup.sh"
    eval "$HOME/arch_desktop_setup.sh"
end
EOF
    fi

    success "First-Boot Handoff vorbereitet."
}

# =========================================
# 📦 Funktion: run_chroot_users
# -----------------------------------------
# Zweck: Sequenzielle Ausführung
# =========================================
run_chroot_users() {
    header "Phase 7: Users, Environment & Security"

    users_accounts
    users_security
    users_pacman_target
    users_shell_ux
    users_editor
    users_aur
    users_desktop_handoff
}
