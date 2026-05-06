#!/usr/bin/env bash

# =========================================
# 📄 DATEI: 08_xfce_setup.sh
# 💡 ZWECK: Installation & Konfiguration von XFCE Desktop
# =========================================

export ENABLE_BLUETOOTH=false
export ENABLE_QEMU_GA=false
export INSTALL_OOTB=false
export INSTALL_GAMING=false
export PURGE_CONFIGS=false

# =========================================
# 📦 Funktion: xfce_ask_features
# -----------------------------------------
# Zweck: Fragt den Benutzer nach OOTB-Apps und Gaming-Tools
# Aufgabe: Kombiniert Abfragen in einer übersichtlichen Dialog-Checklist
# =========================================
xfce_ask_features() {
    if command -v dialog >/dev/null 2>&1; then
        local choices
        choices=$(dialog --clear --title "$STR_DLG_FEAT_TITLE" --checklist "$STR_DLG_FEAT_MSG" 15 75 2 \
            "OOTB" "$STR_DLG_FEAT_OOTB" off \
            "GAMING" "$STR_DLG_FEAT_GAMING" off 3>&1 1>&2 2>&3)
        
        if [[ $choices == *"OOTB"* ]]; then INSTALL_OOTB=true; else INSTALL_OOTB=false; fi
        if [[ $choices == *"GAMING"* ]]; then INSTALL_GAMING=true; else INSTALL_GAMING=false; fi
    else
        # CLI Fallback
        echo -e "\n${STR_GUI_ASK_OOTB}"
        local choice_ootb
        while true; do
            read -rp "$(echo -e "${STR_GUI_PROMPT_YN}")" choice_ootb
            case "${choice_ootb,,}" in
                j|ja|y|yes) INSTALL_OOTB=true; break ;;
                n|nein|no)  INSTALL_OOTB=false; break ;;
                *) echo -e "${STR_GUI_ERR_INVALID}" >&2 ;;
            esac
        done
        echo -e "\n${STR_GUI_ASK_GAMING}"
        local choice_gaming
        while true; do
            read -rp "$(echo -e "${STR_GUI_PROMPT_YN}")" choice_gaming
            case "${choice_gaming,,}" in
                j|ja|y|yes) INSTALL_GAMING=true; break ;;
                n|nein|no)  INSTALL_GAMING=false; break ;;
                *) echo -e "${STR_GUI_ERR_INVALID}" >&2 ;;
            esac
        done
    fi
}

xfce_detect_browser_mail_lang() {
    local sys_lang
    local lang_code

    if [[ -f /etc/locale.conf ]]; then
        sys_lang=$(source /etc/locale.conf 2>/dev/null && echo "$LANG")
    else
        sys_lang="${LANG:-de_DE.UTF-8}"
    fi

    lang_code="${sys_lang%%_*}"
    if [[ -n "$lang_code" ]]; then
        for pkg in "firefox-i18n-${lang_code}" "thunderbird-i18n-${lang_code}"; do
            if pacman -Sp "$pkg" >/dev/null 2>&1; then
                echo -e "  -> ${STR_GUI_LOG_LANG_PKG_FOUND}: ${pkg}"
                XFCE_OOTB_PKGS+=("$pkg")
            fi
        done
    fi
}

xfce_detect_hardware() {
    echo -e "${STR_GUI_LOG_XFCE_HW_DETECT}"
    
    local virt_type
    virt_type=$(systemd-detect-virt 2>/dev/null || echo "none")
    if [[ "$virt_type" != "none" ]]; then
        echo -e "${STR_GUI_LOG_VM_DETECTED}"
        XFCE_PKGS+=("qemu-guest-agent" "spice-vdagent")
        [[ "$virt_type" == "qemu" || "$virt_type" == "kvm" ]] && ENABLE_QEMU_GA=true
    fi

    if lsusb 2>/dev/null | grep -iq "bluetooth" || lspci 2>/dev/null | grep -iq "bluetooth" || dmesg 2>/dev/null | grep -iq "bluetooth"; then
        echo -e "${STR_GUI_LOG_BT_DETECTED}"
        # XFCE benötigt blueman als GTK Applet
        XFCE_PKGS+=("bluez" "bluez-utils" "blueman")
        ENABLE_BLUETOOTH=true
    fi
    
    echo -e "${STR_GUI_LOG_AUDIO}"
    XFCE_PKGS+=("${AUDIO_PKGS[@]}")
}

