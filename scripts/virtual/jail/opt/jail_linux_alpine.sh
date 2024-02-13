#!/bin/sh
#SPDX-License-Identifier: MIT

#Print Header
print_header 'setup alpine in jail'

#Main Functions
main() {
    log -info "setup main ${jail_name}"
    set_config
    install_tools
    set_rc_remote
    start_service
    set_user
}


#Add Tools
install_tools() {

log -info "install software in jail"

chroot ${location_main}/${jail_name} /bin/sh <<EOT
nameserver 1.1.1.1" > /etc/resolv.conf
apk add net-tools
EOT

}


#Set rc.conf parameter - remote for jail
set_rc_remote() {  

    log -info "set local rc.conf"
    sysrc -f /etc/rc.conf linux_enable=YES
}

#If linix version <> "" then install linux - otherwise use BSD
#linux_version=""
#Start service
start_service() {

    log -info "start service"

    #show wireguard service status
    #jexec ${jail_name} service devuan start

    #show wireguard service status
    #jexec ${jail_name} service devuan status

}

#https://forums.freebsd.org/threads/no-networking-in-bastille-jail.84883/

#Set config
set_config() {  
    log -info "set config"  

    log -info "append fstab"  
#cat << EOF >> ${fstab_name}
#devfs   /${location_main}/${jail_name}/dev    devfs    rw    0    0
#linprocfs   /${location_main}/${jail_name}/proc    linprocfs    rw,late    0    0
#linsysfs    /${location_main}/${jail_name}/sys    linsysfs    rw,late    0    0
#tmpfs    /${location_main}/${jail_name}/dev/shm    tmpfs    rw,late,mode=1777    0    0
#EOF


    #Mount FileSystems
    #mount -t linprocfs none /jails/${jail_name}/proc
    #mount -t linsysfs none /jails/${jail_name}/sys
    #mount -t tmpfs none /jails/${jail_name}/tmp

    #Package
    #jexec ${jail_name} bash -c "dpkg --force-depends -i /var/cache/apt/archives/*.deb"
    #jexec ${jail_name} bash -c "dpkg --configure --pending"
    #jexec ${jail_name} bash -c "dpkg -l | grep -v ^ii"
    #jexec ${jail_name} bash -c "dpkg --force-all -i /path/to/package"
    #jexec ${jail_name} bash -c "apt-get install man-d"


#Set firewall rules
#log -info "write firewall"
#cat << EOF > /${location_main}/${jail_name}/etc/pf.conf
##rule for wireguard
#nat on ${vpn_jail_internal_if} from ${vpn_range} to any -> (${vpn_jail_internal_if})
#EOF


#Last info
log -info "setup finished - alpine linux - please reboot"

}

set_user() {
    log -info "create user"
}

#Call main Function manually - if not need uncomment
main "$@"; exit