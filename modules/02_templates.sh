#!/usr/bin/env bash

# =========================================
# 📄 DATEI: 02_templates.sh
# 💡 ZWECK: Zentrale Konfigurations-Templates
# =========================================

# =========================================
# 📦 Funktion: load_templates
# -----------------------------------------
# Zweck: Lädt große Textblöcke und Configs in den Speicher
# Aufgabe: Hält die Logik-Module sauber und wartbar
# =========================================
load_templates() {
    # =========================================
    # 📄 Template: ZRAM Configuration
    # =========================================
    export TPL_ZRAM_CONF="[zram0]
zram-size = ram / 2
compression-algorithm = zstd"

    # =========================================
    # 📄 Template: Globale Fish Shell Configuration (etc/fish/config.fish)
    # =========================================
    export TPL_FISH_CONFIG_ETC="set -g fish_greeting

if status is-interactive
    if type -q fastfetch; fastfetch; end
end

# Starship & Zoxide global einbinden, falls installiert
if type -q starship; starship init fish | source; end
if type -q zoxide; zoxide init fish | source; end

alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first'
alias la='eza -laa --icons --group-directories-first'
alias cat='bat --theme=\"Monokai Extended\"'
alias top='btop'
alias cd='z'
alias update='sudo pacman -Syu'
alias parus='paru -Syu'
alias snapshots='snapper -c root list'
"

    # =========================================
    # 📄 Template: Globale Starship Config (etc/starship.toml)
    # =========================================
    export TPL_STARSHIP_CONFIG_ETC="add_newline = true"

    # =========================================
    # 📄 Template: Fish Snippet für globale UX (für sudo -i)
    # =========================================
    export TPL_FISH_UX_ROOT="
# Zwingt Root in die gleiche UX
set -x STARSHIP_CONFIG /etc/starship.toml
"

    # =========================================
    # 📄 Template: Paru Configuration (.config/paru/paru.conf)
    # =========================================
    export TPL_PARU_CONF="
[options]
PgpFetch
Devel
Provides
# UX
BottomUp
NoSudoLoop
# Pacman Color Integration
Color = auto
# ILoveCandy Integration
ParallelDownloads = 5
BottomUp
"

    # =========================================
    # 📄 Template: Micro Editor Environment
    # =========================================
    export TPL_MICRO_ENV="export EDITOR=micro
export VISUAL=micro"

    # =========================================
    # 📄 Template: Desktop Handoff Skript
    # =========================================
    export TPL_DESKTOP_HANDOFF="#!/usr/bin/env bash

BLUE='\033[1;34m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
NC='\033[0m'

clear
echo -e \"\${BLUE}=========================================\${NC}\"
echo -e \"\${CYAN} 🚀 Willkommen in deinem neuen Arch Linux!\${NC}\"
echo -e \"\${BLUE}=========================================\${NC}\n\"

echo \"Dies ist das Post-Install-Skript für die grafische Oberfläche (GUI).\"
echo

read -rp \"Möchtest du das Desktop-Setup jetzt starten? (j/n): \" start_choice
if [[ \"\${start_choice,,}\" =~ ^(j|ja|y|yes)$ ]]; then
    echo -e \"\n\${GREEN}[OK] Desktop-Setup wird geladen...\${NC}\"
    sleep 2

    echo
    read -rp \"Setup abgeschlossen. Skript löschen? (j/n): \" del_choice
    if [[ \"\${del_choice,,}\" =~ ^(j|ja|y|yes)$ ]]; then
        rm -- \"\$0\"
        echo -e \"\${GREEN}[OK] Skript entfernt.\${NC}\"
    fi
else
    echo -e \"\nSetup übersprungen.\"
fi"

    # =========================================
    # 📄 Template: Sudoers AUR Build (Temporär)
    # =========================================
    export TPL_SUDOERS_AUR_BUILD="builduser ALL=(ALL) NOPASSWD: ALL"

    # =========================================
    # 📄 Template: Limine Globale Config (Splash, Farben, Memtest)
    # =========================================
    export TPL_LIMINE_BASE="timeout: 5
remember_last_entry: no
default_entry: 1

# Hintergrundbild
wallpaper: boot():/splash.jpg
wallpaper_style: stretched

# Farben
term_background: FF000000
term_foreground: FFB000
"

    # =========================================
    # 📄 Template: Limine Config Main (LUKS)
    # =========================================
    # Hinzugefügt:removed Mainline zusatz, memtest
    export TPL_LIMINE_LUKS="${TPL_LIMINE_BASE}
/$STR_LBL_BOOT_LABEL
    protocol: linux
    kernel_path: boot():/vmlinuz-linux
    module_path: boot():/initramfs-linux.img
    cmdline: cryptdevice=UUID={{ROOT_UUID}}:cryptroot root=/dev/mapper/cryptroot rootflags=subvol=@ rw quiet loglevel=3 udev.log_level=3

/$STR_LBL_BOOT_LABEL_LTS
    protocol: linux
    kernel_path: boot():/vmlinuz-linux-lts
    module_path: boot():/initramfs-linux-lts.img
    cmdline: cryptdevice=UUID={{ROOT_UUID}}:cryptroot root=/dev/mapper/cryptroot rootflags=subvol=@ rw quiet loglevel=3 udev.log_level=3

# --- Tools ---
/$STR_LBL_BOOT_MEMTEST
    protocol: efi
    path: boot():/memtest86+/memtest.efi
"

    # =========================================
    # 📄 Template: Limine Config Main (Standard)
    # =========================================
    # Hinzugefügt:removed Mainline zusatz, memtest
    export TPL_LIMINE_STD="${TPL_LIMINE_BASE}
/$STR_LBL_BOOT_LABEL
    protocol: linux
    kernel_path: uuid({{ROOT_UUID}}):/@/boot/vmlinuz-linux
    module_path: uuid({{ROOT_UUID}}):/@/boot/initramfs-linux.img
    cmdline: root=UUID={{ROOT_UUID}} rootflags=subvol=@ rw quiet splash

/$STR_LBL_BOOT_LABEL_LTS
    protocol: linux
    kernel_path: uuid({{ROOT_UUID}}):/@/boot/vmlinuz-linux-lts
    module_path: uuid({{ROOT_UUID}}):/@/boot/initramfs-linux-lts.img
    cmdline: root=UUID={{ROOT_UUID}} rootflags=subvol=@ rw quiet splash

# --- Tools ---
/$STR_LBL_BOOT_MEMTEST
    protocol: efi
    path: uuid({{ROOT_UUID}}):/@/boot/memtest86+/memtest.efi
"

    # =========================================
    # 📄 Template: Hosts File
    # =========================================
    export TPL_HOSTS="127.0.0.1   localhost
::1         localhost
127.0.1.1   {{HOSTNAME}}.localdomain {{HOSTNAME}}"

    # =========================================
    # 📄 Template: Snapper Root Config (Desktop Best-Practice)
    # =========================================
    # Angepasst auf Best-Practice
    export TPL_SNAPPER_ROOT="SUBVOLUME=\"/\"
FSTYPE=\"btrfs\"
ALLOW_USERS=\"\"
ALLOW_GROUPS=\"wheel\"
SYNC_ACL=\"no\"
BACKGROUND_COMPARISON=\"yes\"
NUMBER_CLEANUP=\"yes\"
NUMBER_MIN_AGE=\"1800\"
NUMBER_LIMIT=\"10\"
NUMBER_LIMIT_IMPORTANT=\"3\"
TIMELINE_CREATE=\"yes\"
TIMELINE_CLEANUP=\"yes\"
TIMELINE_MIN_AGE=\"1800\"
TIMELINE_LIMIT_HOURLY=\"5\"
TIMELINE_LIMIT_DAILY=\"7\"
TIMELINE_LIMIT_WEEKLY=\"0\"
TIMELINE_LIMIT_MONTHLY=\"0\"
TIMELINE_LIMIT_YEARLY=\"0\"
EMPTY_PRE_POST_CLEANUP=\"yes\"
EMPTY_PRE_POST_MIN_AGE=\"1800\""

    # =========================================
    # 📄 Template: Snapper Pacman Pre-Hook
    # =========================================
    export TPL_PACMAN_SNAPPER="[Trigger]
Operation = Install
Operation = Upgrade
Operation = Remove
Type = Package
Target = *

[Action]
Description = Erstelle BTRFS Snapshot (Pre-Transaction)...
Depends = snapper
When = PreTransaction
Exec = /usr/bin/snapper -c root create -d \"Pacman Pre-Transaction\""

    # =========================================
    # 📄 Template: BTRFS Snapshot-Update Skript (CachyOS style)
    # =========================================
    export TPL_SNAPPER_UPDATE_SCRIPT="#!/usr/bin/env bash

LIMINE_CONF=\"/boot/limine.conf\"
[[ -b /dev/mapper/cryptroot ]] && LIMINE_CONF=\"/boot/limine.conf\" || LIMINE_CONF=\"/boot/efi/limine.conf\"

BOOT_PART_UUID=\"{{BOOT_PART_UUID}}\"
ROOT_UUID=\"{{ROOT_UUID}}\"
CRYPTROOT_UUID=\"{{CRYPTROOT_UUID}}\"

SNAPSHOT_BASE=\"/@.snapshots\"

# Bestehende Snapshot-Einträge entfernen
sed -i '/# === AUTO_GENERATED_SNAPSHOTS ===/,\$d' \"\$LIMINE_CONF\"
echo \"# === AUTO_GENERATED_SNAPSHOTS ===\" >> \"\$LIMINE_CONF\"

# Nach Snapshots suchen (Snapper .snapshots Verzeichnis)
mapfile -t SNAPSHOTS < <(btrfs subvolume list / | grep \"/\.snapshots/\" | awk '{print \$NF}' | sort -r)

for snap in \"\${SNAPSHOTS[@]}\"; do
    snap_num=\$(basename \"\$snap\")
    snap_name=\$(grep \"Pacman\" \"/\$snap/info.xml\" | head -n 1 | sed 's/.*<desc>\(.*\)<\/desc>.*/\1/')
    [[ -z \"\$snap_name\" ]] && snap_name=\"Manuell\"

    # Bootloader-Pfad berechnen
    boot_path=\"/@/\$snap/vmlinuz-linux\"
    init_path=\"/@/\$snap/initramfs-linux.img\"

    # CMDLINE generieren (LUKS vs Standard)
    cmdline=\"\"
    if [[ -z \"\$CRYPTROOT_UUID\" ]]; then
        cmdline=\"root=UUID=\$ROOT_UUID rootflags=subvol=\$snap/\$snap_num/snapshot rw quiet splash\"
    else
        cmdline=\"cryptdevice=UUID=\$CRYPTROOT_UUID:cryptroot root=/dev/mapper/cryptroot rootflags=subvol=\$snap/\$snap_num/snapshot rw quiet loglevel=3 udev.log_level=3\"
    fi

    # Eintrag anfügen
    echo \"
/$STR_LBL_BOOT_LABEL (Snapshot #\$snap_num: \$snap_name)
    protocol: linux
    kernel_path: uuid(\$BOOT_PART_UUID):\$boot_path
    module_path: uuid(\$BOOT_PART_UUID):\$init_path
    cmdline: \$cmdline\" >> \"\$LIMINE_CONF\"
done
"

    # =========================================
    # 📄 Template: Snapper Update Service
    # =========================================
    export TPL_SNAPPER_UPDATE_SERVICE="[Unit]
Description=Update Limine config with BTRFS snapshots
After=snapper-cleanup.timer snapper-timeline.timer

[Service]
Type=oneshot
ExecStart=/usr/local/bin/limine-update-snapshots.sh
"

    # =========================================
    # 📄 Template: Snapper Update Timer
    # =========================================
    export TPL_SNAPPER_UPDATE_TIMER="[Unit]
Description=Run limine-update-snapshots service hourly

[Timer]
OnCalendar=hourly
RandomizedDelaySec=5min
Persistent=true

[Install]
WantedBy=timers.target
"

    # =========================================
    # 📄 Template: Limine Snapshot Sync Hook
    # =========================================
    export TPL_PACMAN_LIMINE_SYNC="[Trigger]
Operation = Install
Operation = Upgrade
Operation = Remove
Type = Package
Target = *

[Action]
Description = Aktualisiere Limine Bootmenü (Snapshots)...
When = PostTransaction
Exec = /usr/local/bin/limine-update-snapshots.sh"

    export TPL_FISH_HANDOFF="
if test -f ~/.config/setup_active
    echo ''
    echo '--------------------------------------------------'
    echo '$STR_HANDOFF_TITLE'
    echo '--------------------------------------------------'
    
    read -l -p 'echo \"$STR_HANDOFF_QUESTION\"' confirm

    if [ \"\$confirm\" = \"j\" ] || [ \"\$confirm\" = \"J\" ] || [ \"\$confirm\" = \"y\" ] || [ \"\$confirm\" = \"Y\" ]
        rm ~/.config/setup_active
        # Startet die install.sh im setup Ordner
        bash ~/setup/install.sh
    else
        echo ''
        echo '$STR_HANDOFF_INFO'
        echo '$STR_HANDOFF_PATH_INFO'
        echo ''
        rm ~/.config/setup_active
    end
end
"
}