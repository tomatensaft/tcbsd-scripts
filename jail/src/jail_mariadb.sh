#!/bin/sh
#SPDX-License-Identifier: MIT

#Print Header
print_header 'setup mariadb in jail'

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
	mariadb106-server

}


#Set rc.conf parameter - remote for jail
set_rc_remote() {  

    log -info "set remote rc.conf"
    add_or_replace_in /${location_main}/${jail_name}/etc/rc.conf 'mysql_enable=' '"YES"'
}


#Start service
start_service() {

    log -info "start service"
    jexec ${jail_name} service mysql-server start
    jexec ${jail_name} service mysql-server status
}


#Set config
set_config() {  
    log -info "set config"  

    #View Service
    jexec ${jail_name} sockstat -l | grep 3206
}

set_user() {
    log -info "create user"
}

#Call main Function manually - if not need uncomment
main "$@"; exit