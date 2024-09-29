#!/bin/sh
#SPDX-License-Identifier: MIT

#Print Header
print_header 'setup telegraf in jail'

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
	telegraf

}


#Set rc.conf parameter - remote for jail
set_rc_remote() {

    log -info "set remote rc.conf"
    add_or_replace_in /${location_main=}/${jail_name}/etc/rc.conf 'telegraf_enable=' '"YES"'
}


#Start service
start_service() {

    log -info "start service"
    jexec ${jail_name} service telegraf start
    jexec ${jail_name} service telegraf status
}


#Set config
set_config() {
    log -info "set config"

    #Set chdir path - for autostart in jail
    #sed -i "" "s/required_files=\"\${grafana_config}\"/&\n\\
    #grafana_chdir=\"\${grafana_homepath}\"\n/" /${location_main}/${jail_name}/usr/local/etc/rc.d/grafana

    #admin/admin - init user and passwd
}

set_user() {
    log -info "create user"
}

#Call main Function manually - if not need uncomment
main "$@"; exit

#Import Template 1138
