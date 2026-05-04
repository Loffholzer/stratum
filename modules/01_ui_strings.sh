#!/usr/bin/env bash

# =========================================
# 📄 DATEI: 01_ui_strings.sh
# 💡 ZWECK: Zentrale UI-Texte & Lokalisierung (DE)
# =========================================

# =========================================
# 📦 Funktion: load_ui_strings
# -----------------------------------------
# Zweck: Deutschsprachige Strings (DE)
# =========================================

load_strings_de() {
    # --- Allgemeines ---
    export STR_PROMPT_SEL_1_2="Auswahl [1-2]: "
    export STR_PROMPT_SEL_1_3="Auswahl [1-3]: "
    export STR_PROMPT_YN="(j/n)"
    export STR_WARN_YES_NO="Bitte mit j/n antworten."
    export STR_WARN_INVALID_SEL="Ungültige Auswahl."
    export STR_PROMPT_SELECT_NUM="Nummer wählen (0 für Abbruch): "
    export STR_LOG_USER_ABORT="Abbruch durch Benutzer."

    # --- Modul 03: Systemkonfiguration ---
    export STR_SYS_HEADER="System-Konfiguration"
    export STR_ERR_ROOT_REQ="Ausführung als Root erforderlich."
    export STR_ERR_UEFI_REQ="UEFI-Umgebung zwingend erforderlich."
    export STR_LOG_INTEL_CPU="Intel CPU erkannt."
    export STR_LOG_AMD_CPU="AMD CPU erkannt."
    export STR_WARN_UNKNOWN_CPU="Unbekannte CPU. Kein Microcode."
    export STR_ERR_AUTO_DRY_RUN="AUTO_MODE darf nicht mit DRY_RUN=false laufen!"
    export STR_LOG_AUTO_ACTIVE="AUTO-MODE aktiv. Überspringe Eingaben."

    # Tastatur
    export STR_PHASE_KEYMAP="Tastaturlayout"
    export STR_OPT_AUTO="(Automatisch)"
    export STR_OPT_US_STD="us (Standard)"
    export STR_OPT_MANUAL_SEARCH="Manuell suchen"
    export STR_PROMPT_SEARCH_KEYMAP="Suche (z.B. de, fr): "
    export STR_TITLE_KEYMAP_HITS="Keymap Treffer"
    export STR_WARN_KEYMAP_LIVE_FAIL="Konnte Layout im Live-System nicht setzen."
    export STR_WARN_NO_HITS="Keine Treffer."
    export STR_WARN_TOO_MANY_HITS="Zu viele Treffer. Bitte verfeinern."

    # Zeitzone
    export STR_PHASE_TIMEZONE="Zeitzone"
    export STR_LOG_RECOGNIZED="Erkannt: "
    export STR_OPT_USE_RECOGNIZED_TZ="Erkannte Zeitzone nutzen"
    export STR_PROMPT_SEARCH_TZ="Suche (z.B. berlin, tokyo): "
    export STR_TITLE_TZ_HITS="Zeitzonen Treffer"
    export STR_LOG_TZ_AUTO_FAIL="Automatische Zeitzonen-Erkennung fehlgeschlagen. Manuelle Suche erforderlich."

    # Locale
    export STR_PHASE_LOCALE="Systemsprache (Locale)"
    export STR_LOG_LOCALE_HINT="Hinweis: en_US.UTF-8 wird immer generiert."
    export STR_OPT_PLUS_EN_US=" + en_US.UTF-8"
    export STR_OPT_ONLY_EN_US="Nur en_US.UTF-8"
    export STR_PROMPT_SEARCH_LOCALE="Suche (z.B. fr_FR, es_ES): "
    export STR_TITLE_LOCALE_HITS="Locale Treffer"

    # Identität
    export STR_PHASE_IDENTITY="Identität & Module"
    export STR_PROMPT_HOSTNAME="Hostname (z.B. arch-pc): "
    export STR_PROMPT_USERNAME="Username (z.B. max): "
    export STR_PROMPT_PASS_USER="User-Passwort: "
    export STR_PROMPT_PASS_CONFIRM="Passwort wiederholen: "
    export STR_ASK_CONFIRM_INPUT="Eingabe korrekt?"
    export STR_WARN_HOSTNAME_RULES="Erlaubt: a-z, 0-9, Bindestrich."
    export STR_WARN_USERNAME_RULES="Erlaubt: a-z, 0-9, Unterstrich. Beginnend mit Buchstabe."
    export STR_ERR_PASS_MISMATCH="Passwörter stimmen nicht überein."

    # --- Modul 04: Laufwerkskonfiguration ---
    export STR_DISK_HEADER="Laufwerkskonfiguration"
    export STR_PHASE_DISK_SEL="Ziellaufwerk auswählen"
    export STR_PHASE_PROFIL_SEL="Disk-Setup / Verschlüsselung"
    export STR_PROMPT_LUKS_PASS="LUKS-Passwort (Verschlüsselung): "
    export STR_ERR_NO_DISK="Keine geeigneten Laufwerke gefunden."
    export STR_LOG_FOUND_DISKS="Gefundene Laufwerke:"
    export STR_OPT_PROF_STD="Standard (BTRFS Subvolumes, unverschlüsselt)"
    export STR_OPT_PROF_LUKS="LUKS (BTRFS auf LUKS2, verschlüsselt)"

    # Zusammenfassung
    export STR_SUMMARY_HEADER="Zusammenfassung (Point of no Return)"
    export STR_WARN_DELETE="ACHTUNG: Alle Daten auf %s werden unwiderruflich GELÖSCHT!"
    export STR_ASK_START_INSTALL="Installation jetzt starten?"
    export STR_LBL_KEY="Tastatur:"
    export STR_LBL_TZ="Zeitzone:"
    export STR_LBL_LANG="Sprache:"
    export STR_LBL_DISK="Laufwerk:"
    export STR_LBL_LUKS="LUKS:"
    export STR_LBL_IDENTITY="Identität:"
    export STR_LBL_CPU="CPU-Ucode:"

    # --- Modul 05: Live-Umgebung ---
    export STR_PREP_HEADER="Phase 1: Live-Umgebung vorbereiten"
    export STR_LOG_TIME_SYNC="Synchronisiere Systemzeit..."
    export STR_LOG_PACMAN_OPT="Optimiere Pacman-Konfiguration (ParallelDownloads & Color)..."
    export STR_LOG_REFLECTOR="Suche schnellste Mirrors mit Reflector..."
    export STR_WARN_DRY_PREP="[DRY-RUN] Live-Umgebung Setup übersprungen."

    # --- Modul 06: Partitionierung ---
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

    # --- Modul 07: Grundsystem ---
    export STR_BASE_PHASE_HEADER="Phase 3: Grundsystem (Pacstrap)"
    export STR_LOG_PACSTRAP="Starte Pacstrap (Kernsystem, Kernel, Firmware)..."
    export STR_LOG_FSTAB="Generiere fstab..."
    export STR_WARN_DRY_BASE="[DRY-RUN] Pacstrap übersprungen."
    export STR_OK_BASE_DONE="Grundsystem erfolgreich installiert."

    # --- Modul 08: Zielsystem-Umgebung ---
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
    export STR_ENV_HDR_HW_LOCALE="Hardware-Erkennung & Lokalisierung"
    export STR_LOG_LANG_CHECK="Prüfe Sprachpakete für Sprache: [%s]..."
    export STR_WARN_GPU_NVIDIA="NVIDIA GPU erkannt. Proprietäre Treiber (Closed-Source) werden installiert!"
    export STR_LOG_GPU_AMD="AMD GPU erkannt. Open-Source Treiber werden installiert."
    export STR_LOG_GPU_INTEL="Intel GPU erkannt. Open-Source Treiber werden installiert."
    export STR_LOG_BATTERY="Batterie erkannt. power-profiles-daemon wird installiert."
    export STR_LOG_INSTALL_HW_LOCALE="Installiere Hardwaresupport und Lokalisierungs-Tools..."
    export STR_OK_HW_LOCALE="Hardware & Sprach-Tools eingerichtet."

    # --- Modul 09: Benutzer & Umgebung ---
    export STR_USR_PHASE_HEADER="Phase 5: Benutzer & Umgebung"
    export STR_LOG_ROOT_LOCK="Sperre Root-Account..."
    export STR_LOG_USER_CREATE="Erstelle Standard-Benutzer (%s)..."
    export STR_LOG_SUDO_SETUP="Konfiguriere Sudo für Gruppe 'wheel'..."
    export STR_LOG_UX_INSTALL="Installiere UX-Stack (Fish, Starship, Zoxide, Fastfetch)..."
    export STR_LOG_ROOT_UX="Konfiguriere UX-Stack für Root (global in /etc)..."
    export STR_LOG_FISH_DEFAULT="Setze Fish als Standard-Shell für %s..."
    export STR_LOG_TOOLS_INSTALL="Installiere CLI-Tools (eza, bat, btop)..."
    export STR_LOG_AUR_TEMP_USER="Erstelle temporären AUR-Builduser..."
    export STR_LOG_AUR_BUILD="Baue und installiere Paru (AUR Helper)..."
    export STR_LOG_PARU_CONFIG="Konfiguriere Paru für %s..."
    export STR_LOG_AUR_CLEANUP="Entferne AUR-Builduser und räume auf..."
    export STR_LOG_MICRO_CONFIG="Setze Micro als Standard-Editor (EDITOR)..."
    export STR_LOG_SSH_INSTALL="Installiere und aktiviere OpenSSH..."
    export STR_LOG_FONTS_XDG="Installiere Basis-Schriften und XDG-Verzeichnisstruktur..."
    export STR_LOG_COPY_ASSETS="Kopiere System-Assets und bereite GUI-Handoff vor..."
    export STR_WARN_DRY_USERS="[DRY-RUN] User- und Tool-Setup übersprungen."
    export STR_OK_USERS_DONE="Benutzer und Umgebung erfolgreich eingerichtet."

    # --- Modul 10: Dienste & Wartung ---
    export STR_SRV_PHASE_HEADER="Phase 6: Dienste & Systemwartung"
    export STR_LOG_NM_ENABLE="Aktiviere NetworkManager..."
    export STR_LOG_BTRFS_SERVICES="Aktiviere BTRFS-Wartungsdienste (Trim & Scrub)..."
    export STR_LOG_INSTALL_FIREWALL_MDNS="Installiere Firewall und mDNS (Avahi)..."
    export STR_LOG_CONFIG_MDNS="Konfiguriere mDNS in nsswitch.conf..."
    export STR_LOG_CONFIG_FIREWALL="Setze Firewalld Standard-Zone auf 'home'..."
    export STR_LOG_ENABLE_ADV_SERVICES="Aktiviere Systemd-Dienste (Avahi, Firewalld, PPD)..."
    export STR_OK_ADV_SERVICES="Erweiterte Netzwerkdienste konfiguriert."
    export STR_LOG_SNAPPER_SETUP="Installiere Snapper und erstelle Pacman-Pre-Hook..."
    export STR_LOG_SNAPPER_UPDATE="Aktiviere BTRFS Snapshot-Update Dienst (CachyOS style)..."
    export STR_WARN_DRY_SERVICES="[DRY-RUN] Dienste-Konfiguration übersprungen."
    export STR_OK_SERVICES_DONE="Systemdienste erfolgreich konfiguriert."

    # --- Modul 99: Abschluss ---
    export STR_CLN_PHASE_HEADER="Phase 7: Abschluss & Bereinigung"
    export STR_LOG_FINAL_UNMOUNT="Hänge Dateisysteme aus (/mnt)..."
    export STR_LOG_FINAL_LUKS="Schließe LUKS Container..."
    export STR_WARN_DRY_CLEANUP="[DRY-RUN] Bereinigung übersprungen."
    export STR_OK_INSTALL_DONE="Installation von Arch Linux erfolgreich abgeschlossen!"
    export STR_LOG_ISSUE_SUMMARY="Fehler: %d | Warnungen: %d"
    export STR_LOG_PERFECT_RUN="Installation fehlerfrei abgeschlossen (0 Fehler, 0 Warnungen)."
    export STR_ASK_REBOOT="Möchtest du das System jetzt neu starten?"
    export STR_LOG_REBOOTING="System wird neu gestartet..."
    export STR_LOG_EXIT="Du bleibst in der Live-Umgebung. Du kannst sie mit 'reboot' verlassen."

    # --- Handoff (Erster Login nach Reboot) ---
    export STR_HANDOFF_TITLE="WILLKOMMEN ZU STRATUM OS"
    export STR_HANDOFF_QUESTION="Möchtest du jetzt mit der Installation der GUI (Grafikoberfläche) fortfahren? [j/N]: "
    export STR_HANDOFF_INFO="Kein Problem! Du kannst die Installation jederzeit manuell starten."
    export STR_HANDOFF_PATH_INFO="Die Skripte findest du hier: ~/setup/"
    export STR_HANDOFF_STARTING="Starte GUI-Setup..."
}

