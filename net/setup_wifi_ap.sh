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
