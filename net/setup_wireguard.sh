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
print_header 'setup wireguard at hostmachine'

#Check Root
check_root

#Parameter 
config_file=${1:-"../conf/setup_wireguard_local.conf"}

#Load config
load_config ${config_file}
log -info "init setup ${setup_name} from configfile"

#Check DHCP Daemon
if pkg info wireguard | grep wireguard; then
    log -info "package wireguard Found"
else
    pkg install -y wireguard 
fi

#Write rc.conf parameter
log -info "set remote rc.conf"
sysrc -f /etc/rc.conf wireguard_enable="YES"
sysrc -f /etc/rc.conf wireguard_interfaces="${vpn_name}"
sysrc -f /etc/rc.conf gateway_enable="YES"
sysrc -f /etc/rc.conf pf_enable="YES"
sysrc -f /etc/rc.conf pflog_enable="YES"
#sysrc -f /etc/rc.conf defaultrouter="${net_address_host}" #optional for hostmachine


log -info "set pf config"  

#Insert firewall rules
log -info "write firewall"
sed -i "" "s|scrub in all|&\n\\
#allow dynamic virtual if configuration\\
nat pass on ${vpn_internal_if} from ${vpn_range} to any -> (${vpn_internal_if})\\
rdr-anchor "\"virtual\/*\"" \n|" /etc/pf.conf

#Apped firewall rules
cat << EOF >> /etc/pf.conf

pass in on ${vpn_internal_if} proto udp from any to ${vpn_internal_if} port ${vpn_port}
pass in on ${vpn_name} from any to any

EOF

#Wireguard sec keys
log -info "generate keys - umask folder"

#umask path
umask 077 ${vpn_path}

#Server Keys
log -info "generate server.key"
wg genkey | tee ${vpn_path}/server_private.key | wg pubkey | tee ${vpn_path}/server_public.key

#Private Keys -need for client
log -info "generate client key"
wg genkey | tee ${vpn_path}/client_private.key | wg pubkey | tee ${vpn_path}/client_public.key

#create pre sharwd key
log -info "generate pre-shared key"
wg genpsk > ${vpn_path}/client_preshared.key

#Read Keys
log -info "read keys"
private_server_key="$(cat ${vpn_path}/server_private.key)"
private_client_key="$(cat ${vpn_path}/client_private.key)"
public_server_key="$(cat ${vpn_path}/server_public.key)"
public_client_key="$(cat ${vpn_path}/client_public.key)"
preshared_client_key="$(cat ${vpn_path}/client_preshared.key)"

#write wireguard server config
log -info "set wireguard server config"
cat << EOF > ${vpn_path}/${vpn_name}.conf
[Interface]
Address = ${vpn_ip} # address the server will bind to
ListenPort = ${vpn_port} # listener port
PrivateKey = ${private_server_key}

[Peer]
AllowedIPs = 0.0.0.0/0 # insert you ips - 0.0.0.0 for any
PreSharedKey = ${preshared_client_key}
PublicKey = ${public_client_key}

EOF


#write wireguard client config
log -info "set wireguard client config"
log -info "see file /usr/local/etc/wireguard/${vpn_name}_client.conf"
cat << EOF > ${vpn_path}/${vpn_name}_client.conf
[Interface]
PrivateKey = ${private_client_key}
Address = ${vpn_prefix}.2 # address the server will bind to
DNS = 8.8.8.8


[Peer]
PublicKey = ${public_server_key}
PreSharedKey = ${preshared_client_key}
AllowedIPs = 0.0.0.0/0 # insert you ips - 0.0.0.0 for any
Endpoint = insert_server_ip:51820


EOF

#Last info
log -info "setup finished - wireguard - please reboot"
