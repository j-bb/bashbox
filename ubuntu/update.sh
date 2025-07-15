#!/bin/bash

# if not root, run as root
if (( $EUID != 0 )); then
    echo "You must be root"
    exit 1
fi

echo -n "updating "
date

lock_1="/var/lib/dpkg/lock"
lock_2="/var/cache/apt/archives/lock"
lock_3="/var/lib/apt/lists/lock"

checking_lock() {
    i=0
    tput sc
    while fuser $1 >/dev/null 2>&1 ; do
        case $(($i % 4)) in
            0 ) j="-" ;;
            1 ) j="\\" ;;
            2 ) j="|" ;;
            3 ) j="/" ;;
        esac
        tput rc
        echo -en "\r[$j] $1 Waiting for other software managers to finish..." 
        sleep 0.5
        ((i=i+1))
    done
    touch $1
}

checking_lock "$lock_1"
checking_lock "$lock_2"
checking_lock "$lock_3"

echo
echo
echo ">>>>> System - fix-broken install"
echo
apt -y --fix-broken install


echo
echo
echo ">>>>> System - auto-remove"
echo
apt -y auto-remove

echo
echo
echo ">>>>> System - auto-clean"
echo
apt -y auto-clean

echo
echo
echo ">>>>> System - update"
echo
apt update


echo
echo
echo ">>>>> System - full-upgrade"
echo
apt full-upgrade


echo
echo
echo ">>>>> Snap - refresh, version"
echo
snap refresh
snap version


echo
echo
echo ">>>>> Kernel - Actual kernel"
echo
uname -r

## echo
## echo
## echo ">>>>> Kernel - Check new kernel"
## echo
## echo "ubuntu-mainline-kernel.sh -i to install the latest one"
## echo
## ubuntu-mainline-kernel.sh -c

echo
echo
echo ">>>>> Ubuntu - Actual Ubuntu version"
echo
lsb_release -a

echo
echo
echo ">>>>> Ubuntu - Check new Ubuntu version"
echo
do-release-upgrade -c

rm -rf "$lock_1"
rm -rf "$lock_2"
rm -rf "$lock_3"
