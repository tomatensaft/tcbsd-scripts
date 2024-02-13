#!/bin/sh
#SPDX-License-Identifier: MIT

#Print Header
print_header 'setup influxdb in jail'

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
	influxdb

}


#Set rc.conf parameter - remote for jail
set_rc_remote() {  

    log -info "set remote rc.conf"
    add_or_replace_in /${location_main}/${jail_name}/etc/rc.conf 'influxd_enable=' '"YES"'
}


#Start service
start_service() {

    log -info "start service"
    jexec ${jail_name} service influxd start
    jexec ${jail_name} service influxd status

    #View Service
    jexec ${jail_name} sockstat -l | grep 8086

    #Create Template Database
    log -info "create database for influx db"
    jexec ${jail_name} influx --execute "DROP DATABASE $database_name"
    jexec ${jail_name} influx --execute "CREATE DATABASE $database_name"
    jexec ${jail_name} influx --execute 'CREATE RETENTION POLICY "a_year" ON "'$database_name'" DURATION 52w REPLICATION 1'
    jexec ${jail_name} influx --execute "SHOW DATABASES"
    jexec ${jail_name} influx --execute "CREATE USER $database_user WITH PASSWORD '$database_pwd'"
    jexec ${jail_name} influx --execute "GRANT ALL ON $database_name TO $database_user"
    jexec ${jail_name} influx --execute "SHOW USERS"

}


#Set config
set_config() {  
    log -info "set config"  


        #Adjust infuxd config file
        sed -i "" "s/^\[http\]/&\n\\
        #custom configuration\\
        enabled=true\n\\
        bind-address=\":8086\"\n/" /${location_main}/${jail_name}/usr/local/etc/influxd.conf


#sed -i "" "s/^\[http\]/&\n#custom configurationenabled=true\nbind-address=:8086\n/"

   
    #Last info
    log -info "config finished - influxdb"


}

set_user() {
    log -info "create user"
}

#Call main Function manually - if not need uncomment
main "$@"; exit