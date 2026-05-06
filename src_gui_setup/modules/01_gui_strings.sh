#!/bin/bash
# =========================================
# 📄 Modul: 01_gui_strings
# -----------------------------------------
# Zweck: Texte und Lokalisierung für die GUI
# =========================================

export RED='\033[1;31m'
export GREEN='\033[1;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[1;34m'
export MAGENTA='\033[1;35m'
export CYAN='\033[1;36m'
export BOLD='\033[1m'
export NC='\033[0m'

export STR_GUI_INFO_PREFIX="${MAGENTA}[INFO]${NC}"
export STR_GUI_ERR_PREFIX="${RED}[FEHLER]${NC}"
export STR_GUI_OK_PREFIX="${GREEN}[OK]${NC}"

export STR_GUI_MENU_TITLE="${BOLD}${CYAN} 🚀 DESKTOP-UMGEBUNG AUSWÄHLEN${NC}"
export STR_GUI_MENU_SUB="Wähle deine bevorzugte Oberfläche für die Installation:"
export STR_GUI_MENU_UNINSTALL_TITLE="${BOLD}${CYAN} 🗑️ DEINSTALLATIONS-MENÜ${NC}"
export STR_GUI_OPT_KDE="  ${CYAN}[1]${NC} KDE Plasma"
export STR_GUI_DESC_KDE="      └─ Klassisch, maximal anpassbar (Windows-like)"
export STR_GUI_OPT_COSMIC="  ${CYAN}[2]${NC} COSMIC Desktop"
export STR_GUI_DESC_COSMIC="      └─ Modernste Technik (Rust/Wayland)"
export STR_GUI_OPT_GNOME="  ${CYAN}[3]${NC} GNOME"
export STR_GUI_DESC_GNOME="      └─ Polierter Workflow (macOS-like)"
export STR_GUI_OPT_XFCE="  ${CYAN}[4]${NC} XFCE"
export STR_GUI_DESC_XFCE="      └─ Leichtgewicht, ressourcenschonend (Low-Mem)"
export STR_GUI_OPT_UNINSTALL="  ${CYAN}[5]${NC} Oberfläche deinstallieren..."
export STR_GUI_OPT_APPS="  ${CYAN}[6]${NC} Zusätzliche Anwendungen installieren..."
export STR_GUI_APPS_SUB="Wähle eine Anwendung zur Installation aus:"
export STR_GUI_OPT_LO="  ${CYAN}[1]${NC} LibreOffice"
export STR_GUI_DESC_LO="      └─ Vollständige Office-Suite"
export STR_GUI_OPT_FLATPAK="  ${CYAN}[2]${NC} Flatpak & Flathub"
export STR_GUI_DESC_FLATPAK="      └─ Universelles App-Paketformat"
export STR_GUI_OPT_KVM="  ${CYAN}[3]${NC} KVM / Virt-Manager"
export STR_GUI_DESC_KVM="      └─ Professionelle VM-Virtualisierung"
export STR_GUI_OPT_EXIT="  ${CYAN}[0]${NC} Setup beenden"
export STR_GUI_OPT_BACK="  ${CYAN}[0]${NC} Zurück zum Hauptmenü"
export STR_GUI_PROMPT_YN="${MAGENTA}[INPUT]${NC} (j/n): "
export STR_GUI_PROMPT="${MAGENTA}[INPUT]${NC} Auswahl [0-6]: "

export STR_GUI_LOG_START_KDE="${STR_GUI_INFO_PREFIX} Bereite Installation von KDE Plasma vor..."
export STR_GUI_LOG_START_COSMIC="${STR_GUI_INFO_PREFIX} Bereite Installation von COSMIC Desktop vor..."
export STR_GUI_LOG_START_GNOME="${STR_GUI_INFO_PREFIX} Bereite Installation von GNOME vor..."
export STR_GUI_LOG_START_XFCE="${STR_GUI_INFO_PREFIX} Bereite Installation von XFCE vor..."
export STR_GUI_LOG_START_RM_KDE="${STR_GUI_INFO_PREFIX} Bereite Deinstallation von KDE Plasma vor..."
export STR_GUI_LOG_START_RM_COSMIC="${STR_GUI_INFO_PREFIX} Bereite Deinstallation von COSMIC Desktop vor..."
export STR_GUI_LOG_START_RM_GNOME="${STR_GUI_INFO_PREFIX} Bereite Deinstallation von GNOME vor..."
export STR_GUI_LOG_START_RM_XFCE="${STR_GUI_INFO_PREFIX} Bereite Deinstallation von XFCE vor..."
export STR_GUI_LOG_EXIT="${STR_GUI_INFO_PREFIX} Setup wird beendet. Viel Spaß mit deinem Basis-System!"

