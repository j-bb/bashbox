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

COMMAND="$1.sh"
UBUNTU_DISTRIBUTION=`hostnamectl | grep Ubuntu | wc -l`

if [ "$UBUNTU_DISTRIBUTION" -eq "1" ]; then
    DISTRIBUTION="ubuntu"
else
    DISTRIBUTION="Unknown"
fi
echo -e "[Bashbox] distribution found \033[33m$DISTRIBUTION\033[0m"

if [ ! -d "./$DISTRIBUTION" ]; then
    echo -e "[Bashbox] \033[33merror\033[0m : no sub-folder for distribution $DISTRIBUTION"
    exit
fi

if [ "" = "$1" ]; then
    echo -e "[Bashbox] availlable command are : \033[33m"
    ls "./$DISTRIBUTION" | grep ".sh"
    echo -e "\033[0m"
    exit;
else
    echo -e "[Bashbox] command is \033[33m$COMMAND\033[0m"
fi

FILE="./$DISTRIBUTION/$COMMAND"

if [ -f "$FILE" ]; then
    echo -e "[Bashbox] \033[33m$FILE\033[0m exists."
    source "$FILE"
else
    echo -e "[Bashbox] command not found: \033[33m$COMMAND\033[0m"
    echo -e "[Bashbox] full path not found is \033[33m$FILE\033[0m"
    exit
fi