xfce_install_ootb() {
    [[ "$INSTALL_OOTB" != "true" ]] && return 0
    echo -e "\n${STR_GUI_LOG_OOTB_PKGS}"
    xfce_detect_browser_mail_lang
    pacman -S --needed --noconfirm "${XFCE_OOTB_PKGS[@]}" || true
}

xfce_install_gaming() {
    [[ "$INSTALL_GAMING" != "true" ]] && return 0
    echo -e "\n${STR_GUI_LOG_GAMING_SETUP}"

    if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
        echo -e "  -> ${STR_GUI_LOG_GAMING_MULTILIB}"
        sed -i '/^#\[multilib\]/{s/^#//;n;s/^#//}' /etc/pacman.conf
        pacman -Sy >/dev/null 2>&1 || true
    fi

    local gpu_pkgs=()
    if lspci 2>/dev/null | grep -iq "VGA.*NVIDIA"; then
        echo -e "  -> ${STR_GUI_LOG_GAMING_NVIDIA}"
        gpu_pkgs+=("lib32-nvidia-utils")
    elif lspci 2>/dev/null | grep -iq "VGA.*AMD"; then
        echo -e "  -> ${STR_GUI_LOG_GAMING_AMD}"
        gpu_pkgs+=("lib32-mesa" "lib32-vulkan-radeon")
    elif lspci 2>/dev/null | grep -iq "VGA.*Intel"; then
        echo -e "  -> ${STR_GUI_LOG_GAMING_INTEL}"
        gpu_pkgs+=("lib32-mesa" "lib32-vulkan-intel")
    fi

    pacman -S --needed --noconfirm "${GAMING_PKGS[@]}" "${gpu_pkgs[@]}" || true
}

xfce_configure_firefox() {
    [[ "$INSTALL_OOTB" != "true" ]] && return 0
    echo -e "\n${STR_GUI_LOG_FF_POLICY}"
    source "$(dirname "${BASH_SOURCE[0]}")/02_gui_templates.sh"
    mkdir -p /etc/firefox/policies
    echo "$TPL_FF_POLICIES" > /etc/firefox/policies/policies.json
}

# XFCE ist primär ein X11 Desktop. Wayland Variablen werden hier bewusst übersprungen!
xfce_configure_wayland() {
    return 0
}

xfce_configure_keyboard() {
    if [[ -f /etc/vconsole.conf ]]; then
        local sys_keymap
        sys_keymap=$(grep "^KEYMAP=" /etc/vconsole.conf | cut -d'=' -f2)
        if [[ -n "$sys_keymap" ]]; then
            local x11_map
            x11_map="${sys_keymap%%-*}"
            echo -e "\n${STR_GUI_LOG_KEYMAP} (vconsole: ${sys_keymap} -> x11: ${x11_map})"
            localectl set-x11-keymap "$x11_map" 2>/dev/null || true
        fi
    fi
}

xfce_verify_packages() {
    echo -e "\n${STR_GUI_LOG_VERIFY_PKGS}"
    pacman -Sy >/dev/null 2>&1 || true

    local missing
    if ! missing=$(pacman -Sp --noconfirm "${XFCE_PKGS[@]}" 2>&1 >/dev/null); then
        echo -e "${STR_GUI_ERR_MISSING_PKGS}\n${missing}" >&2
        exit 1
    fi
}

xfce_install_packages() {
    echo -e "\n${STR_GUI_LOG_XFCE_PKGS}"
    if ! pacman -S --needed --noconfirm "${XFCE_PKGS[@]}"; then
        echo -e "${STR_GUI_ERR_PACMAN}" >&2
        exit 1
    fi
}

xfce_enable_services() {
    echo -e "\n${STR_GUI_LOG_XFCE_ENABLE_SRV}"
    systemctl enable lightdm.service
    systemctl enable power-profiles-daemon.service 2>/dev/null || true
    [[ "$ENABLE_BLUETOOTH" == true ]] && systemctl enable bluetooth.service
    [[ "$ENABLE_QEMU_GA" == true ]] && systemctl enable qemu-guest-agent.service
    if [[ "$INSTALL_OOTB" == true ]]; then
        systemctl enable cups.service 2>/dev/null || true
        systemctl enable ufw.service 2>/dev/null || true
    fi
}

xfce_cleanup() {
    echo -e "\n${STR_GUI_LOG_CLEANUP}"
    pacman -Scc --noconfirm >/dev/null 2>&1 || true
}