# =========================================
# 📦 Funktion: load_strings_en
# -----------------------------------------
# Zweck: Englischsprachige Strings (EN)
# =========================================
load_strings_en() {
    # --- General ---
    export STR_PROMPT_SEL_1_2="Selection [1-2]: "
    export STR_PROMPT_SEL_1_3="Selection [1-3]: "
    export STR_PROMPT_YN="(y/n)"
    export STR_WARN_YES_NO="Please answer with y/n."
    export STR_WARN_INVALID_SEL="Invalid selection."
    export STR_PROMPT_SELECT_NUM="Select number (0 to abort): "
    export STR_LOG_USER_ABORT="Aborted by user."

    # --- Module 03: System Configuration ---
    export STR_SYS_HEADER="System Configuration"
    export STR_ERR_ROOT_REQ="Root privileges required."
    export STR_ERR_UEFI_REQ="UEFI environment strictly required."
    export STR_LOG_INTEL_CPU="Intel CPU detected."
    export STR_LOG_AMD_CPU="AMD CPU detected."
    export STR_WARN_UNKNOWN_CPU="Unknown CPU. No microcode."
    export STR_ERR_AUTO_DRY_RUN="AUTO_MODE cannot run with DRY_RUN=false!"
    export STR_LOG_AUTO_ACTIVE="AUTO-MODE active. Skipping inputs."

    # Keyboard
    export STR_PHASE_KEYMAP="Keyboard Layout"
    export STR_OPT_AUTO="(Automatic)"
    export STR_OPT_US_STD="us (Standard)"
    export STR_OPT_MANUAL_SEARCH="Manual search"
    export STR_PROMPT_SEARCH_KEYMAP="Search (e.g., us, fr): "
    export STR_TITLE_KEYMAP_HITS="Keymap Matches"
    export STR_WARN_KEYMAP_LIVE_FAIL="Could not set layout in live system."
    export STR_WARN_NO_HITS="No matches."
    export STR_WARN_TOO_MANY_HITS="Too many matches. Please refine."

    # Timezone
    export STR_PHASE_TIMEZONE="Timezone"
    export STR_LOG_RECOGNIZED="Detected: "
    export STR_OPT_USE_RECOGNIZED_TZ="Use detected timezone"
    export STR_PROMPT_SEARCH_TZ="Search (e.g., berlin, tokyo): "
    export STR_TITLE_TZ_HITS="Timezone Matches"
    export STR_LOG_TZ_AUTO_FAIL="Automatic timezone detection failed. Manual search required."

    # Locale
    export STR_PHASE_LOCALE="System Language (Locale)"
    export STR_LOG_LOCALE_HINT="Note: en_US.UTF-8 is always generated."
    export STR_OPT_PLUS_EN_US=" + en_US.UTF-8"
    export STR_OPT_ONLY_EN_US="Only en_US.UTF-8"
    export STR_PROMPT_SEARCH_LOCALE="Search (e.g., fr_FR, es_ES): "
    export STR_TITLE_LOCALE_HITS="Locale Matches"

    # Identity
    export STR_PHASE_IDENTITY="Identity & Modules"
    export STR_PROMPT_HOSTNAME="Hostname (e.g., arch-pc): "
    export STR_PROMPT_USERNAME="Username (e.g., max): "
    export STR_PROMPT_PASS_USER="User password: "
    export STR_PROMPT_PASS_CONFIRM="Repeat password: "
    export STR_ASK_CONFIRM_INPUT="Input correct?"
    export STR_WARN_HOSTNAME_RULES="Allowed: a-z, 0-9, hyphen."
    export STR_WARN_USERNAME_RULES="Allowed: a-z, 0-9, underscore. Starts with a letter."
    export STR_ERR_PASS_MISMATCH="Passwords do not match."

    # --- Module 04: Drive Configuration ---
    export STR_DISK_HEADER="Drive Configuration"
    export STR_PHASE_DISK_SEL="Select Target Drive"
    export STR_PHASE_PROFIL_SEL="Disk Setup / Encryption"
    export STR_PROMPT_LUKS_PASS="LUKS password (encryption): "
    export STR_ERR_NO_DISK="No suitable drives found."
    export STR_LOG_FOUND_DISKS="Found drives:"
    export STR_OPT_PROF_STD="Standard (BTRFS subvolumes, unencrypted)"
    export STR_OPT_PROF_LUKS="LUKS (BTRFS on LUKS2, encrypted)"

    # Summary
    export STR_SUMMARY_HEADER="Summary (Point of no Return)"
    export STR_WARN_DELETE="WARNING: All data on %s will be irrevocably DELETED!"
    export STR_ASK_START_INSTALL="Start installation now?"
    export STR_LBL_KEY="Keyboard:"
    export STR_LBL_TZ="Timezone:"
    export STR_LBL_LANG="Language:"
    export STR_LBL_DISK="Drive:"
    export STR_LBL_LUKS="LUKS:"
    export STR_LBL_IDENTITY="Identity:"
    export STR_LBL_CPU="CPU ucode:"

    # --- Phases ---
    export STR_PREP_HEADER="Phase 1: Prepare Live Environment"
    export STR_LOG_TIME_SYNC="Synchronizing system time..."
    export STR_LOG_PACMAN_OPT="Optimizing Pacman config (ParallelDownloads & Color)..."
    export STR_LOG_REFLECTOR="Searching for fastest mirrors with Reflector..."
    export STR_WARN_DRY_PREP="[DRY-RUN] Live environment setup skipped."

    export STR_DISK_PHASE_HEADER="Phase 2: Partitioning & Filesystems"
    export STR_LOG_UNMOUNT="Unmounting existing partitions on %s..."
    export STR_LOG_WIPE="Wiping filesystem signatures on %s..."
    export STR_LOG_PARTITION="Creating GPT layout on %s..."
    export STR_LOG_FORMAT_EFI="Formatting EFI partition (%s) as FAT32..."
    export STR_LOG_LUKS_SKIP="LUKS encryption skipped."
    export STR_LOG_LUKS_FORMAT="LUKS Setup: Formatting %s with LUKS2..."
    export STR_LOG_LUKS_OPEN="LUKS Setup: Opening container 'cryptroot'..."
    export STR_LOG_FORMAT_BTRFS="Creating BTRFS filesystem on %s..."
    export STR_LOG_SUBVOL="Creating BTRFS subvolumes..."
    export STR_LOG_MOUNT="Mounting subvolumes to /mnt..."
    export STR_WARN_DRY_DISK="[DRY-RUN] Partitioning skipped."
    export STR_OK_DISK_DONE="Drive successfully prepared."

    export STR_BASE_PHASE_HEADER="Phase 3: Base System (Pacstrap)"
    export STR_LOG_PACSTRAP="Running pacstrap (core system, kernel, firmware)..."
    export STR_LOG_FSTAB="Generating fstab..."
    export STR_WARN_DRY_BASE="[DRY-RUN] Pacstrap skipped."
    export STR_OK_BASE_DONE="Base system successfully installed."

    export STR_ENV_PHASE_HEADER="Phase 4: Target System Environment"
    export STR_ENV_HDR_BASICS="Chroot: Configure Basics"
    export STR_LOG_TZ_LOCALE="Setting timezone (%s) and locales..."
    export STR_LOG_PACMAN_TARGET="Configuring Pacman in target system (Color & ILoveCandy)..."
    export STR_OK_BASICS_DONE="Basic configuration completed."
    export STR_WARN_DRY_BASICS="[DRY-RUN] Chroot basics setup skipped."
    export STR_ENV_HDR_INITRAMFS="Chroot: Initramfs (mkinitcpio)"
    export STR_LOG_HOOK_LUKS="LUKS Profile: Adding 'encrypt' hook after 'block'."
    export STR_LOG_HOOKS_DEF="Defined hooks: %s"
    export STR_OK_INITRAMFS_DONE="Initramfs images successfully generated."
    export STR_WARN_DRY_INITRAMFS="[DRY-RUN] mkinitcpio configuration skipped."
    export STR_ENV_HDR_BOOTLOADER="Chroot: Limine Bootloader"
    export STR_LOG_INSTALL_LIMINE="Installing Limine, efibootmgr, and memtest86+..."
    export STR_LOG_GEN_LIMINE_CONF="Generating limine.conf (Splash, Colors, Memtest, Snapshot support)..."
    export STR_LOG_EFI_ENTRY="Copying UEFI bootfiles, splash, and creating NVRAM entry..."
    export STR_LBL_BOOT_LABEL="Arch Linux"
    export STR_LBL_BOOT_LABEL_LTS="Arch Linux (LTS)"
    export STR_LBL_BOOT_MEMTEST="Memtest86+ v7"
    export STR_OK_BOOTLOADER_DONE="Limine Bootloader successfully installed."
    export STR_WARN_DRY_BOOTLOADER="[DRY-RUN] Limine setup skipped."
    export STR_ENV_HDR_HW_LOCALE="Hardware Detection & Localization"
    export STR_LOG_LANG_CHECK="Checking language packages for: [%s]..."
    export STR_WARN_GPU_NVIDIA="NVIDIA GPU detected. Proprietary drivers (closed-source) will be installed!"
    export STR_LOG_GPU_AMD="AMD GPU detected. Open-source drivers will be installed."
    export STR_LOG_GPU_INTEL="Intel GPU detected. Open-source drivers will be installed."
    export STR_LOG_BATTERY="Battery detected. power-profiles-daemon will be installed."
    export STR_LOG_INSTALL_HW_LOCALE="Installing hardware support and localization tools..."
    export STR_OK_HW_LOCALE="Hardware & language tools configured."

    export STR_USR_PHASE_HEADER="Phase 5: Users & Environment"
    export STR_LOG_ROOT_LOCK="Locking root account..."
    export STR_LOG_USER_CREATE="Creating standard user (%s)..."
    export STR_LOG_SUDO_SETUP="Configuring sudo for 'wheel' group..."
    export STR_LOG_UX_INSTALL="Installing UX stack (Fish, Starship, Zoxide, Fastfetch)..."
    export STR_LOG_ROOT_UX="Configuring UX stack for root (globally in /etc)..."
    export STR_LOG_FISH_DEFAULT="Setting Fish as default shell for %s..."
    export STR_LOG_TOOLS_INSTALL="Installing CLI tools (eza, bat, btop)..."
    export STR_LOG_AUR_TEMP_USER="Creating temporary AUR build user..."
    export STR_LOG_AUR_BUILD="Building and installing Paru (AUR Helper)..."
    export STR_LOG_PARU_CONFIG="Configuring Paru for %s..."
    export STR_LOG_AUR_CLEANUP="Removing AUR build user and cleaning up..."
    export STR_LOG_MICRO_CONFIG="Setting Micro as default editor (EDITOR)..."
    export STR_LOG_SSH_INSTALL="Installing and enabling OpenSSH..."
    export STR_LOG_FONTS_XDG="Installing base fonts and XDG directory structure..."
    export STR_LOG_COPY_ASSETS="Copying system assets and preparing GUI handoff..."
    export STR_WARN_DRY_USERS="[DRY-RUN] User and tool setup skipped."
    export STR_OK_USERS_DONE="Users and environment successfully configured."

    export STR_SRV_PHASE_HEADER="Phase 6: Services & System Maintenance"
    export STR_LOG_NM_ENABLE="Enabling NetworkManager..."
    export STR_LOG_BTRFS_SERVICES="Enabling BTRFS maintenance services (Trim & Scrub)..."
    export STR_LOG_INSTALL_FIREWALL_MDNS="Installing firewall and mDNS (Avahi)..."
    export STR_LOG_CONFIG_MDNS="Configuring mDNS in nsswitch.conf..."
    export STR_LOG_CONFIG_FIREWALL="Setting Firewalld default zone to 'home'..."
    export STR_LOG_ENABLE_ADV_SERVICES="Enabling Systemd services (Avahi, Firewalld, PPD)..."
    export STR_OK_ADV_SERVICES="Advanced network services configured."
    export STR_LOG_SNAPPER_SETUP="Installing Snapper and creating Pacman pre-hook..."
    export STR_LOG_SNAPPER_UPDATE="Enabling BTRFS snapshot update service (CachyOS style)..."
    export STR_WARN_DRY_SERVICES="[DRY-RUN] Services configuration skipped."
    export STR_OK_SERVICES_DONE="System services successfully configured."

    export STR_CLN_PHASE_HEADER="Phase 7: Completion & Cleanup"
    export STR_LOG_FINAL_UNMOUNT="Unmounting filesystems (/mnt)..."
    export STR_LOG_FINAL_LUKS="Closing LUKS container..."
    export STR_WARN_DRY_CLEANUP="[DRY-RUN] Cleanup skipped."
    export STR_OK_INSTALL_DONE="Arch Linux installation successfully completed!"
    export STR_LOG_ISSUE_SUMMARY="Errors: %d | Warnings: %d"
    export STR_LOG_PERFECT_RUN="Installation completed perfectly (0 errors, 0 warnings)."
    export STR_ASK_REBOOT="Do you want to reboot the system now?"
    export STR_LOG_REBOOTING="System is rebooting..."
    export STR_LOG_EXIT="You remain in the live environment. You can leave it with 'reboot'."

    # Handoff
    export STR_HANDOFF_TITLE="WELCOME TO STRATUM OS"
    export STR_HANDOFF_QUESTION="Do you want to proceed with the GUI installation now? [y/N]: "
    export STR_HANDOFF_INFO="No problem! You can start the installation manually at any time."
    export STR_HANDOFF_PATH_INFO="You can find the scripts here: ~/setup/"
    export STR_HANDOFF_STARTING="Starting GUI setup..."
}

# =========================================
# 📦 Funktion: load_ui_strings
# -----------------------------------------
# Zweck: Sprachabfrage & Hauptcontroller
# =========================================
load_ui_strings() {
    if [[ "${AUTO_MODE:-false}" == "true" ]]; then
        load_strings_en
        return 0
    fi

    echo -e "\n${BLUE}=========================================${NC}"
    echo -e "${BOLD}${CYAN} 🌐 SELECT INSTALLER LANGUAGE / SPRACHE WÄHLEN${NC}"
    echo -e "${BLUE}=========================================${NC}\n"
    echo -e "  ${CYAN}[1]${NC} English"
    echo -e "  ${CYAN}[2]${NC} Deutsch\n"

    local choice
    while true; do
        read -rp "$(echo -e "${BLUE}[INPUT]${NC} Selection / Auswahl [1-2]: ")" choice
        case "$choice" in
            1) 
                load_strings_en
                break 
                ;;
            2) 
                load_strings_de
                break 
                ;;
            *) 
                echo -e "${RED}[ERROR]${NC} Invalid selection / Ungültige Auswahl." >&2 
                ;;
        esac
    done
    
    # Terminal aufräumen, um sauber ins Modul 03 zu starten
    clear
}