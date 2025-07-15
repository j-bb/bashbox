#!/bin/bash

COMMAND="$1.sh"
UBUNTU_DISTRIBUTION=`hostnamectl | grep Ubuntu | wc -l`

if [ "$UBUNTU_DISTRIBUTION" -eq "1" ]; then
    DISTRIBUTION="ubuntu"
else
    DISTRIBUTION="Unknown"
fi
echo "Bashbox distribution found $DISTRIBUTION"

FILE="./$DISTRIBUTION/$COMMAND"
echo "Bashbox command is $FILE"

if [ -f "$FILE" ]; then
    echo "$FILE exists."
    source "$FILE"
else
    echo "Bashbox command not found: $COMMAND"
    echo "Full path not found is $FILE"
    exit
fi
