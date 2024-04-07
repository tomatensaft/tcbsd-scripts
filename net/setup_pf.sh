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
print_header 'setup pf firewall'


#Check Root
check_root

#set rc.conf services
log -info "write rc.conf"
sysrc -f /etc/rc.conf pf_enable="YES"
sysrc -f /etc/rc.conf pf_rules="/etc/pf.conf"
sysrc -f /etc/rc.conf pflog_enable="YES"
sysrc -f /etc/rc.conf pflog_logfile="/var/log/pflog"