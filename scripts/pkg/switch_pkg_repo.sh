#!/bin/sh
#SPDX-License-Identifier: MIT

#Switch Beckhoff Repo to Official and back

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
print_header 'switch repo'

#Check number of args
check_args $# 1

#Parameter/Arguments
option=$1
pkg_file="/usr/local/etc/pkg/repos/FreeBSD.conf"


#Main Functions
main() {

    #Check Inputargs
    case ${option} in
            --test)
                log -info "test Command for debugging $0"
                ;;

            --beckhoff)
                log -info "switch to beckhoff repo"
                check_requirements
                sed -i '' 's|yes|no|g' ${pkg_file}
                ;;

            --official)
                check_requirements
                log -info "switch to official repo"
                sed -i '' 's|no|yes|g' ${pkg_file}
                ;;

            --help | --info | *)
                usage   "\-\-test:                  test command" \
                        "\-\-beckhoff:              switch to beckhoff repo" \
                        "\-\-official:              switch to official repo" \
                        "\-\-help:                  help"
                ;;
    esac
}


#Check requirements
check_requirements() {

    #Check Root
    if [ $(id -u) -ne 0 ]; then
        log -info "usage: run '$0' as root."
        cleanup_exit ERR
    fi

    #Check File Exist
    if [ -f "${pkg_file}" ]; then
        log -info "file Found"
    else
        log -info "file not Found"
        cleanup_exit ERR  
    fi

}

#Call main Function manually - if not need uncomment
main "$@"; exit

