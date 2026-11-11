```bash
#!/bin/bash

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


set -Ee

REPO="https://github.com/j-bb/bashbox/archive/refs/heads/main.tar.gz"

# Colors
YELLOW='\033[33m'
GREEN='\033[32m'
RED='\033[31m'
RESET='\033[0m'

# Installation directory
INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Temporary directory
TMP_DIR=""

function cleanup() {
    [[ -n "$TMP_DIR" && -d "$TMP_DIR" ]] && rm -rf "$TMP_DIR"
}

function error_exit() {
    echo -e "\n[Bashbox] ${RED}ERROR: $1${RESET}"
    exit 1
}

function ctrl_c() {
    echo
    echo "[Bashbox] >>>>> Trapped CTRL-C"
    exit 130
}

trap ctrl_c INT
trap cleanup EXIT

# Header
echo -e -n "[Bashbox] updating Bashbox \033[33m"
date
echo -e "${RESET}"

# Development repository detection
if [[ -d "$INSTALL_DIR/.git" ]]; then
    echo
    echo -e "[Bashbox] >>>>> ${YELLOW}Development repository detected.${RESET}"
    echo "[Bashbox] Bashbox self-update is disabled in development mode."
    echo "[Bashbox] Use 'git pull' to update this repository."
    exit 0
fi

# Check dependencies
command -v curl >/dev/null 2>&1 || error_exit "curl not found."
command -v tar  >/dev/null 2>&1 || error_exit "tar not found."

# Download
echo
echo -e "[Bashbox] >>>>> GitHub - ${YELLOW}Downloading Bashbox${RESET}"
echo

TMP_DIR="$(mktemp -d)" || error_exit "Unable to create temporary directory."

curl -fsSL "$REPO" -o "$TMP_DIR/bashbox.tar.gz" \
    || error_exit "Download failed."

# Extract
echo
echo -e "[Bashbox] >>>>> GitHub - ${YELLOW}Extracting archive${RESET}"
echo

mkdir "$TMP_DIR/extracted"

tar -xzf "$TMP_DIR/bashbox.tar.gz" \
    --strip-components=1 \
    -C "$TMP_DIR/extracted" \
    || error_exit "Extraction failed."

# Install
echo
echo -e "[Bashbox] >>>>> Bashbox - ${YELLOW}Installing files${RESET}"
echo

cp -a "$TMP_DIR/extracted/." "$INSTALL_DIR/" \
    || error_exit "Installation failed."

# Done
echo
echo -e "[Bashbox] >>>>> Bashbox - ${GREEN}Update completed successfully.${RESET}"
echo
```
