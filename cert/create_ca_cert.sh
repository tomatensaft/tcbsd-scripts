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

# print Header
print_header 'create ce certificate'

# check number of args
check_args $# 1

# parameter/Arguments
option=$1
config_file=${2:-".env"}


# main Functions
main() {

    # check Inputargs
    case $option in
            --test)
                log -info "test command for debugging $0"
                ;;

            --create)
                load_config ${config_file}
                log -info "create easy-rsa certificate"
                check_requirements
                create_ca_certificate $directory $servername $clientname
                ;;

            --delete)
                log -info "delete"
                delete_ca_certificates $directory
                ;;

            --help | --info | *)
                usage   "\-\-test:      test command" \
                        "\-\-create:    create certificates" \
                        "\-\-delete:    delete certificates" \
                        "\-\-help:      help" 
                ;;
    esac
}


create_ca_certificate() {

    # check arguments
    check_args $# 1

    # create folder folder
    log -info "create folder"
    mkdir -p $1
    #chmod -R 777 $1
    cd $1

    # init PKI
    log -info "init pki"
    easy-rsa init-pki
    chmod -R 777 $1

    # cretae vars file
    log -info "create file"
    cat << EOF > $1/pki/vars
set_var EASYRSA_REQ_COUNTRY     ${EASYRSA_REQ_COUNTRY}
set_var EASYRSA_REQ_PROVINCE     ${EASYRSA_REQ_PROVINCE}
set_var EASYRSA_REQ_CITY        ${EASYRSA_REQ_CITY}
set_var EASYRSA_REQ_ORG         ${EASYRSA_REQ_ORG}
set_var EASYRSA_REQ_EMAIL       ${EASYRSA_REQ_EMAIL}
set_var EASYRSA_REQ_OU          ${EASYRSA_REQ_OU}
set_var EASYRSA_KEY_SIZE	${EASYRSA_KEY_SIZE}
set_var EASYRSA_CA_EXPIRE	${EASYRSA_CA_EXPIRE}
set_var EASYRSA_CERT_EXPIRE	${EASYRSA_CERT_EXPIRE}
EOF

    # build CA server & client
    log -info "create certificates"
    easy-rsa build-ca #nopass - without passwd

    # server certificate
    easy-rsa build-server-full $2 nopass #attention nopass

    # client certificate
    easy-rsa build-client-full $3 nopass #attention nopass

    # generate diffihellmann
    easy-rsa gen-dh

    # generaute revocatipn certificate
    easy-rsa gen-crl

    # access for all users - if wanted
    chmod -R 777 $1
}

# delete Certificates
delete_ca_certificates() {

    read -t 8 -p "delete $1 ? [(y)es, (n)o]: " selectOption
    : "${selectOption:=n}"

    if [ $selectOption = "y" ] ; then
        log -info "delete $1"
        rm -r $1
        exit 0
    fi
    log -info "exit without deleting"
}

# check requirements
check_requirements() {

    # check root
    check_root

    # check command
    if command -v ls >/dev/null 2>&1 ; then
        log -info "program Found"
    else
        log -info "program Not Found"
        cleanup_exit ERR
    fi 

    # check easy-rsa software
    if pkg info easy-rsa | grep easy-rsa; then
        log -info "easy-rsa software found"
    else
        pkg install -y easy-rsa 
    fi

    # check easy-rsa software
    if pkg info openssl | grep openssl; then
        log -info "opsnssl software found"
    else
        pkg install -y openssl
    fi

}

# call main Function manually - if not need uncomment
main "$@"; exit
