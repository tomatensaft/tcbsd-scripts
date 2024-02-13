#!/bin/sh
#SPDX-License-Identifier: MIT

#Create NFS Server

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
print_header 'setup pf firewall'


#Check Root
check_root

#set rc.conf services
log -info "write rc.conf"
sysrc -f /etc/rc.conf pf_enable="YES"
sysrc -f /etc/rc.conf pf_rules="/etc/pf.conf"
sysrc -f /etc/rc.conf pflog_enable="YES"
sysrc -f /etc/rc.conf pflog_logfile="/var/log/pflog"