#!/bin/sh
#SPDX-License-Identifier: MIT

#set -x

# set absolute path of root app for global use - relative path from this point
# ${PWD%/*} -> one folder up / ${PWD%/*/*} -> two folders up 
SCRIPT_ROOT_PATH="${PWD%/*}/posix-lib-utils"

# test include external libs from tcbsd submodule
if [ -f  ${SCRIPT_ROOT_PATH}/tcbsd_lib.sh ]; then
    . ${SCRIPT_ROOT_PATH}/tcbsd_lib.sh
else
    printf "$0: tcbsd external libs not found - exit.\n"
    exit 1
fi

#Print Header
print_header 'nmap ip/port scanner'

#Check number of args
check_args $# 1

#Parameter/Arguments
option=$1
ipaddress=${2:-127.0.0.1}
startport=${3:-0}
endport=${4:-1000}


#Main Functions
main() {

    #Check Inputargs
    case ${option} in
            --test)
                log -info "test Command for debugging $0"
                ;;

            --localhost)
                log -info "scan localhost"
                check_requirements
                scan_localhost
                ;;

            --ip-port)
                log -info "scan ip port range"
                check_requirements
                scan_ip_port_range ${startport} ${endport} ${ipaddress}
                ;;

            --ip-range)
                log -info "scan ip range"
                check_requirements
                scan_ip_range ${ipaddress}
                ;;

            --os)
                log -info "scan os"
                check_requirements
                scan_os ${ipaddress}
                ;;

            --help | --info | *)
                usage   "\-\-test:                                          test command" \
                        "\-\-ip-port [192.168.1.*] [startport] [endport]:   scan ip port" \
                        "\-\-ip-range [192.168.1.*]:                        scan ip range" \
                        "\-\-os [192.168.1.50]:                             scan os for ip" \
                        "\-\-help:                                          help"
                ;;
    esac
}


#Check localhost
scan_localhost() {

    nmap localhost
}

#Scan Port from Specific IP Address
#Startport / Endport / Ip-Address
#nmap -sV -p 1-100 192.168.1.1/24
scan_ip_port_range() {

    if [ -z $1  ]; then
        log -info"parameter for startport empty"
        cleanup_exit ERR
    fi   

    if [ -z $2  ]; then
        log -info"parameter for endport empty"
        cleanup_exit ERR
    fi   

    if [ -z $3  ]; then
        log -info"parameter for ip address empty"
        cleanup_exit ERR
    fi  

    nmap -sV -v -p $1-$2 $3
}

scan_ip_range() {

    if [ -z $1  ]; then
        log -info"parameter for ip range empty"
        cleanup_exit ERR
    fi   

    nmap -sP $1
}

#Scan OS
#Ip-Address
scan_os() {

    if [ -z $1  ]; then
        log -info "parameter for ip-address empty"
        cleanup_exit ERR
    else   
        log -info "scan host '$1'" 
        nmap -A $1
    fi    
}

#Check requirements
check_requirements() {

    #Check Root
    if [ $(id -u) -ne 0 ]; then
        log -info "restricted execution - no root access"
        #log -info "Usage: run '$0' as root."
        #cleanup_exit ERR
    fi

    #Check Uefi Firmware
    if pkg info nmap | grep nmap; then
        log -info "nmap Found"
    else
        pkg install -y nmap 
    fi
}

#Call main Function manually - if not need uncomment
main "$@"; exit