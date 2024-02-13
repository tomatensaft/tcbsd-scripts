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
print_header 'setup NFS server'

#Print usage information
usage   "$0 [nfs folder]:    optional parameter" 

#Optional Parameter
nfs_folder=${1:-"/usr/home/Administrator"}

#Check Root
check_root

#set rc.conf services
log -info "write rc.conf parameter"
add_or_replace_in /etc/rc.conf 'nfs_server_enable' '"YES"'
add_or_replace_in /etc/rc.conf 'nfsv4_server_enable' '"YES"'
add_or_replace_in /etc/rc.conf 'nfsuserd_enable=' '"YES"'

#set port
add_or_replace_in /etc/rc.conf 'mountd_flags=' '"-p 831"'

#set firewall
log -info "write pf.conf parameter"
add_or_replace_in /etc/pf.conf "pass in quick proto tcp to port 111" ""
add_or_replace_in /etc/pf.conf "pass in quick proto tcp to port 831" ""
add_or_replace_in /etc/pf.conf "pass in quick proto tcp to port 2049" ""

#Export Home directory
log -info "write exports"
if [ -f "/etc/resolv.conf" ]; then
    log -info "resolv.conf found"
else
    touch /etc/resolf.conf           
fi

#add parameter
add_or_replace_in /etc/exports "V4: /" ""
add_or_replace_in /etc/exports ${nfs_folder}

#Reload
/etc/rc.d/mountd onereload

#Mount nfs share - client side
#mount -t nfs <nfs-server-ip>:/usr/home/Administrator /mnt

#Show mountes
#showmount -e

#Last info
log -info "setup finished - nfs server"