# --- Dialog Menü (Ohne ANSI-Farben) ---
export STR_DLG_TITLE="Stratum OS - Desktop Setup"
export STR_DLG_MSG="Wähle deine bevorzugte Oberfläche für die Installation:"
export STR_DLG_OPT_1="KDE Plasma | Klassisch, anpassbar (Windows-like)"
export STR_DLG_OPT_2="COSMIC     | Modernste Technik (Rust/Wayland)"
export STR_DLG_OPT_3="GNOME      | Polierter Workflow (macOS-like)"
export STR_DLG_OPT_4="XFCE       | Leichtgewicht (Low-Mem)"
export STR_DLG_OPT_5="Oberfläche deinstallieren..."
export STR_DLG_OPT_6="Zusätzliche Anwendungen..."
export STR_DLG_OPT_0="Setup beenden"

export STR_DLG_UNINSTALL_TITLE="Stratum OS - Deinstallation"
export STR_DLG_UNINSTALL_MSG="Wähle die zu entfernende Oberfläche:"
export STR_DLG_OPT_BACK="Zurück"

export STR_DLG_APPS_TITLE="Stratum OS - Anwendungen"
export STR_DLG_APPS_MSG="Wähle eine Anwendung zur Installation aus:"
export STR_DLG_OPT_LO="LibreOffice | Vollständige Office-Suite"
export STR_DLG_OPT_FLATPAK="Flatpak | Universelles Paketformat & Flathub"
export STR_DLG_OPT_KVM="KVM/QEMU | Virt-Manager für Virtuelle Maschinen"
export STR_DLG_OPT_DOCKER="Docker | Container-Plattform für Entwickler"

export STR_DLG_APPS_CHECKLIST_MSG="Wähle die zu installierenden Anwendungen (mit Leertaste markieren):"
export STR_DLG_APPS_HARUNA="Haruna | Moderner Video Player (mpv-basiert)"
export STR_DLG_APPS_DISCORD="Discord | Voice- & Text-Chat für Communitys"
export STR_DLG_APPS_GIMP="GIMP | Mächtige Bildbearbeitung (Foto-Fokus)"
export STR_DLG_APPS_OBS="OBS Studio | Streaming & Bildschirmaufnahme"
export STR_DLG_APPS_CODIUM="Code - OSS | Freier & quelloffener Code-Editor"
export STR_DLG_APPS_REMMINA="Remmina | Remote-Desktop-Client (inkl. RDP/VNC/SSH)"
export STR_DLG_APPS_FILEZILLA="FileZilla | Grafischer FTP/SFTP Client"
export STR_DLG_APPS_NEXTCLOUD="Nextcloud | Desktop-Client für deine private Cloud"

export STR_GUI_LOG_APPS_LO="${STR_GUI_INFO_PREFIX} Lade und installiere LibreOffice..."
export STR_GUI_LOG_APPS_FLATPAK="${STR_GUI_INFO_PREFIX} Installiere Flatpak und binde Flathub-Repository ein..."
export STR_GUI_LOG_APPS_KVM="${STR_GUI_INFO_PREFIX} Installiere KVM, QEMU und Virt-Manager (User wird libvirt hinzugefügt)..."

export STR_DLG_FEAT_TITLE="Stratum OS - Optionale Features"
export STR_DLG_FEAT_MSG="Wähle gewünschte Erweiterungen (mit Leertaste markieren):"
export STR_DLG_FEAT_OOTB="Out-of-the-Box Apps (Browser, Mail, Media)"
export STR_DLG_FEAT_GAMING="Gaming-Stack (Steam, Lutris, Wine, Treiber)"

