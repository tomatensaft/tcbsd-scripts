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
print_header 'smtp sendmail with ssmtp'

#Check number of args
check_args $# 1

#Parameter/Arguments
option=$1
config_file=${2:-"./conf/setup_mail_ssmtp.conf"}


#Main Functions
main() {

    #Check Inputargs
    case ${option} in
            --test)
                log -info "test command for debugging $0"
                ;;

            --setup)
                load_config ${config_file}
                log -info "init setup ${setup_name} from configfile"
                check_requirements
                set_rc_sysctl_local
                write_config
                ;;

            --testmail)
                log -info "send testmail - to address"
                send_mail
                ;;

            --help | --info | *)
                usage   "\-\-test:                         test command" \
                        "\-\-setup  [configfile]:          setup ssmtp client" \
                        "\-\-testmail [address]:           testmail" \
                        "\-\-help:                         help"
                ;;
    esac
}

#Set rc.conf parameter - on local system
set_rc_sysctl_local() {

    log -info "set local rc.conf and sysctl.conf"

    #write rc.conf
    sysrc -f /etc/rc.conf sendmail_enable=NO
    sysrc -f /etc/rc.conf sendmail_submit_enable=NO
    sysrc -f /etc/rc.conf sendmail_outbound_enable=NO
    sysrc -f /etc/rc.conf sendmail_msp_queue_enable=NO

}

#write configuration
write_config() {

#write mailer.conf configuration   
log -info "write ssmtp configuration"
cat << EOF > /etc/mail/mailer.conf

sendmail        /usr/local/sbin/ssmtp
send-mail       /usr/local/sbin/ssmtp
mailq           /usr/local/sbin/ssmtp
newaliases      /usr/local/sbin/ssmtp
hoststat        /usr/local/sbin/ssmtp
purgestat       /usr/local/sbin/ssmtp

EOF

#write ssmtp.conf  
log -info "write mailer configuration"
cat << EOF > /usr/local/etc/ssmtp/ssmtp.conf

root=${username}
mailhub=${smtp_server}:${smtp_port}
hostname=${hostname}
UseSTARTTLS=YES
FromLineOverride=YES
realname=${realname}
AuthUser=${username}
AuthPass=${password}

EOF


#write revaliases.conf
log -info "write revaliases configuration"
cat << EOF > /usr/local/etc/ssmtp/revaliases

Administrator:${username}:${smtp_server}:${smtp_port}
root:${username}:${smtp_server}:${smtp_port}

EOF

}

#Send testmail
send_mail() {

    echo test | mail -v -s Testmail ${config_file} -FAutoMailClient

}


#Check requirements
check_requirements() {

    #Check Root
    check_root

    #Check Command
    if command -v ls >/dev/null 2>&1 ; then
        log -info "program Found"
    else
        log -info "program Not Found"
        cleanup_exit ERR
    fi 

    #Check SSmtp Client
    if pkg info ssmtp | grep ssmtp; then
        log -info "ssmtp software found"
    else

        #Switch to official repo
        switch_tcbsd_repo freebsd

        #Install Software
        pkg install -y ssmtp

        #Switch back offical repo
        switch_tcbsd_repo bhf
    fi
}

#Call main Function manually - if not need uncomment
main "$@"; exit
