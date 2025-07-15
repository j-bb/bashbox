#!/bin/bash

# if not root, run as root
if (( $EUID != 0 )); then
    echo "You must be root"
    exit 1
fi

echo -n "Bashbox ubuntu "
echo -n -e "\033[33mtest\033[0m "
date
