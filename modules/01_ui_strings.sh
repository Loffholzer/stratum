#!/usr/bin/env bash

# =========================================
# 📄 DATEI: 01_ui_strings.sh
# 💡 ZWECK: Zentrale UI-Texte & Lokalisierung (DE)
# =========================================

# =========================================
# 📦 Funktion: load_ui_strings
# -----------------------------------------
# Zweck: Lädt alle UI-Texte in den Speicher
# Aufgabe: Definiert Prompts, Logs und Fehlermeldungen
# =========================================

load_ui_strings() {
    # --- Allgemeines ---
    export STR_INPUT_PREFIX="${BLUE}[INPUT]${NC}"
    export STR_INFO_PREFIX="${BLUE}[INFO]${NC}"
    export STR_OK_PREFIX="${GREEN}[OK]${NC}"
    export STR_WARN_PREFIX="${YELLOW}[WARN]${NC}"
    export STR_ERR_PREFIX="${RED}[ERROR]${NC}"

    export STR_PROMPT_SEL_1_2="Auswahl [1-2]: "
    export STR_PROMPT_SEL_1_3="Auswahl [1-3]: "
    export STR_PROMPT_YN="(j/n)"
    export STR_WARN_YES_NO="Bitte mit j/n antworten."
    export STR_WARN_INVALID_SEL="Ungültige Auswahl."
    export STR_WARN_NO_HITS="Keine Treffer."
    export STR_WARN_TOO_MANY_HITS="Zu viele Treffer. Bitte verfeinern."
    export STR_PROMPT_SELECT_NUM="Nummer wählen (0 für Abbruch): "
    export STR_OPT_MANUAL_SEARCH="Manuell suchen"

    # --- Modul: 03_config_sys (Header & Phasen) ---
    export STR_SYS_HEADER="System-Konfiguration"
    export STR_PHASE_KEYMAP="Tastaturlayout"
    export STR_PHASE_TIMEZONE="Zeitzone"
    export STR_PHASE_LOCALE="Systemsprache (Locale)"
    export STR_PHASE_IDENTITY="Identität & Module"
    
    # --- Modul: 03_config_sys (Prompts & Optionen) ---
    export STR_PROMPT_HOSTNAME="Hostname (z.B. arch-pc): "
    export STR_PROMPT_USERNAME="Username (z.B. max): "
    export STR_PROMPT_PASS_USER="User-Passwort: "
    export STR_PROMPT_PASS_CONFIRM="Passwort wiederholen: "
    
    export STR_OPT_AUTO="(Automatisch)"
    export STR_OPT_US_STD="us (Standard)"
    export STR_PROMPT_SEARCH_KEYMAP="Suche (z.B. de, fr): "
    export STR_TITLE_KEYMAP_HITS="Keymap Treffer"
    export STR_WARN_KEYMAP_LIVE_FAIL="Konnte Layout im Live-System nicht setzen."

    export STR_LOG_RECOGNIZED="Erkannt: "
    export STR_OPT_USE_RECOGNIZED_TZ="Erkannte Zeitzone nutzen"
    export STR_PROMPT_SEARCH_TZ="Suche (z.B. berlin, tokyo): "
    export STR_TITLE_TZ_HITS="Zeitzonen Treffer"
    export STR_LOG_TZ_AUTO_FAIL="Automatische Zeitzonen-Erkennung fehlgeschlagen. Manuelle Suche erforderlich."

    export STR_LOG_LOCALE_HINT="Hinweis: en_US.UTF-8 wird immer generiert."
    export STR_OPT_PLUS_EN_US=" + en_US.UTF-8"
    export STR_OPT_ONLY_EN_US="Nur en_US.UTF-8"
    export STR_PROMPT_SEARCH_LOCALE="Suche (z.B. fr_FR, es_ES): "
    export STR_TITLE_LOCALE_HITS="Locale Treffer"

    export STR_ASK_CONFIRM_INPUT="Eingabe korrekt?"
    export STR_ASK_ROOT_LOCK="Root-Login sperren? (Sicherer, Sudo wird genutzt)"
    export STR_ASK_MULTILIB="Multilib (32-Bit) aktivieren?"
    export STR_ASK_SHELL_UX="UX-Stack (Fish, Starship, Zoxide) installieren?"
    export STR_ASK_TOOLS="CLI-Tools (eza, bat, btop) installieren?"
    export STR_ASK_AUR="AUR-Helper (Paru) installieren?"
    export STR_ASK_EDITOR="Micro als Standard-Editor setzen?"
    export STR_ASK_SSH="OpenSSH installieren und aktivieren?"

    # --- Modul: 03_config_sys (Micro-Texte & Warnungen) ---
    export STR_LOG_INTEL_CPU="Intel CPU erkannt."
    export STR_LOG_AMD_CPU="AMD CPU erkannt."
    export STR_WARN_UNKNOWN_CPU="Unbekannte CPU. Kein Microcode."
    export STR_WARN_HOSTNAME_RULES="Erlaubt: a-z, 0-9, Bindestrich."
    export STR_WARN_USERNAME_RULES="Erlaubt: a-z, 0-9, Unterstrich. Beginnend mit Buchstabe."
    export STR_ERR_AUTO_DRY_RUN="AUTO_MODE darf nicht mit DRY_RUN=false laufen!"
    export STR_LOG_AUTO_ACTIVE="AUTO-MODE aktiv. Überspringe Eingaben."

    # --- Modul: 04_config_disk ---
    export STR_DISK_HEADER="Laufwerkskonfiguration"
    export STR_PHASE_DISK_SEL="Ziellaufwerk auswählen"
    export STR_PHASE_PROFIL_SEL="Disk-Setup / Verschlüsselung"
    export STR_PROMPT_LUKS_PASS="LUKS-Passwort (Verschlüsselung): "
    
    export STR_SUMMARY_HEADER="Zusammenfassung (Point of no Return)"
    export STR_WARN_DELETE="ACHTUNG: Alle Daten auf %s werden unwiderruflich GELÖSCHT!"
    export STR_ASK_START_INSTALL="Installation jetzt starten?"

    # --- Fehler ---
    export STR_ERR_ROOT_REQ="Ausführung als Root erforderlich."
    export STR_ERR_UEFI_REQ="UEFI-Umgebung zwingend erforderlich."
    export STR_ERR_NO_DISK="Keine geeigneten Laufwerke gefunden."
    export STR_ERR_PASS_MISMATCH="Passwörter stimmen nicht überein."

    # --- Modul: 04_config_disk (Micro-Texte & Labels) ---
    export STR_LOG_FOUND_DISKS="Gefundene Laufwerke:"
    export STR_LOG_USER_ABORT="Abbruch durch Benutzer."
    export STR_OPT_PROF_STD="Standard (BTRFS Subvolumes, unverschlüsselt)"
    export STR_OPT_PROF_LUKS="LUKS (BTRFS auf LUKS2, verschlüsselt)"
    export STR_LBL_HOST="Hostname:"
    export STR_LBL_USER="Username:"
    export STR_LBL_KEY="Tastatur:"
    export STR_LBL_TZ="Zeitzone:"
    export STR_LBL_LANG="Sprache:"
    export STR_LBL_DISK="Laufwerk:"
    export STR_LBL_LUKS="LUKS:"
    export STR_LBL_IDENTITY="Identität:"
    export STR_LBL_CPU="CPU-Ucode:"
    export STR_LBL_ROOT="Root-Sperre:"
    export STR_LBL_MULTILIB="Multilib:"

    # --- Modul: 05_prep ---
    export STR_PREP_HEADER="Phase 1: Live-Umgebung vorbereiten"
    export STR_LOG_TIME_SYNC="Synchronisiere Systemzeit..."
    export STR_LOG_PACMAN_OPT="Optimiere Pacman-Konfiguration (ParallelDownloads & Color)..."
    export STR_LOG_REFLECTOR="Suche schnellste Mirrors mit Reflector..."
    export STR_WARN_DRY_PREP="[DRY-RUN] Live-Umgebung Setup übersprungen."

    # --- Modul: 06_disk (Partitionierung & Formatierung) ---
    export STR_DISK_PHASE_HEADER="Phase 2: Partitionierung & Dateisysteme"
    export STR_LOG_UNMOUNT="Unmounte existierende Partitionen auf %s..."
    export STR_LOG_WIPE="Lösche Dateisystem-Signaturen (Wipe) auf %s..."
    export STR_LOG_PARTITION="Erstelle GPT-Layout auf %s..."
    export STR_LOG_FORMAT_EFI="Formatiere EFI-Partition (%s) als FAT32..."
    export STR_LOG_LUKS_SKIP="LUKS-Verschlüsselung wird übersprungen."
    export STR_LOG_LUKS_FORMAT="LUKS Setup: Formatiere %s mit LUKS2..."
    export STR_LOG_LUKS_OPEN="LUKS Setup: Öffne Container 'cryptroot'..."
    export STR_LOG_FORMAT_BTRFS="Erstelle BTRFS-Dateisystem auf %s..."
    export STR_LOG_SUBVOL="Erstelle BTRFS Subvolumes..."
    export STR_LOG_MOUNT="Mounte Subvolumes unter /mnt..."
    export STR_WARN_DRY_DISK="[DRY-RUN] Partitionierung übersprungen."
    export STR_OK_DISK_DONE="Laufwerk erfolgreich vorbereitet."

    # --- Modul: 07_base (Pacstrap) ---
    export STR_BASE_PHASE_HEADER="Phase 3: Grundsystem (Pacstrap)"
    export STR_LOG_PACSTRAP="Starte Pacstrap (Kernsystem, Kernel, Firmware)..."
    export STR_LOG_FSTAB="Generiere fstab..."
    export STR_WARN_DRY_BASE="[DRY-RUN] Pacstrap übersprungen."
    export STR_OK_BASE_DONE="Grundsystem erfolgreich installiert."

    # --- Modul: 08_chroot_env (Bootloader & Basics) ---
    export STR_ENV_PHASE_HEADER="Phase 4: Zielsystem-Umgebung"
    
    export STR_ENV_HDR_BASICS="Chroot: Basics konfigurieren"
    export STR_LOG_TZ_LOCALE="Setze Timezone (%s) und Locales..."
    export STR_LOG_PACMAN_TARGET="Konfiguriere Pacman im Zielsystem (Color & ILoveCandy)..."
    export STR_OK_BASICS_DONE="Basiskonfiguration im Zielsystem abgeschlossen."
    export STR_WARN_DRY_BASICS="[DRY-RUN] Chroot-Basis-Setup übersprungen."
    
    export STR_ENV_HDR_INITRAMFS="Chroot: Initramfs (mkinitcpio)"
    export STR_LOG_HOOK_LUKS="LUKS-Profil: Füge 'encrypt' Hook nach 'block' hinzu."
    export STR_LOG_HOOKS_DEF="Definierte Hooks: %s"
    export STR_OK_INITRAMFS_DONE="Initramfs Images erfolgreich generiert."
    export STR_WARN_DRY_INITRAMFS="[DRY-RUN] mkinitcpio-Konfiguration übersprungen."
    
    export STR_ENV_HDR_BOOTLOADER="Chroot: Limine Bootloader"
    export STR_LOG_INSTALL_LIMINE="Installiere Limine, efibootmgr und memtest86+..."
    export STR_LOG_GEN_LIMINE_CONF="Generiere limine.conf (Splash, Farben, Memtest, Snapshot-Support)..."
    export STR_LOG_EFI_ENTRY="Kopiere UEFI-Bootfiles, Splash und erstelle NVRAM-Eintrag..."
    export STR_LBL_BOOT_LABEL="Arch Linux"
    export STR_LBL_BOOT_LABEL_LTS="Arch Linux (LTS)"
    export STR_LBL_BOOT_MEMTEST="Memtest86+ v7"
    export STR_OK_BOOTLOADER_DONE="Limine Bootloader erfolgreich installiert."
    export STR_WARN_DRY_BOOTLOADER="[DRY-RUN] Limine-Setup übersprungen."

    # --- Modul: 09_chroot_users (User, Sudo, AUR) ---
    export STR_USR_PHASE_HEADER="Phase 5: Benutzer & Umgebung"
    
    export STR_LOG_ROOT_LOCK="Sperre Root-Account..."
    export STR_LOG_ROOT_UX="Konfiguriere UX-Stack für Root (global in /etc)..."
    export STR_LOG_USER_CREATE="Erstelle Standard-Benutzer (%s)..."
    export STR_LOG_SUDO_SETUP="Konfiguriere Sudo für Gruppe 'wheel'..."
    export STR_LOG_USER_UX="Setze globale UX-Einstellungen für %s..."
    
    export STR_LOG_UX_INSTALL="Installiere UX-Stack (Fish, Starship, Zoxide, Fastfetch)..."
    export STR_LOG_TOOLS_INSTALL="Installiere CLI-Tools (eza, bat, btop)..."
    export STR_LOG_FISH_DEFAULT="Setze Fish als Standard-Shell für %s..."
    
    export STR_LOG_AUR_TEMP_USER="Erstelle temporären AUR-Builduser..."
    export STR_LOG_AUR_BUILD="Baue und installiere Paru (AUR Helper)..."
    export STR_LOG_PARU_CONFIG="Konfiguriere Paru für %s..."
    export STR_LOG_AUR_CLEANUP="Entferne AUR-Builduser und räume auf..."

    export STR_LOG_MICRO_CONFIG="Setze Micro als Standard-Editor (EDITOR)..."
    export STR_LOG_SSH_INSTALL="Installiere und aktiviere OpenSSH..."
    export STR_LOG_DESKTOP_HANDOFF="Erstelle Desktop-Handoff Skript für %s..."
    export STR_LOG_FONTS_XDG="Installiere Basis-Schriften und XDG-Verzeichnisstruktur..."
    
    export STR_WARN_DRY_USERS="[DRY-RUN] User- und Tool-Setup übersprungen."
    export STR_OK_USERS_DONE="Benutzer und Umgebung erfolgreich eingerichtet."

    export STR_LOG_COPY_ASSETS="Kopiere System-Assets und bereite GUI-Handoff vor..."

    # --- Modul: 10_chroot_services (Dienste & Wartung) ---
    export STR_SRV_PHASE_HEADER="Phase 6: Dienste & Systemwartung"
    
    export STR_LOG_NM_ENABLE="Aktiviere NetworkManager..."
    export STR_LOG_BTRFS_SERVICES="Aktiviere BTRFS-Wartungsdienste (Trim & Scrub)..."
    export STR_LOG_SNAPPER_SETUP="Installiere Snapper und erstelle Pacman-Pre-Hook..."
    export STR_LOG_SNAPPER_UPDATE="Aktiviere BTRFS Snapshot-Update Dienst (CachyOS style)..."
    
    export STR_WARN_DRY_SERVICES="[DRY-RUN] Dienste-Konfiguration übersprungen."
    export STR_OK_SERVICES_DONE="Systemdienste erfolgreich konfiguriert."

    # --- Modul: 99_cleanup (Abschluss & Reboot) ---
    export STR_CLN_PHASE_HEADER="Phase 7: Abschluss & Bereinigung"
    export STR_LOG_FINAL_UNMOUNT="Hänge Dateisysteme aus (/mnt)..."
    export STR_LOG_FINAL_LUKS="Schließe LUKS Container..."
    
    export STR_WARN_DRY_CLEANUP="[DRY-RUN] Bereinigung übersprungen."
    export STR_OK_INSTALL_DONE="Installation von Arch Linux erfolgreich abgeschlossen!"
    
    export STR_LOG_ISSUE_SUMMARY="Fehler: %d | Warnungen: %d"
    export STR_LOG_PERFECT_RUN="Perfekter Durchlauf! (0 Fehler, 0 Warnungen)"

    export STR_ASK_REBOOT="Möchtest du das System jetzt neu starten?"
    export STR_LOG_REBOOTING="System wird neu gestartet..."
    export STR_LOG_EXIT="Du bleibst in der Live-Umgebung. Du kannst sie mit 'reboot' verlassen."

    # --- Neue Features: Hardware, Locale, Netzwerk ---
    export STR_ENV_HDR_HW_LOCALE="Hardware-Erkennung & Lokalisierung"
    export STR_LOG_LANG_CHECK="Prüfe Sprachpakete für Sprache: [%s]..."
    export STR_WARN_GPU_NVIDIA="NVIDIA GPU erkannt. Proprietäre Treiber (Closed-Source) werden installiert!"
    export STR_LOG_GPU_AMD="AMD GPU erkannt. Open-Source Treiber werden installiert."
    export STR_LOG_GPU_INTEL="Intel GPU erkannt. Open-Source Treiber werden installiert."
    export STR_LOG_BATTERY="Batterie erkannt. power-profiles-daemon wird installiert."
    export STR_LOG_INSTALL_HW_LOCALE="Installiere Hardwaresupport und Lokalisierungs-Tools..."
    export STR_OK_HW_LOCALE="Hardware & Sprach-Tools eingerichtet."

    export STR_LOG_INSTALL_FIREWALL_MDNS="Installiere Firewall und mDNS (Avahi)..."
    export STR_LOG_CONFIG_MDNS="Konfiguriere mDNS in nsswitch.conf..."
    export STR_LOG_CONFIG_FIREWALL="Setze Firewalld Standard-Zone auf 'home'..."
    export STR_LOG_ENABLE_ADV_SERVICES="Aktiviere Systemd-Dienste (Avahi, Firewalld, PPD)..."
    export STR_OK_ADV_SERVICES="Erweiterte Netzwerkdienste konfiguriert."

    # --- Handoff / Erster Login ---
    export STR_HANDOFF_TITLE="WILLKOMMEN ZU STRATUM OS"
    export STR_HANDOFF_QUESTION="Möchtest du jetzt mit der Installation der GUI (Grafikoberfläche) fortfahren? [j/N]: "
    export STR_HANDOFF_INFO="Kein Problem! Du kannst die Installation jederzeit manuell starten."
    export STR_HANDOFF_PATH_INFO="Die Skripte findest du hier: ~/setup/"
    export STR_HANDOFF_STARTING="Starte GUI-Setup..."
}