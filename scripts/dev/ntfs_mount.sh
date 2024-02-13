#!/bin/sh
#SPDX-License-Identifier: MIT

#Short Info

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
print_header 'ntfs mount'

#Check number of args
check_args $# 1

#Parameter/Arguments
option=$1
device=${2:-"/dev/da0s1"}
mountpath="/mnt/ntfs"

#Main Functions
main() {

    #Check Inputargs
    case $option in
            --test)
                log -info "test Command for debugging $0"
                ;;

            --mount)
                log -info "mount ntfs device"
                check_requirements
                check_folder
                mount_ntfs ${device}
                ;;

            --umount)
                check_requirements
                log -info "umount ntfs device"
                umount_ntfs
                ;;

            --list_gp)
                log -info "list gpart devices"
                check_gpart ${device}
                ;;

            --list_dev)
                log -info "list dev devices"
                check_devices ${device}
                ;;

            --persistent)
                log -info "setup persistent"
                setup_persistent
                ;;
        
            --help | --info | *)
                usage   "\-\-test:                  test command" \
                        "\-\-mount [/dev/daX]:      mount device - optional parameter" \
                        "\-\-list_gp:               list gpart devices" \
                        "\-\-list_dev:              list devices" \
                        "\-\-umount:                umount device" \
                        "\-\-persistent:            mount persistent" \
                        "\-\-help:                  help"
                ;;
    esac
}


#Check Folder
check_folder() {

    if [ -d $mountpath ]; then
        log -info "folder ${mountpath} found"
    else
        log -info "folder ${mountpath} not found"
        mkdir -m 777 $mountpath #for all users         
    fi
#Include extenal scripts
if [ -f  ../../lib/shared_lib.sh ]; then
    . ../../lib/shared_lib.sh
elif [ -f  ../lib/shared_lib.sh ]; then
    . ../lib/shared_lib.sh
else
    log -info "$0: shared lib not found."
    cleanup_exit ERR 
fi
check_gpart() {

    log -info "list part devices"

    if [ "$1" = "/dev/da0s1" ]; then
	    log -info "Use /dev/da0"
        gpart show /dev/da0
    else
        gpart show $1   
	fi
}

#Check devices
check_devices() {

    log -info "list dev devices (most $1)"

    if [ "$1" = "/dev/da0s1" ]; then
	    log -info "Use /dev/da0"
        ls -l /dev/da0* 
    else
        ls -l $1   
	fi
}

#Mount ntfs device
mount_ntfs() {

    log -info "mount device readonly (standard $1)"

    if [ -d $1 ]; then
        log -info "device $1 found"
        ntfs-3g $1 ${mountpath} -o ro
    elif [ -d "/dev/da0p1" ]; then
        log -info "folder /dev/da0p1 found"
        ntfs-3g /dev/da0p1 ${mountpath} -o ro
    else
        log -info "No mount device in /dev found"       
    fi   
}

#Umount ntfs device
umount_ntfs() {

    log -info "unmount ${mountpath}"
    umount ${mountpath}
}

#Setupt persisetnt into config files
setup_persistent() {

    add_or_replace_in /boot/loader.conf 'fuse_load=' '"YES"'
    add_or_replace_in /etc/sysctl.conf 'vfs.usermount=' '"1"'
}

#Check requirements
check_requirements() {

    #Check Root
    check_root

    #Check Command
    if command -v ls >/dev/null 2>&1 ; then
        log -info "program Found"
    else
        log -info "program Not Found"
        cleanup_exit ERR
    fi 

    #Check FuseFS package
    if pkg info fusefs | grep fusefs-ntfs; then
        log -info "fusefs package found"
    else
        pkg install -y fusefs-ntfs
    fi

    #Check Kernel Modules
    if kldstat | grep fusefs; then
        log -info "kernel module fusefs found"
    else
        log -info "load kernel module fusefs"
        kldload fusefs
        sysctl vfs.usermount=1
    fi
}

#Call main Function manually - if not need uncomment
main "$@"; exit