#!/bin/sh
#SPDX-License-Identifier: MIT

#Tcp Traffic Analyzer

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