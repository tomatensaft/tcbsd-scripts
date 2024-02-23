#!/bin/sh
#SPDX-License-Identifier: MIT
#Not finished - Not tested

#Short Info

#Include extenal scripts
if [ -f  ../../lib/shared_lib.sh ]; then
    . ../../lib/shared_lib.sh
elif [ -f  ../lib/shared_lib.sh ]; then
    . ../lib/shared_lib.sh
else
    log -info "$0: shared lib not found."
    cleanup_exit ERR 
fi

#Print Header
print_header 'header description'

#Check number of args
check_args $# 1

#Parameter/Arguments
option=$1
param_1="$(ls)"
param_2="filename.txt"

#Main Functions
main() {

    #Check Inputargs
    case $option in
            --test)
                log -info "test Command for debugging $0"
                ;;

            --create)
                log -info "create"
                check_requirements
                ;;

            --start)
                check_requirements
                log -info "start"
                ;;


            --delete)
                log -info "delete"
                ;;

            --help | --info | *)
                usage   "\-\-test:      test command" \
                        "\-\-create:    create machine" \
                        "\-\-start:     start machine" \
                        "\-\-delete:    delete machine" \
                        "\-\-help:      help" 
                ;;
    esac
}


#Check requirements
check_requirements() {
    #Check Root
    check_root

    #Check Command
    if command -v ls >/dev/null 2>&1 ; then
        log -info "program found"
    else
        log -info "program not found"
        cleanup_exit ERR
    fi 
}

#Call main Function manually - if not need uncomment
main "$@"; exit