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


# if not root, run as root
if (( $EUID != 0 )); then
    echo -e "[Bashbox] \033[33mYou must be root\033[0m"
    exit 1
fi

echo -e -n "[Bashbox] updating \033[33m"
date
echo -e "\033[0m"

lock_1="/var/lib/dpkg/lock"
lock_2="/var/cache/apt/archives/lock"
lock_3="/var/lib/apt/lists/lock"
lock_4="/var/lib/dpkg/lock-frontend"

function remove_lock() {
    rm -rf "$lock_1"
    rm -rf "$lock_2"
    rm -rf "$lock_3"
    ## No need to remove lock 4 as it will not be set when calling checking_lock
    ## A better way to unify remove_lock and check_lock should be possible.
}

# trap ctrl-c and call ctrl_c()
trap ctrl_c INT

function ctrl_c() {
    echo
    echo "[Bashbox] >>>>>  Trapped CTRL-C"
    remove_lock
    exit
}

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


    if [[ "$2" -ne "1" ]]; then
        touch $1
    else
        echo "[Bashbox] >>>>> No lock file option $1"
    fi
}

checking_lock "$lock_1" "0"
checking_lock "$lock_2" "0"
checking_lock "$lock_3" "0"
checking_lock "$lock_4" "1"

echo
echo
echo -e "[Bashbox] >>>>> apt - \033[33mfix-broken install\033[0m"
echo
apt -y --fix-broken install


echo
echo
echo -e "[Bashbox] >>>>> apt - \033[33mauto-remove\033[0m"
echo
apt -y auto-remove

echo
echo
echo -e "[Bashbox] >>>>> apt - \033[33mauto-clean\033[0m"
echo
apt -y auto-clean

echo
echo
echo -e "[Bashbox] >>>>> apt - \033[33mupdate\033[0m"
echo
apt update


echo
echo
echo -e "[Bashbox] >>>>> apt - \033[33mfull-upgrade\033[0m"
echo
apt full-upgrade


echo
echo
echo -e "[Bashbox] >>>>> snap - \033[33mrefresh, version\033[0m"
echo
snap refresh
snap version


echo
echo
echo -e "[Bashbox] >>>>> kernel - \033[33mCurrent kernel\033[0m"
echo
uname -r

## echo
## echo
## echo -e ">>>>> Kernel - Check new kernel"
## echo
## echo "ubuntu-mainline-kernel.sh -i to install the latest one"
## echo
## ubuntu-mainline-kernel.sh -c

echo
echo
echo -e "[Bashbox] >>>>> Ubuntu - \033[33mCurrent Ubuntu version\033[0m"
echo
lsb_release -a

echo
echo
echo -e "[Bashbox] >>>>> Ubuntu - \033[33mCheck new Ubuntu version\033[0m"
echo
do-release-upgrade -c

remove_lock
