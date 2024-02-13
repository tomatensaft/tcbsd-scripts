#!/bin/sh
#SPDX-License-Identifier: MIT

#Create local repo

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
print_header 'setup local repo'

#Check number of args
check_args $# 1

#Parameter/Arguments
option=$1
repo_source="https://tcbsd.beckhoff.com/TCBSD/13/stable/packages/"
repo_destination="/tmp/repo/new"
repo_tmp="/tmp/repo"

#Main Functions
main() {

    #Check Inputargs
    case ${option} in
            --test)
                log -info "test command for debugging $0"
                ;;

            --get)
                log -info "get repo from source"
                check_requirements
                get_repo
                copy_repo
                ;;

            --set)
                check_requirements
                set_repo
                ;;

            --delete)
                log -info "delete repo"
                delete_repo
                ;;

            --help | --info | *)
                usage   "\-\-test:              test command" \
                        "\-\-get:               get repo" \
                        "\-\-set:               set repo" \
                        "\-\-delete:            delete repo" \
                        "\-\-help:              help"
                ;;
    esac
}

#Get Repo
get_repo() {

    wget --recursive --timestamping --level=inf --no-cache \
            --no-parent --no-cookies --no-host-directories \
            --relative \
            --directory-prefix ${repo_tmp} ${repo_source}
}

#Copy Repo
copy_repo() {

    cp -r ${repo_tmp} ${repo_destination}
}

#Set new Repo Source
set_repo() {

    sh /usr/local/share/examples/bhf/pkgrepo-set.sh "file:///${repo_destination}/TCBSD/13/stable/packages"
}

#Delete Repo
delete_repo() {

    rm -r ${repo_destination}
}

#Check requirements
check_requirements() {

    #Check Root
    check_root

    #Check Command
    if command -v wget >/dev/null 2>&1 ; then
        log -info "wget program found"
    else
        log -info "wget program not found - install"
        
        env ASSUME_ALWAYS_YES=YES pkg install \
        wget \
    fi 
}

#Call main Function manually - if not need uncomment
main "$@"; exit


