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

#Print Header
print_header 'setup workstation'

#Username Parameter
username=${1:-$(users)} #whoami

#console tools
../setup/setup_console.sh --install_tools_tcbsd ${username}
../setup/setup_console.sh --install_tools_freebsd ${username}

#Set doas without password
../setup/setup_console.sh --doas_pwd ${username}

#xorg
../setup/setup_xorg.sh --install_kde ${username}

#virtualbox - if detected
../vbox/setup_vbox_guest.sh