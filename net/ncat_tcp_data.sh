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
print_header 'netcat send/receive tcp data'

#Check number of args
check_args $# 1

#Parameter/Arguments
option=$1
ipaddress=${2:-localhost}
port=${3:-3000}
data=${4:-"TestData"}

#Main Functions
main() {

    #Check Inputargs
    case ${option} in
            --test)
                log -info "test command for debugging $0"
                ;;

            --send)
                log -info "create"
                check_requirements
                send_tcp_data
                ;;

            --listen)
                check_requirements
                log -info "start"
                listen_tcp_data
                ;;

            --help | --info | *)
                usage   "\-\-test:                              test command" \
                        "\-\-send [ipaddress] [port] [data]:    send data" \
                        "\-\-listen [ipaddress] [port]:         start machine" \
                        "\-\-help:                              help" 
                ;;
    esac
}

#Send Tcp Data
send_tcp_data() {

    log -info "send tcp data"
    echo ${data} | nc ${ipaddress} ${port}
}

#Listen Tcp Data
listen_tcp_data() {

    log -info "listen socket"
    nc -l ${ipaddress} ${port}
}

#Check requirements
check_requirements() {

    #Check Root
    check_root

    #Check Command
    if command -v nc >/dev/null 2>&1 ; then
        log -info "ncat program found"
    else
        log -info "ncat program not found"
        cleanup_exit ERR
    fi 
}

#Call main Function manually - if not need uncomment
main "$@"; exit