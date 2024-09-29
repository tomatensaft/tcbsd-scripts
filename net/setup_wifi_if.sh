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
print_header 'setup wlan interface'

#Print usage information
usage   "$0 [interface] [ssid] [psk]:    mandatory parameter" 

#Check number of args
check_args $# 3

#Check Root
check_root

#Optional Parameter
interface=${1:-wlan0}
ssid_name=${2:-myssid}
psk=${3:-mypsk}

#Check Root
check_root

log -info "scan pci bus"
pciscan -ls # rtwn

#Write rc.conf parameter
log -info "write rc.conf parameter"
add_or_replace_in /etc/rc.conf.conf 'wlans_rtwn0=' "\"${interface}"\"

#Create DHCP
add_or_replace_in /etc/rc.conf.conf "ifconfig_${interface}=" '"WPA DHCP country DE"'

#Create Static
#add_or_replace_in /etc/rc.conf.conf "ifconfig_${interface}=" '"WPA inet 192.168.0.100 netmask 255.255.255.0 country DE"'

#Write DHCPD conf
log -info "write wpa_supplicant.conf"
cat << EOF > /etc/wpa_supplicant.conf
network={
    ssid="${ssid_name}"    #for myssid specify the name of the network
    psk="${psk}"           #for mypsk enter password of network
}
EOF

log -info "setup interface"
ifconfig $interface up



