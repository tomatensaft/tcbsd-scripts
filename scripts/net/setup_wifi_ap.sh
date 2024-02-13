#!/bin/sh
#SPDX-License-Identifier: MIT

#Create Wifi Access Point

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
print_header 'setup wifi AP'

#Print usage information
usage   "$0 [interface] [ssid] [psk]:    mandatory parameter" 

#Check number of args
check_args $# 3

#Check Root
check_root

#Parameter
interface=${1:-wlan0}
ssid_name=${2:-myssid}
psk=${3:-mypsk}


#Check Root
check_root

#Check DHCP Daemon
if pkg info hostapd | grep hostapd; then
    log -info "package hostapd Found"
else
    pkg install -y hostapd 
fi

#Write rc.conf parameter
log -info "write rc.conf parameter"
add_or_replace_in /etc/rc.conf 'hostapd_enable=' '"YES"'
add_or_replace_in /etc/rc.conf 'wlans_rtwn0=' "\"${interface}"\"
add_or_replace_in /etc/rc.conf "create_args_${interface}=" "\"wlanmode hostap ssid ${ssid_name} authmode WPA2\""
add_or_replace_in /etc/rc.conf "ifconfig_${interface}=" '"inet 192.168.0.1 netmask 255.255.255.0 country DE"'


#Write hostapd conf
log -info "write hostapd.conf"
if grep "hostap custom config" "/etc/hostapd.conf"; then
    log -info "wlan config found rules found"
else
    cat << EOF > /etc/hostapd.conf
#hostap custom config
interface=${interface}
debug=1
ctrl_interface=/var/run/hostapd
ctrl_interface_group=wheel
ssid=${ssid_name}
wpa=2
wpa_passphrase=${psk}    #password for wlan network
wpa_key_mgmt=WPA-PSK
wpa_pairwise=CCMP
channel=6    #Channel for the desired radio band (default: 0 stands for ACS, automatic Channel Selection)
hw_mode=g    #Operation mode, in this case g=IEEE802.11g (2.4 GHz)
country_code=DE #used to set the right regulatory domain for your country
ieee80211d=1    #advertises the country_code an the set of allowed channels and transmit power levels based on the regulatory limits (default=0)
EOF
fi

#Start AP Service
log -info "start hostapd"
service hostapd forcestart