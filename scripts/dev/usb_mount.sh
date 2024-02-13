#!/bin/sh
#SPDX-License-Identifier: MIT

#Usb helper

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
print_header 'usb mount'

#Check number of args
check_args $# 1

#Parameter/Arguments
option=$1
device=${2:-/dev/da0s1}
mountpath="/mnt/usb"

#Main Functions
main() {
    #Check Inputargs
    case ${option} in
            --test)
                log -info "test Command for debugging $0"
                ;;

            --mount)
                log -info "mount usb device"
                check_requirements
                check_folder
                mount_usb ${device}
                ;;

            --umount)
                log -info "umount usb Device"
                check_requirements
                check_folder
                umount_usb
                ;;

            --list_gp)
                log -info "list gpart devices"
                check_gpart ${device}
                ;;

            --list_dev)
                log -info "list dev devices"
                check_devices ${device}
                ;;

            --help | --info | *)
                usage   "\-\-test:                  test command" \
                        "\-\-mount [/dev/daX]:      mount device - optional parameter" \
                        "\-\-list_gp:               list gpart devices" \
                        "\-\-list_dev:              list devices" \
                        "\-\-umount:                umount device" \
                        "\-\-help:                  help"
                ;;
    esac
}

#Check Gpart
check_gpart() {

    log -info "list part devices"

    if [ "$1" = "/dev/da0s1" ]; then
	    log -info "use /dev/da0"
        gpart show /dev/da0
    else
        gpart show $1   
	fi
}

#Check devices
check_devices() {

    log -info "list dev devices (most da0s1)"

    if [ "$1" = "/dev/da0s1" ]; then
	    log -info "use /dev/da0"
        ls -l /dev/da0* 
    else
        ls -l $1   
	fi
}

#Mount USB Device
mount_usb() {

    log -info "mount device readonly (standard $1)"

    if [ -d $1 ]; then
        log -info "device $1 found"
        mount -t msdosfs $1 ${mountpath}
    elif [ -d "/dev/da0p1" ]; then
        log -info "folder /dev/da0p1 found"
        mount -t msdosfs /dev/da0p1 ${mountpath}
    else
        log -info "No mount device in /dev found"       
    fi   
}

#UMount USB
umount_usb() {

    log -info "unmount ${mountpath}"
    umount ${mountpath}
}

#Check Folder
check_folder() {

    if [ -d ${mountpath} ]; then
        log -info "folder ${mountpath} found"
    else
        log -info "folder ${mountpath} not found"
        mkdir -m 777 ${mountpath} #for all users     
    fi

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