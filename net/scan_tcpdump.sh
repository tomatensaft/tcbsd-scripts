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
print_header 'tcp dump analyzer'

#Check number of args
check_args $# 1

#Parameter/Arguments
option=$1
interface=${2:-"igb1"}
protocol="tcp"

#Main Functions
main() {

    #Check Inputargs
    case ${option} in
            --test)
                log -info "test command for debugging $0"
                ;;

            --start)
                log -info "start logging"
                check_requirements
                scan_tcp_traffic ${interface}
                ;;

            --help | --info | *)
                usage   "\-\-test:               test command" \
                        "\-\-start [device]:     start device scanning" \
                        "\-\-help:               help"
                ;;
    esac
}

#Get TcpTraffic
scan_tcp_traffic() {
    
    log -info "start scan traffic"
    #tcpdump -i $1 -s 0 -w DHCP.dump #Dump in File 
    tcpdump -i $1 -vv -n
    #Filter with Grep
}



#Check requirements
check_requirements()
{
    #Check Root
    check_root

    #Check Command
    if command -v tcpdump >/dev/null 2>&1 ; then
        log -info "tcpdump program Found"
    else
        log -info "tcpdump program not found"
        cleanup_exit ERR
    fi 
}

#Call main Function manually - if not need uncomment
main "$@"; exit