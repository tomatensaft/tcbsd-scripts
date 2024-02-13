#!/bin/sh
#SPDX-License-Identifier: MIT

#Print Header
print_header 'setup devuan in jail'

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

    #Package
    jexec ${jail_name} bash -c "dpkg --force-depends -i /var/cache/apt/archives/*.deb"
    jexec ${jail_name} bash -c "dpkg --configure --pending"

    #optional dpkg commands
    #jexec ${jail_name} bash -c "dpkg -l | grep -v ^ii" 
    #jexec ${jail_name} bash -c "dpkg --force-all -i /path/to/package"
    
    #test apt-get
    jexec ${jail_name} bash -c "apt-get install man-d"

}


#Set rc.conf parameter - remote for jail
set_rc_remote() {  

    log -info "set remote rc.conf"

}

#Start service
start_service() {

    log -info "start service"

    #show wireguard service status
    #jexec ${jail_name} service devuan start

    #show devuan linux service status
    jexec ${jail_name} service devuan status

}


#Set config
set_config() {  
    log -info "set config"  

#    log -info "append fstab"  
#cat << EOF >> ${fstab_name}
#linprocfs   /${location_main}/${jail_name}/proc    linprocfs    rw,late    0    0
#linsysfs    /${location_main}/${jail_name}/sys    linsysfs    rw,late    0    0
#tmpfs    /${location_main}/${jail_name}/dev/shm    tmpfs    rw,late,mode=1777    0    0
#EOF


#Last info
log -info "setup finished - devuan linux - please reboot"

}

set_user() {
    log -info "create user"
}

#Call main Function manually - if not need uncomment
main "$@"; exit