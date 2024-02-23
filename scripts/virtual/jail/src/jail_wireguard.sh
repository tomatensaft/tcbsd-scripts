#!/bin/sh
#SPDX-License-Identifier: MIT

#Print Header
print_header 'setup wireguard in jail'

#Main Functions
main() {
    log -info "setup main ${jail_name}"
    install_tools
    set_config
    set_rc_remote
    start_service
    set_user
}


#Add Tools
install_tools() {

    log -info "install software in jail"
    env ASSUME_ALWAYS_YES=YES pkg -j ${jail_name} install \
	wireguard

}


#Set rc.conf parameter - remote for jail
set_rc_remote() {  

    log -info "set remote rc.conf"
    add_or_replace_in /${location_main}/${jail_name}/etc/rc.conf 'wireguard_enable=' '"YES"'
    add_or_replace_in /${location_main}/${jail_name}/etc/rc.conf 'wireguard_interfaces=' "${vpn_name}"
    add_or_replace_in /${location_main}/${jail_name}/etc/rc.conf 'gateway_enable=' '"YES"'
    add_or_replace_in /${location_main}/${jail_name}/etc/rc.conf 'pf_enable=' '"YES"'
    add_or_replace_in /${location_main}/${jail_name}/etc/rc.conf 'pflog_enable=' '"YES"'
    add_or_replace_in /${location_main}/${jail_name}/etc/rc.conf 'defaultrouter=' "${net_address_host}"
}


#Start service
start_service() {

    log -info "start service"

    #show wireguard service status
    jexec ${jail_name} service wireguard start

    #show wireguard service status
    jexec ${jail_name} service wireguard status

    #View Sockets
    jexec ${jail_name} sockstat -l | grep 8086
}


#Set config
set_config() {  
    log -info "set config"  

#Set firewall rules
log -info "write firewall"
cat << EOF > /${location_main}/${jail_name}/etc/pf.conf
#rules for wireguard client
nat pass on ${vpn_jail_internal_if} from ${vpn_range} to any -> (${vpn_jail_internal_if})
pass in on ${vpn_jail_internal_if} proto udp from any to ${vpn_jail_internal_if} port ${vpn_port}
pass in on ${vpn_name} from any to any
EOF

#rdr pass log on { igb1 } inet proto udp to (igb1) port 51820 -> 10.99.0.24

#Wireguard sec keys
log -info "generate keys - umask folder"

#umask 077 /${location_main}/${jail_name}/${wireguard_path}
jexec ${jail_name} umask 077 ${vpn_path}

#Server Keys
log -info "generate server.key"
jexec ${jail_name} sh -c "wg genkey | tee ${vpn_path}/server_private.key | wg pubkey | \
    tee ${vpn_path}/server_public.key"

#Private Keys -need for client
log -info "generate client key"
jexec ${jail_name} sh -c "wg genkey | tee ${vpn_path}/client_private.key | wg pubkey | \
    tee ${vpn_path}/client_public.key"

#create pre sharwd key
log -info "generate pre-shared key"
jexec ${jail_name} sh -c  "wg genpsk > ${vpn_path}/client_preshared.key"

#Read Keys
log -info "read keys"
private_server_key="$(jexec ${jail_name} cat ${vpn_path}/server_private.key)"
private_client_key="$(jexec ${jail_name} cat ${vpn_path}/client_private.key)"
public_server_key="$(jexec ${jail_name} cat ${vpn_path}/server_public.key)"
public_client_key="$(jexec ${jail_name} cat ${vpn_path}/client_public.key)"
preshared_client_key="$(jexec ${jail_name} cat ${vpn_path}/client_preshared.key)"

#write wireguard server config
log -info "set wireguard server config"
cat << EOF > /${location_main}/${jail_name}/usr/local/etc/wireguard/${vpn_name}.conf
[Interface]
Address = ${vpn_ip} # address the server will bind to
ListenPort = ${vpn_port} # listener port
PrivateKey = ${private_server_key}
Table = off

[Peer]
AllowedIPs = 0.0.0.0/1 # insert you ips - 0.0.0.0 for any
PreSharedKey = ${preshared_client_key}
PublicKey = ${public_client_key}

EOF

#write wireguard client config
log -info "set wireguard client config"
log -info "see file /${location_main}/${jail_name}/usr/local/etc/wireguard/${vpn_name}_client.conf"
cat << EOF > /${location_main}/${jail_name}/usr/local/etc/wireguard/${vpn_name}_client.conf
[Interface]
PrivateKey = ${private_client_key}
Address = ${vpn_prefix}.2 # address the server will bind to
DNS = 8.8.8.8


[Peer]
PublicKey = ${public_server_key}
PreSharedKey = ${preshared_client_key}
AllowedIPs = 0.0.0.0/1 # insert you ips - 0.0.0.0 for any
Endpoint = insert_server_ip:51820


EOF


#write wireguard manuel routing
log -info "write wireguard manual routing /usr/local/etc/rc.d"
cat << EOF > /${location_main}/${jail_name}/usr/local/etc/rc.d/wireguard_route.sh
#!/bin/sh 
#Write wireguard manual routing for jail

sleep 5
logger "Set Wireguard routes."
route add ${vpn_prefix}.2 -interface ${vpn_name}

EOF

log -info "permission for executeable"
chmod +x /${location_main}/${jail_name}/usr/local/etc/rc.d/wireguard_route.sh

#Last info
log -info "setup finished - wireguard - please reboot"

}

set_user() {
    #log -info "create user"
}

#Call main Function manually - if not need uncomment
main "$@"; exit

#Client config
#[Interface]
#PrivateKey = your-private-client-key-here
#Address = 10.96.100.2/32
#DNS = 10.96.0.1 # optional, useful to avoid DNS leaks

#[Peer]
#PublicKey = your-public-server-key-here
#PreSharedKey = your-preshared-client-key-here
#AllowedIPs = 10.96.0.0/16 # my LAN
#Endpoint = your-external-ip-or-host:51820

#more infos
#https://vlads.me/post/create-a-wireguard-server-on-freebsd-in-15-minutes/


#Create ClientConfig - to Export
#[Interface]
#PrivateKey = your-private-client-key-here
#Address = 10.88.0.2/32 #actual config
#DNS = 8.8.8.8

#[Peer]
#PublicKey = your-public-server-key-here
#PreSharedKey = your-preshared-client-key-here
#AllowedIPs = 0.0.0.0/0 #all lans
#Endpoint = your-external-ip-or-host:51820
