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
print_header 'setup DHCP server'

#Print usage information
#usage   "$0 [interface]:    optional parameter" 

#Optional Parameter
interface=${1:-wlan0}

#Check Root
check_root

#Check DHCP Daemon
if pkg info dhcpd | grep dhcp; then
    log -info "dhcpd Found"
else
    pkg install -y dhcpd 
fi

#Write DHCPD conf
log -info "write dhcp.conf"
if grep "dhcp_conf custom setup" "/usr/local/etc/dhcpd.conf"; then
    log -info "dhcpd rules found"
else
    log -info "dhcpd rules not found - creating"
    cat << EOF > /usr/local/etc/dhcpd.conf
#dhcp_conf custom setup
subnet 192.168.0.0 netmask 255.255.255.0 {
range 192.168.0.10 192.168.0.20;
default-lease-time 600;
max-lease-time 72400;
option subnet-mask 255.255.255.0;
}
EOF
fi    

#Write rc.conf parameter
log -info "write loader.conf and rc.conf parameter"

sysrc -f /etc/rc.conf dhcpd_enable="YES"
sysrc -f /etc/rc.conf dhcpd_flags=="${interface}"
sysrc -f /etc/rc.conf dhcpd_ifaces="${interface}"


#Start service
log -info "start dhcp server"
service dhcpd start

#Last info
log -info "setup finished - leases find in /var/db/dhcpd.lease"