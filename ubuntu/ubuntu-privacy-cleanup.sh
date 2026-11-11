#!/usr/bin/env bash

## MIT License
##
## Copyright (c) 2024 Jean-Baptiste Briaud.
##
## Permission is hereby granted, free of charge, to any person obtaining a copy
## of this software and associated documentation files (the "Software"), to deal
## in the Software without restriction, including without limitation the rights
## to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
## copies of the Software, and to permit persons to whom the Software is
## furnished to do so, subject to the following conditions:
##
## The above copyright notice and this permission notice shall be included in all
## copies or substantial portions of the Software.
##
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
## IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
## AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
## OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
## SOFTWARE.

set -Eeuo pipefail

readonly ESM_HOOK="/etc/apt/apt.conf.d/20apt-esm-hook.conf"
readonly ESM_HOOK_DISABLED="${ESM_HOOK}.disabled"

# Colors
YELLOW='\033[33m'
GREEN='\033[32m'
RED='\033[31m'
RESET='\033[0m'

log() {
    echo -e "[Bashbox] $*"
}

error_exit() {
    echo -e "\n[Bashbox] ${RED}ERROR: $1${RESET}"
    exit 1
}

ctrl_c() {
    echo
    echo "[Bashbox] >>>>> Trapped CTRL-C"
    exit 130
}

trap ctrl_c INT

# ---------------------------------------------------------------------------
# Header and execution plan
# ---------------------------------------------------------------------------

show_header() {
    echo -e -n "[Bashbox] privacy cleanup \033[33m"
    date
    echo -e "${RESET}"
}

show_plan() {
    cat <<'EOF'

This script will perform the following operations:

1. Ubuntu MOTD news
   Disable the motd-news.timer systemd service.

2. Ubuntu Pro notifications
   Disable APT news notifications through Ubuntu Pro configuration.

3. Ubuntu Pro ESM cache
   Disable the esm-cache.service systemd service.

4. Ubuntu Pro APT hook
   Disable the ESM APT hook using dpkg-divert.
   The original file will be preserved with a .disabled suffix.

5. GeoClue
   Disable, stop and mask the GeoClue systemd service.
   The GeoClue package will NOT be removed.

6. APT repositories
   Refresh the local APT package index using apt update.

WHAT WILL NOT BE DONE:

- No packages will be removed.
- No packages will be installed.
- No APT repositories will be deleted.
- No system packages will be upgraded.
- No user data or personal files will be modified.
- No firewall or network configuration will be changed.

PERSISTENCE:

Configuration changes made by this script are stored in the system
configuration and are intended to survive system reboots.

They are not temporary session changes.

Future package updates or administrative changes may alter some settings.
The corresponding services and configuration should then be checked again.

To reverse these changes, the corresponding services and configuration
settings must be manually restored.

EOF
}

confirm_execution() {
    echo "Do you want to proceed with these changes?"
    echo
    read -r -p 'Type "Yes" to continue: ' answer

    if [[ "$answer" != "Yes" ]]; then
        echo
        log "Operation cancelled. No changes have been made."
        exit 0
    fi
}

# ---------------------------------------------------------------------------
# Privileges
# ---------------------------------------------------------------------------

require_root() {
    if [[ "$EUID" -ne 0 ]]; then
        error_exit "Please run this script with sudo."
    fi
}

# ---------------------------------------------------------------------------
# Systemd services
# ---------------------------------------------------------------------------

disable_service() {
    local service="$1"
    local unit_files
    local enabled_state
    local active_state

    log ">>>>> ${YELLOW}Checking service: ${service}${RESET}"

    unit_files="$(systemctl list-unit-files "$service" --no-legend 2>/dev/null || true)"

    if ! grep -q "^${service}[[:space:]]" <<< "$unit_files"; then
        log "${YELLOW}${service}: not installed, skipped.${RESET}"
        return 0
    fi

    enabled_state="$(systemctl is-enabled "$service" 2>/dev/null || true)"
    active_state="$(systemctl is-active "$service" 2>/dev/null || true)"

    # Already masked and stopped
    if [[ "$enabled_state" == "masked" && "$active_state" != "active" ]]; then
        log "${GREEN}${service}: no need, already masked and stopped.${RESET}"
        return 0
    fi

    # Already masked but still running
    if [[ "$enabled_state" == "masked" && "$active_state" == "active" ]]; then
        systemctl stop "$service"
        log "${GREEN}${service}: already masked, service stopped.${RESET}"
        return 0
    fi

    # Already disabled and stopped
    if [[ "$enabled_state" == "disabled" && "$active_state" != "active" ]]; then
        systemctl mask "$service"
        log "${GREEN}${service}: already disabled and stopped, now masked.${RESET}"
        return 0
    fi

    # Disable and stop the service
    systemctl disable --now "$service" 2>/dev/null || true
    systemctl mask "$service"

    log "${GREEN}${service}: disabled, stopped and masked.${RESET}"
}

# ---------------------------------------------------------------------------
# Ubuntu Pro APT news notifications
# ---------------------------------------------------------------------------

disable_ubuntu_pro_news() {
    local current_config

    log ">>>>> ${YELLOW}Checking Ubuntu Pro APT news notifications${RESET}"

    if ! command -v pro >/dev/null 2>&1; then
        log "${YELLOW}Ubuntu Pro command not found, skipped.${RESET}"
        return 0
    fi

    current_config="$(pro config show 2>/dev/null || true)"

    if grep -Eiq 'apt_news[[:space:]]*[:=][[:space:]]*false([[:space:]]|$)' \
        <<< "$current_config"; then
        log "${GREEN}No need, Ubuntu Pro APT news already disabled.${RESET}"
        return 0
    fi

    if pro config set apt_news=false; then
        log "${GREEN}Ubuntu Pro configuration updated: apt_news=false.${RESET}"
    else
        error_exit "Unable to disable Ubuntu Pro APT news notifications."
    fi
}

# ---------------------------------------------------------------------------
# Ubuntu Pro ESM APT hook
# ---------------------------------------------------------------------------

disable_esm_hook() {
    local diversion_list

    log ">>>>> ${YELLOW}Checking the ESM APT hook${RESET}"

    diversion_list="$(dpkg-divert --list "$ESM_HOOK" 2>/dev/null || true)"

    if grep -q "$ESM_HOOK" <<< "$diversion_list"; then
        log "${GREEN}No need, ESM APT hook already diverted.${RESET}"
        return 0
    fi

    if [[ -f "$ESM_HOOK" ]]; then
        dpkg-divert \
            --add \
            --rename \
            --divert "$ESM_HOOK_DISABLED" \
            "$ESM_HOOK"

        log "${GREEN}ESM APT hook disabled.${RESET}"
    else
        log "${GREEN}No need, ESM APT hook already absent.${RESET}"
    fi
}

# ---------------------------------------------------------------------------
# GeoClue
# ---------------------------------------------------------------------------

disable_geoclue() {
    log ">>>>> ${YELLOW}Checking GeoClue${RESET}"

    disable_service geoclue.service

    log "GeoClue package has been preserved."
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

main() {
    show_header
    show_plan
    confirm_execution

    # Check root privileges only after user confirmation.
    require_root

    log ">>>>> ${YELLOW}Starting privacy cleanup${RESET}"

    disable_service motd-news.timer
    disable_ubuntu_pro_news
    disable_service esm-cache.service
    disable_esm_hook
    disable_geoclue

    log ">>>>> ${YELLOW}Refreshing APT package index${RESET}"
    apt update

    echo
    log ">>>>> ${GREEN}Privacy cleanup completed successfully.${RESET}"
    echo
}

main "$@"
