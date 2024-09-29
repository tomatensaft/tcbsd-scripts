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
print_header 'bhyve qemu convert'

#Check number of args
check_args $# 3

#Parameter/Arguments
option=$1
image_type=${2:-default}
image_input=${3:-default}
image_output=${4:-default}


#Main Functions
main() {

    #Check Inputargs
    case $option in
            --test)
                log -info "test Command for debugging $0"
                ;;

            --convert)
                log -info "convert image"
                check_requirements
                convert_image image_type image_input image_output
                ;;

            --backup)
                check_requirements
                log -info "backup image"
                #Start
                ;;


            --delete)
                log -info "delete image"
                #Delete
                ;;

            --help | --info | *)
                usage   "\-\-test:                                                          test command" \
                        "\-\-convert [qcow, qcow2, vdi, vmdk] [inputimage] [outputimage]:   convert image" \
                        "\-\-backup:                                                        backup image" \
                        "\-\-delete:                                                        delete image" \
                        "\-\-help:                                                          help"  
                ;;
    esac
}

#Convert Image
convert_image() {

    if [ "$1" = "default" ]; then
	    log -error "parameter for type missing."
        cleanup_exit ERR 
	fi
    if [ "$2" = "default" ]; then
	    log -error "parameter for inputimage missing."
        cleanup_exit ERR 
	fi
    if [ "$3" = "default" ]; then
	    log -error "parameter for outputimage missing."
        cleanup_exit ERR 
	fi

    qemu-img convert -f $1 -O raw $2 $3
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

    #Check qemu-devel package
    if pkg info qemu | grep qemu-devel; then
        log -info "qemu found"
    else
        pkg install -y qemu-devel 
    fi

}

#Call main Function manually - if not need uncomment
main "$@"; exit
