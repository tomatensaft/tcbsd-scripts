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
print_header 'setup virtualbox'

#Check Root
check_root

#Check VBox device
if  ! check_vbox_device; then
    log -info "$0: virtualbox not found - skip setup."
else
    log -info "$0: virtualbox found found."

    #Dont forget to switch correct VGA Card in the VBox Settings
    log -info "install software"
    env ASSUME_ALWAYS_YES=YES pkg install virtualbox-ose-additions

    log -info "write rc.conf"
    add_or_replace_in /etc/rc.conf 'vboxguest_enable=' '"YES"'
    add_or_replace_in /etc/rc.conf 'vboxservice_enable=' '"YES"'

    # and start ...
    log -info "start guest service"
    service vboxguest start
    service vboxservice start

    #Last info
    log -info "setup finished - virtualbox guest"

fi

