#!/bin/sh
#SPDX-License-Identifier: MIT
#Not finished - Not testet

#Install Debian Bhyve Guest

#Include extenal scripts
if [ -f  ../../../lib/shared_lib.sh ]; then
    . ../../../lib/shared_lib.sh
elif [ -f  ../../lib/shared_lib.sh ]; then
    . ../../lib/shared_lib.sh
elif [ -f  ../lib/shared_lib.sh ]; then
    . ../lib/shared_lib.sh    
else
    printf "$0: shared lib not found - exit."
    exit 1
fi

#Check number of args
#check_args $# 1

#Print Header
print_header 'setup portsnap tree'

#Static Params - Adjust if needed / Init

#Checl Root Access
check_root

#Check if Ports exists

################ Portsnap Version #################

#First Time fetch and extract
portsnap fetch extract

#Update Portsnap
portsnap fetch update

################ Portsnap Version #################

#Check Git installation
check_git

#Clone Git Repo
git clone https://git.FreeBSD.org/ports.git /usr/ports

#Update Git Repo
git -C /usr/ports pull