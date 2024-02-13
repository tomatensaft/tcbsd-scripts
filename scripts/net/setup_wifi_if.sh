#!/bin/sh
#SPDX-License-Identifier: MIT

#Create realtek wlan 

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



