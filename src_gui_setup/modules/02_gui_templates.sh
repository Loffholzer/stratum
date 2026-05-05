#!/usr/bin/env bash

# =========================================
# 📄 Modul: 02_gui_templates.sh
# -----------------------------------------
# Zweck: Platzhalter für zukünftige GUI-Konfigurationen
# Aufgabe: Wird später SDDM-, Wayland- und Desktop-Configs enthalten
# =========================================

# Hier kommen in der neuen Branch die Templates (z.B. SDDM-Theme) hinein.
export TPL_GUI_DUMMY="dummy"

# =========================================
# 📄 Template: Firefox Enterprise Policies
# =========================================
export TPL_FF_POLICIES='{
  "policies": {
    "DisableTelemetry": true,
    "DisableFirefoxStudies": true,
    "DisablePocket": true,
    "DisableAppUpdate": true,
    "PasswordManagerEnabled": false,
    "OfferToSaveLogins": false,
    "AutofillAddressEnabled": false,
    "AutofillCreditCardEnabled": false,
    "Preferences": {
      "dom.security.https_only_mode": true,
      "browser.contentblocking.category": "strict",
      "privacy.donottrackheader.enabled": true
    },
    "ExtensionSettings": {
      "uBlock0@raymondhill.net": {
        "installation_mode": "force_installed",
        "install_url": "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi"
      },
      "idcac-pub@guus.ninja": {
        "installation_mode": "force_installed",
        "install_url": "https://addons.mozilla.org/firefox/downloads/latest/istilldontcareaboutcookies/latest.xpi"
      }
    },
    "SearchEngines": {
      "Default": "Brave",
      "Add": [
        {
          "Name": "Brave",
          "URLTemplate": "https://search.brave.com/search?q={searchTerms}",
          "Method": "GET",
          "IconURL": "https://cdn.search.brave.com/serp/v2/_app/imgs/logo.svg",
          "Alias": "!b"
        }
      ]
    }
  }
}'

# =========================================
# 📄 Template: Wayland Environment Profile
# =========================================
export TPL_WAYLAND_ENV="# Stratum OS - Global Wayland Settings

# Erzwingt natives Wayland für Firefox (falls nicht ohnehin Default)
export MOZ_ENABLE_WAYLAND=1

# Erzwingt natives Wayland für moderne Electron-Apps (VSCode, Discord, Obsidian)
export ELECTRON_OZONE_PLATFORM_HINT=auto
"