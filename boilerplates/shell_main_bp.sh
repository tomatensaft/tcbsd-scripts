#!/bin/sh
# SPDX-License-Identifier: MIT

# set -x

# set absolute path of root app for global use - relative path from this point
SCRIPT_ROOT_PATH="../"

# include external libs from git submodule
if [ -f  ${SCRIPT_ROOT_PATH}/posix-lib-utils/tcbsd_lib.sh ]; then
    . ${SCRIPT_ROOT_PATH}/posix-lib-utils/tcbsd_lib.sh
else
    printf "$0: external libs not found - exit.\n"
    exit 1
fi

#print header
print_header 'header description'

#check number of args
check_args $# 1

#parameter/Aaguments
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

    #check Root
    check_root

    #check Command
    if command -v ls >/dev/null 2>&1 ; then
        log -info "program found"
    else
        log -info "program not found"
        cleanup_exit ERR
    fi 
}

#call main function manually - if not need uncomment
main "$@"; exit