#!/bin/sh
#SPDX-License-Identifier: MIT

#set -x

# set absolute path of root app for global use - relative path from this point
# ${PWD%/*} -> one folder up / ${PWD%/*/*} -> two folders up 
SCRIPT_ROOT_PATH="${PWD%/*}/posix-lib-utils"

# test include external libs from tcbsd submodule
if [ -f  ${SCRIPT_ROOT_PATH}/tcbsd_lib.sh ]; then
    . ${SCRIPT_ROOT_PATH}/tcbsd_lib.sh
else
    printf "$0: tcbsd external libs not found - exit.\n"
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