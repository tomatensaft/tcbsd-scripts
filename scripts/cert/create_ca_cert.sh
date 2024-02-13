#!/bin/sh
#SPDX-License-Identifier: MIT

#Short Info

#set -x

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
print_header 'create ce certificate'

#Check number of args
check_args $# 1

#Parameter/Arguments
option=$1
config_file=${2:-"./ca_cert.conf"}


#Main Functions
main() {

    #Check Inputargs
    case $option in
            --test)
                log -info "test Command for debugging $0"
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

    #check arguments
    check_args $# 1

    #create folder folder
    log -info "create folder"
    mkdir -p $1
    #chmod -R 777 $1
    cd $1

    #Init PKI
    log -info "init pki"
    easy-rsa init-pki
    chmod -R 777 $1

    #Cretae vars file
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

    #Buidl CA Server & Client
    log -info "create certificates"
    easy-rsa build-ca #nopass - without passwd

    #Server certificate
    easy-rsa build-server-full $2 nopass #attention nopass

    #Client certificate
    easy-rsa build-client-full $3 nopass #attention nopass

    #generate diffihellmann
    easy-rsa gen-dh

    #generaute revocatipn certificate
    easy-rsa gen-crl

    #Access for all users - if wanted
    chmod -R 777 $1
}

#Delete Certificates
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

    #Check easy-rsa software
    if pkg info easy-rsa | grep easy-rsa; then
        log -info "easy-rsa software found"
    else
        pkg install -y easy-rsa 
    fi

    #Check easy-rsa software    
    if pkg info openssl | grep openssl; then
        log -info "opsnssl software found"
    else
        pkg install -y openssl
    fi

}

#Call main Function manually - if not need uncomment
main "$@"; exit