run_xfce_setup() {
    echo -e "\n${STR_GUI_XFCE_PHASE}\n"
    xfce_ask_features
    xfce_detect_hardware
    xfce_verify_packages
    xfce_install_packages
    xfce_install_ootb
    xfce_install_gaming
    xfce_configure_firefox
    xfce_configure_wayland
    xfce_configure_keyboard
    xfce_enable_services
    xfce_cleanup
    echo -e "\n${STR_GUI_OK_XFCE}"
    
    if command -v dialog >/dev/null 2>&1; then
        dialog --title "$STR_DLG_SUCCESS_TITLE" --msgbox "$STR_DLG_SUCCESS_XFCE" 10 60
    fi
}

xfce_ask_deep_clean() {
    if command -v dialog >/dev/null 2>&1; then
        if dialog --title "$STR_DLG_UNINSTALL_TITLE" --yes-label "Ja" --no-label "Nein" --yesno "$STR_DLG_ASK_DEEP_CLEAN" 10 75; then
            PURGE_CONFIGS=true
        else
            PURGE_CONFIGS=false
        fi
    else
        echo -e "\n${STR_GUI_ASK_DEEP_CLEAN}"
        local choice
        while true; do
            read -rp "$(echo -e "${STR_GUI_PROMPT_YN}")" choice
            case "${choice,,}" in
                j|ja|y|yes) PURGE_CONFIGS=true; break ;;
                n|nein|no)  PURGE_CONFIGS=false; break ;;
                *) echo -e "${STR_GUI_ERR_INVALID}" >&2 ;;
            esac
        done
    fi
}

xfce_disable_services() {
    echo -e "\n${STR_GUI_LOG_XFCE_DISABLE_SRV}"
    systemctl disable lightdm.service 2>/dev/null || true
    systemctl stop lightdm.service 2>/dev/null || true
}

xfce_remove_packages() {
    echo -e "\n${STR_GUI_LOG_XFCE_RM_PKGS}"
    local installed_pkgs=()
    for pkg in "${XFCE_PKGS[@]}"; do
        local pkg_list
        if pacman -Sgq "$pkg" >/dev/null 2>&1; then
            pkg_list=$(pacman -Sgq "$pkg")
        else
            pkg_list="$pkg"
        fi
        for p in $pkg_list; do
            if pacman -Qq "$p" >/dev/null 2>&1; then
                installed_pkgs+=("$p")
            fi
        done
    done

    if [[ ${#installed_pkgs[@]} -gt 0 ]]; then
        installed_pkgs=($(printf "%s\n" "${installed_pkgs[@]}" | sort -u))
        pacman -D --asdeps "${installed_pkgs[@]}" >/dev/null 2>&1 || true

        local leaves_to_remove=()
        local orphans
        orphans=$(pacman -Qdtq 2>/dev/null || true)
        if [[ -n "$orphans" ]]; then
            for p in "${installed_pkgs[@]}"; do
                if echo "$orphans" | grep -q "^${p}$"; then
                    leaves_to_remove+=("$p")
                fi
            done
        fi

        if [[ ${#leaves_to_remove[@]} -gt 0 ]]; then
            pacman -Rs --noconfirm "${leaves_to_remove[@]}" >/dev/null 2>&1 || true
        fi
    fi
}

xfce_purge_configs() {
    [[ "$PURGE_CONFIGS" != "true" ]] && return 0
    echo -e "\n${STR_GUI_LOG_DEEP_CLEAN}"
    local target_user="${SUDO_USER:-$USER}"
    local target_home
    target_home=$(getent passwd "$target_user" | cut -d: -f6)

    if [[ -d "$target_home" ]]; then
        rm -rf "${target_home}/.config/xfce4" 2>/dev/null || true
        find "${target_home}/.cache" -maxdepth 1 -name "sessions" -exec rm -rf {} + 2>/dev/null || true
    fi
}

remove_xfce_setup() {
    echo -e "\n${STR_GUI_XFCE_RM_PHASE}\n"
    
    if [[ "${XDG_CURRENT_DESKTOP,,}" == *"xfce"* ]]; then
        echo -e "${STR_GUI_ERR_GUI_RUNNING}" >&2
        return 1
    fi
    
    xfce_ask_deep_clean
    xfce_disable_services
    xfce_remove_packages
    xfce_purge_configs
    echo -e "\n${STR_GUI_OK_RM_XFCE}"
}