export STR_DLG_SUCCESS_TITLE="Installation Erfolgreich"
export STR_DLG_SUCCESS_KDE="KDE Plasma wurde erfolgreich installiert und konfiguriert!\n\nDu kannst das Setup nun beenden oder weitere Anpassungen vornehmen."
export STR_DLG_SUCCESS_COSMIC="COSMIC Desktop wurde erfolgreich installiert und konfiguriert!\n\nDu kannst das Setup nun beenden oder weitere Anpassungen vornehmen."
export STR_DLG_SUCCESS_GNOME="GNOME wurde erfolgreich installiert und konfiguriert!\n\nDu kannst das Setup nun beenden oder weitere Anpassungen vornehmen."
export STR_DLG_SUCCESS_XFCE="XFCE wurde erfolgreich installiert und konfiguriert!\n\nDu kannst das Setup nun beenden oder weitere Anpassungen vornehmen."

export STR_DLG_ASK_DEEP_CLEAN="Möchtest du alle benutzerspezifischen Konfigurationen (Dotfiles) dieser GUI restlos aus deinem Home-Verzeichnis löschen?"

export STR_GUI_ERR_NO_GUI="${STR_GUI_ERR_PREFIX} Abbruch! Es ist keine Desktop-Umgebung installiert. Bitte installiere zuerst KDE, COSMIC, GNOME oder XFCE."
export STR_GUI_ERR_INVALID="${STR_GUI_ERR_PREFIX} Ungültige Auswahl. Bitte versuche es erneut."
export STR_GUI_ERR_SUDO="${STR_GUI_ERR_PREFIX} Bitte starte das Setup mit sudo: sudo ./install.sh"

export STR_GUI_DUMMY_KDE="KDE Plasma Installations-Dummy erfolgreich aufgerufen."
export STR_GUI_DUMMY_COSMIC="COSMIC Desktop Installations-Dummy erfolgreich aufgerufen."
export STR_GUI_LOG_WAYLAND_ENV="${STR_GUI_INFO_PREFIX} Schreibe globale Wayland-Umgebungsvariablen (Firefox & Electron)..."
export STR_GUI_LOG_KEYMAP="${STR_GUI_INFO_PREFIX} Synchronisiere Tastaturlayout für Login-Screen (Greeter)..."
export STR_GUI_ASK_DEEP_CLEAN="${STR_GUI_INFO_PREFIX} Möchtest du auch alle benutzerspezifischen Konfigurationen (Dotfiles) dieser GUI aus deinem Home-Verzeichnis löschen?"
export STR_GUI_ASK_OOTB="${STR_GUI_INFO_PREFIX} Möchtest du Out-of-the-Box Apps (Browser, Mail, Media) installieren?"
export STR_GUI_LOG_DEEP_CLEAN="${STR_GUI_INFO_PREFIX} Entferne benutzerspezifische Konfigurationsdateien..."
export STR_GUI_ERR_GUI_RUNNING="${STR_GUI_ERR_PREFIX} Abbruch! Diese grafische Oberfläche läuft gerade aktiv. Bitte wechsle in ein TTY (z.B. Strg+Alt+F3), um sie sicher zu deinstallieren."
export STR_GUI_LOG_CLEANUP="${STR_GUI_INFO_PREFIX} Bereinige Pacman-Cache..."
export STR_GUI_ASK_GAMING="${STR_GUI_INFO_PREFIX} Möchtest du den Gaming-Stack (Steam, Lutris, Wine, Gamemode, ProtonUp-Qt) installieren?"
export STR_GUI_LOG_GAMING_SETUP="${STR_GUI_INFO_PREFIX} Konfiguriere Gaming-Umgebung und 32-Bit Bibliotheken..."
export STR_GUI_LOG_GAMING_MULTILIB="${STR_GUI_INFO_PREFIX} Aktiviere [multilib] Repository in pacman.conf..."
export STR_GUI_LOG_GAMING_NVIDIA="${STR_GUI_INFO_PREFIX} NVIDIA GPU erkannt: Installiere lib32-nvidia-utils..."
export STR_GUI_LOG_GAMING_AMD="${STR_GUI_INFO_PREFIX} AMD GPU erkannt: Installiere lib32-vulkan-radeon..."
export STR_GUI_LOG_GAMING_INTEL="${STR_GUI_INFO_PREFIX} Intel GPU erkannt: Installiere lib32-vulkan-intel..."
export STR_GUI_LOG_VERIFY_PKGS="${STR_GUI_INFO_PREFIX} Aktualisiere Paketdatenbanken und verifiziere Verfügbarkeit der Zielpakete..."
export STR_GUI_ERR_MISSING_PKGS="${STR_GUI_ERR_PREFIX} Abbruch! Folgende Pakete konnten in den Arch-Repositories nicht gefunden werden:"

