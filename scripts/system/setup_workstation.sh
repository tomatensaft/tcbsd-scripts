#!/bin/sh
#SPDX-License-Identifier: MIT

#Setup System monitoring

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