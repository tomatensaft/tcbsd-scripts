#!/bin/sh
#SPDX-License-Identifier: MIT

#Sengmail with Mutt

#Include extenal scripts
if [ -f  ../../../lib/shared_lib.sh ]; then
    . ../../../lib/shared_lib.sh
elif [ -f  ../../lib/shared_lib.sh ]; then
    . ../../lib/shared_lib.sh
elif [ -f  ../lib/shared_lib.sh ]; then
    . ../lib/shared_lib.sh    
else
    printf "$0: shared lib not found - exit."
    exit 1
fi

#Print Header
print_header 'smtp sendmail with mutt'

#Check number of args
check_args $# 1

#Parameter/Arguments
option=$1
config_file=${2:-"./conf/setup_mail_mutt.conf"}

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
                write_config
                ;;

            --testmail)
                log -info "send testmail - with correct username"
                send_mail
                ;;

            --help | --info | *)
                usage   "\-\-test:                        test command" \
                        "\-\-setup  [configfile]          setup mutt" \
                        "\-\-testmail [address]           send testmail" \
                        "\-\-help:                        help"
                ;;
    esac
}

#Write Config / Setup
write_config() {

 log -info "write muttrc configuration"


#Check Content
if grep "imap_user" "${userfolder}.muttrc"; then
    log -info "muttrc found - not overwrite"
else
    cat << EOF > ${userfolder}/.muttrc

set ssl_starttls=yes
set ssl_force_tls=yes

set imap_user = ${username}
set imap_pass = ${token}

set from=${username}
set realname=${realname}

set folder=${mail_folder}
set spoolfile=${mail_spoolfile}
set postponed="${mail_postponed}

set header_cache = "~/.mutt/cache/headers"
set message_cachedir = "~/.mutt/cache/bodies"
set certificate_file = "~/.mutt/certificates"

set smtp_url = smtps://${username}:${token}@${smtp_server}:${smtp_port}/

set move = no
set imap_keepalive = 900
EOF
fi
}

#Send testmail
send_mail() {

    echo test | mutt -s "testing mutt email client" ${config_file}
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

    #Check Mutt Client
    if pkg info mutt | grep mutt; then
        log -info "mutt software found"
    else

        #Switch to official repo
        switch_tcbsd_repo freebsd

        #Install Software
        pkg install -y mutt

        #Switch back offical repo
        switch_tcbsd_repo bhf

    fi
}

#Call main Function manually - if not need uncomment
main "$@"; exit