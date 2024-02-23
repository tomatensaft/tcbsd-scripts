#!/bin/sh
#SPDX-License-Identifier: MIT

#Print Header
print_header 'setup mosquitto broker in jail'

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
	mosquitto

}


#Set rc.conf parameter - remote for jail
set_rc_remote() {  

    log -info "set remote rc.conf"
    add_or_replace_in /${location_main}/${jail_name}/etc/rc.conf 'mosquitto_enable=' '"YES"'
}


#Start service
start_service() {

    log -info "start service"
    jexec ${jail_name} service mosquitto start
    jexec ${jail_name} service mosquitto status
}


#Set config
set_config() {  
    log -info "set config"  


#listener replace listener 1883
#allow anonymous true
#add port 1883 8883 to firwall rule

    log -info "set remote rc.conf"
    add_or_replace_in /${location_main}/${jail_name}/etc/rc.conf 'mosquitto_enable=' '"YES"'

#create mosquitto conf
    log -info "create minimal mosquitto config"
cat << EOF > /${location_main}/${jail_name}/usr/local/etc/mosquitto/mosquitto.conf
#Mosquitto - minimalistic config file

#Standard user
user nobody

#Allow anonymous user
allow_anonymous true

#Enable extern listener
listener 1883 0.0.0.0

EOF


}

set_user() {
    log -info "create user"
}

#Call main Function manually - if not need uncomment
main "$@"; exit