# --- Modul: 03_kde_setup ---
export STR_GUI_KDE_PHASE="${BOLD}${CYAN}--- KDE Plasma Installation ---${NC}"
export STR_GUI_LOG_KDE_HW_DETECT="${STR_GUI_INFO_PREFIX} Starte Hardware-Erkennung für KDE Plasma..."
export STR_GUI_LOG_KDE_AUDIO="${STR_GUI_INFO_PREFIX} Konfiguriere PipeWire Audio-Stack für KDE..."
export STR_GUI_LOG_KDE_PKGS="${STR_GUI_INFO_PREFIX} Lade und installiere KDE Plasma, SDDM und Basis-Apps..."
export STR_GUI_LOG_KDE_ENABLE_SRV="${STR_GUI_INFO_PREFIX} Aktiviere Systemdienste (SDDM, Power-Profiles)..."
export STR_GUI_OK_KDE="${STR_GUI_OK_PREFIX} KDE Plasma erfolgreich installiert und konfiguriert!"

export STR_GUI_KDE_RM_PHASE="${BOLD}${CYAN}--- KDE Plasma Deinstallation ---${NC}"
export STR_GUI_LOG_KDE_DISABLE_SRV="${STR_GUI_INFO_PREFIX} Stoppe und deaktiviere KDE-Dienste (SDDM)..."
export STR_GUI_LOG_KDE_RM_PKGS="${STR_GUI_INFO_PREFIX} Entferne KDE Plasma Pakete (ohne Hardware-Treiber)..."
export STR_GUI_OK_RM_KDE="${STR_GUI_OK_PREFIX} KDE Plasma erfolgreich restlos entfernt!"

# --- Modul: 04_cosmic_setup ---
export STR_GUI_COSMIC_PHASE="${BOLD}${CYAN}--- COSMIC Desktop Installation ---${NC}"
export STR_GUI_LOG_HW_DETECT="${STR_GUI_INFO_PREFIX} Starte Hardware-Erkennung für COSMIC..."
export STR_GUI_LOG_VM_DETECTED="${STR_GUI_INFO_PREFIX} Virtuelle Maschine erkannt. Füge VM-Tools hinzu (spice-vdagent, qemu-guest-agent)..."
export STR_GUI_LOG_BT_DETECTED="${STR_GUI_INFO_PREFIX} Bluetooth-Controller erkannt. Füge BlueZ-Stack hinzu..."
export STR_GUI_LOG_AUDIO="${STR_GUI_INFO_PREFIX} Konfiguriere modernes Audio-Setup (PipeWire & WirePlumber)..."
export STR_GUI_LOG_OOTB_ASK="${STR_GUI_INFO_PREFIX} Möchtest du Out-of-the-Box Apps (Firefox, Fonts, Gnome-Keyring, Evince, Archive-Tools) mitinstallieren?"
export STR_GUI_LOG_LANG_PKG_FOUND="${STR_GUI_INFO_PREFIX} Passendes Sprachpaket gefunden und zur Installation markiert"
export STR_GUI_LOG_OOTB_PKGS="${STR_GUI_INFO_PREFIX} Lade und installiere Out-of-the-Box Anwendungen..."
export STR_GUI_LOG_FF_POLICY="${STR_GUI_INFO_PREFIX} Wende gehärtete Firefox Enterprise Policies an (Brave, HTTPS-Only, Telemetry-Off)..."
export STR_GUI_LOG_COSMIC_PKGS="${STR_GUI_INFO_PREFIX} Lade und installiere COSMIC Core-Pakete und Greeter..."
export STR_GUI_LOG_ENABLE_SRV="${STR_GUI_INFO_PREFIX} Aktiviere Systemdienste (Display Manager, Network, Bluetooth)..."
export STR_GUI_OK_COSMIC="${STR_GUI_OK_PREFIX} COSMIC Desktop erfolgreich installiert und konfiguriert!"
export STR_GUI_ERR_PACMAN="${STR_GUI_ERR_PREFIX} Fehler bei der Paketinstallation (Pacman). Abbruch."

