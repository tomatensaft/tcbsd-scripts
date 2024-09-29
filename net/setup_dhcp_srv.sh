#!/bin/sh
#SPDX-License-Identifier: MIT

#set -x

# set absolute path of root app for global use - relative path from this point
# ${PWD%/*} -> one folder up / ${PWD%/*/*} -> two folders up
# adjust script application path/folder
# configuration file will be the same main name as the shell script - but only with .conf extension

# option
option=${1}

# script parameter
root_path="${PWD%/*}/tomatoe-lib/" # "${PWD%/*}/tomatoe-lib/"
main_lib="${root_path}/main_lib.sh"
app_name="${0##*/}"
app_fullname="${PWD}/${app_name}"
#conf_default="$(echo "$app_fullname" | sed 's/.\{2\}$/conf/')"
conf_default="${PWD%/*}/tomatoe_lib.conf"
conf_custom=${2:-"none"}


# header of parameter
printf "\nparameters load - $(date +%Y-%m-%d-%H-%M-%S)\n"
printf "########################################\n\n"

# load config file for default parameters
if [ -f  ${conf_default} ]; then
   printf "$0: include default parameters from ${conf_default}\n"
   . ${conf_default}
else
   printf "$0: config lib default parameters not found - exit\n"
   exit 1
fi

# load config file for custom parameters
if [ ${conf_custom} != "none" ]; then
   if [ -f  ${conf_custom} ]; then
      printf "$0: include custom parameters from ${conf_custom}\n"
      . ${conf_custom}
   else
      printf "$0: config lib custom parameters not found - exit\n"
      exit 1
   fi
else
   printf "$0: no custom file in arguments - not used\n"
fi

# test include external libs from main submodule
if [ -f  ${main_lib} ]; then
   . ${main_lib}
else
   printf "$0: main libs not found - exit.\n"
   exit 1
fi

# print main parameters
print_main_parameters

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
