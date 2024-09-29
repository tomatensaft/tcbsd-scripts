#!/bin/sh
#SPDX-License-Identifier: MIT

#set -x

# set absolute path of root app for global use - relative path from this point
# ${PWD%/*} -> one folder up / ${PWD%/*/*} -> two folders up
# adjust script application path/folder
# configuration file will be the same main name as the shell script - but only with .conf extension

# option
option=${1}

# script parameter
root_path="${PWD%/*}/tomatoe-lib/" # "${PWD%/*}/tomatoe-lib/"
main_lib="${root_path}/main_lib.sh"
app_name="${0##*/}"
app_fullname="${PWD}/${app_name}"
#conf_default="$(echo "$app_fullname" | sed 's/.\{2\}$/conf/')"
conf_default="${PWD%/*}/tomatoe_lib.conf"
conf_custom=${2:-"none"}


# header of parameter
printf "\nparameters load - $(date +%Y-%m-%d-%H-%M-%S)\n"
printf "########################################\n\n"

# load config file for default parameters
if [ -f  ${conf_default} ]; then
   printf "$0: include default parameters from ${conf_default}\n"
   . ${conf_default}
else
   printf "$0: config lib default parameters not found - exit\n"
   exit 1
fi

# load config file for custom parameters
if [ ${conf_custom} != "none" ]; then
   if [ -f  ${conf_custom} ]; then
      printf "$0: include custom parameters from ${conf_custom}\n"
      . ${conf_custom}
   else
      printf "$0: config lib custom parameters not found - exit\n"
      exit 1
   fi
else
   printf "$0: no custom file in arguments - not used\n"
fi

# test include external libs from main submodule
if [ -f  ${main_lib} ]; then
   . ${main_lib}
else
   printf "$0: main libs not found - exit.\n"
   exit 1
fi

# print main parameters
print_main_parameters

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


