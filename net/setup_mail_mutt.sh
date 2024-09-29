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
