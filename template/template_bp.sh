#!/bin/sh
#spdx-license-identifier: mit
#not finished - not tested

#short info

#include extenal scripts
if [ -f  ../../lib/shared_lib.sh ]; then
    . ../../lib/shared_lib.sh
elif [ -f  ../lib/shared_lib.sh ]; then
    . ../lib/shared_lib.sh
else
    log -info "$0: shared lib not found."
    cleanup_exit err 
fi

#print header
print_header 'header description'

#check number of args
check_args $# 1

#parameter/arguments
option=$1
param_1="$(ls)"
param_2="filename.txt"

#main functions
main() {

    #check inputargs
    case $option in
            --test)
                log -info "test command for debugging $0"
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


#check requirements
check_requirements() {
    #check root
    check_root

    #check command
    if command -v ls >/dev/null 2>&1 ; then
        log -info "program found"
    else
        log -info "program not found"
        cleanup_exit err
    fi 
}

#call main function manually - if not need uncomment
main "$@"; exit