#!/bin/sh
#SPDX-License-Identifier: MIT

#Print Header
print_header 'setup gitea server in jail'


#Main Functions
main() {
    log -info "setup gitea main"
    install_tools
    set__config
    set_rc_remote
    start_service
    set_user
}


#Add Tools
install_tools() {

    log -info "install software in jail"
    env ASSUME_ALWAYS_YES=YES pkg -j ${jail_name} install \
	git \
	gitea

}


#Set rc.conf parameter - remote for jail
set_rc_remote() {  

    log -info "set remote rc.conf"
    add_or_replace_in /${location_main}/${jail_name}/etc/rc.conf 'gitea_enable=' '"YES"'
}

#Set User
set_user() {

    log -info "create user"
    
    #Mode of config file
    log -info "chmod app.ini"
    jexec -U root ${jail_name} chmod 777 /usr/local/etc/gitea/conf/app.ini
    
    #Mode fo dev/bull
    log -info "chmod /dev/null"
    jexec -U root ${jail_name} chmod 666 /dev/null

    #create gitea user
    log -info "create user"
    jexec -U git ${jail_name} gitea admin user create --username ${git_user} --password ${git_pwd} --email ${git_mail} --admin -c /usr/local/etc/gitea/conf/app.ini

    #first start
    log -info "first start - set env"
    jexec -U git ${jail_name} /usr/bin/env -i 'GITEA_WORK_DIR=/usr/local/share/gitea' 'GITEA_CUSTOM=/usr/local/etc/gitea' 'HOME=/usr/local/git' 'PATH=/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin' 'USER=git' /usr/local/sbin/gitea web


}


#Start service
start_service() {

    log -info "start service"
    jexec ${jail_name} service gitea start
    jexec ${jail_name} service gitea status
}


#Set config
set_config() {  

    log -info "set config"

    #Backup
    log -info "backup app.ini"
    jexec ${jail_name} cp /usr/local/etc/gitea/conf/app.ini /usr/local/etc/gitea/conf/app.ini.bak

    #Set Address
    log -info "set address"
    #jexec ${jail_name} sed -i .tmp "s/^HTTP_ADDR.*=.*$/HTTP_ADDR = ${net_address_jail}/g" /usr/local/etc/gitea/conf/app.ini
    jexec ${jail_name} sed -i .tmp 's/^HTTP_ADDR.*=.*$/HTTP_ADDR = 0.0.0.0/g' /usr/local/etc/gitea/conf/app.ini

    #Disable registration
    log -info "disable regisration"
    jexec ${jail_name}  sed -i .tmp 's/^DISABLE_REGISTRATION.*=.*$/DISABLE_REGISTRATION = true/g' /usr/local/etc/gitea/conf/app.ini

    #gitea generate secret - faults
    log -info "generate secrets"
    jexec ${jail_name} sed -i .tmp 's/^JWT_SECRET.*=.*$/JWT_SECRET = '`gitea generate secret JWT_SECRET`'/g' /usr/local/etc/gitea/conf/app.ini
    jexec ${jail_name} sed -i .tmp 's/^INTERNAL_TOKEN.*=.*$/INTERNAL_TOKEN = '`gitea generate secret INTERNAL_TOKEN`'/g' /usr/local/etc/gitea/conf/app.ini
    jexec ${jail_name} sed -i .tmp 's/^SECRET_KEY.*=.*$/SECRET_KEY = '`gitea generate secret SECRET_KEY`'/g' /usr/local/etc/gitea/conf/app.ini
    

    #diff backup for review
    jexec ${jail_name} diff /usr/local/etc/gitea/conf/app.ini.bak /usr/local/etc/gitea/conf/app.ini

}


#Call main Function manually - if not need uncomment
main "$@"; exit


#https://www.ccammack.com/posts/jail-gitea-in-freebsd/
#https://www.hagen-bauer.de/2020/03/gitea-freenas-jail.html

#bug
#https://bugs.freebsd.org/bugzilla/show_bug.cgi?id=238230


#dev/null
#https://unix.stackexchange.com/questions/327119/ssh-in-chrooted-jail-doesnt-work-because-of-dev-null-operation-not-supported