export STR_GUI_COSMIC_RM_PHASE="${BOLD}${CYAN}--- COSMIC Desktop Deinstallation ---${NC}"
export STR_GUI_LOG_COSMIC_DISABLE_SRV="${STR_GUI_INFO_PREFIX} Stoppe und deaktiviere COSMIC-Dienste (Greeter)..."
export STR_GUI_LOG_COSMIC_RM_PKGS="${STR_GUI_INFO_PREFIX} Entferne COSMIC Desktop Pakete (ohne Hardware-Treiber)..."
export STR_GUI_OK_RM_COSMIC="${STR_GUI_OK_PREFIX} COSMIC Desktop erfolgreich restlos entfernt!"

# --- Modul: 07_gnome_setup ---
export STR_GUI_GNOME_PHASE="${BOLD}${CYAN}--- GNOME Installation ---${NC}"
export STR_GUI_LOG_GNOME_HW_DETECT="${STR_GUI_INFO_PREFIX} Starte Hardware-Erkennung für GNOME..."
export STR_GUI_LOG_GNOME_PKGS="${STR_GUI_INFO_PREFIX} Lade und installiere GNOME Desktop und GDM..."
export STR_GUI_LOG_GNOME_ENABLE_SRV="${STR_GUI_INFO_PREFIX} Aktiviere Systemdienste (GDM, Power-Profiles)..."
export STR_GUI_OK_GNOME="${STR_GUI_OK_PREFIX} GNOME erfolgreich installiert und konfiguriert!"

export STR_GUI_GNOME_RM_PHASE="${BOLD}${CYAN}--- GNOME Deinstallation ---${NC}"
export STR_GUI_LOG_GNOME_DISABLE_SRV="${STR_GUI_INFO_PREFIX} Stoppe und deaktiviere GNOME-Dienste (GDM)..."
export STR_GUI_LOG_GNOME_RM_PKGS="${STR_GUI_INFO_PREFIX} Entferne GNOME Pakete..."
export STR_GUI_OK_RM_GNOME="${STR_GUI_OK_PREFIX} GNOME erfolgreich restlos entfernt!"

# --- Modul: 08_xfce_setup ---
export STR_GUI_XFCE_PHASE="${BOLD}${CYAN}--- XFCE Installation ---${NC}"
export STR_GUI_LOG_XFCE_HW_DETECT="${STR_GUI_INFO_PREFIX} Starte Hardware-Erkennung für XFCE..."
export STR_GUI_LOG_XFCE_PKGS="${STR_GUI_INFO_PREFIX} Lade und installiere XFCE Desktop und LightDM..."
export STR_GUI_LOG_XFCE_ENABLE_SRV="${STR_GUI_INFO_PREFIX} Aktiviere Systemdienste (LightDM, Power-Profiles)..."
export STR_GUI_OK_XFCE="${STR_GUI_OK_PREFIX} XFCE erfolgreich installiert und konfiguriert!"

export STR_GUI_XFCE_RM_PHASE="${BOLD}${CYAN}--- XFCE Deinstallation ---${NC}"
export STR_GUI_LOG_XFCE_DISABLE_SRV="${STR_GUI_INFO_PREFIX} Stoppe und deaktiviere XFCE-Dienste (LightDM)..."
export STR_GUI_LOG_XFCE_RM_PKGS="${STR_GUI_INFO_PREFIX} Entferne XFCE Pakete..."
export STR_GUI_OK_RM_XFCE="${STR_GUI_OK_PREFIX} XFCE erfolgreich restlos entfernt!"
