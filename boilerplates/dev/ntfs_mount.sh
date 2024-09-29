#!/bin/sh
#spdx-license-identifier: mit

#set -x

# set absolute path of root app for global use - relative path from this point
# ${pwd%/*} -> one folder up / ${pwd%/*/*} -> two folders up
# adjust script application path/folder
# configuration file will be the same main name as the shell script - but only with .conf extension

# option
option=${1}

# script parameter
root_path="${pwd%/*}/tomatoe-lib/" # "${pwd%/*}/tomatoe-lib/"
main_lib="${root_path}/main_lib.sh"
app_name="${0##*/}"
app_fullname="${pwd}/${app_name}"
#conf_default="$(echo "$app_fullname" | sed 's/.\{2\}$/conf/')"
conf_default="${pwd%/*}/tomatoe_lib.conf"
conf_custom=${2:-"none"}


# header of parameter
printf "\nparameters load - $(date +%y-%m-%d-%h-%m-%s)\n"
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

# print header
print_header 'ntfs mount'

# check number of args
check_args $# 1

# parameter/arguments
option=$1
device=${2:-"/dev/da0s1"}
mountpath="/mnt/ntfs"

# main functions
main() {

    # check inputargs
    case $option in
            --test)
                log -info "test command for debugging $0"
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
                        "\-\-mount [/dev/dax]:      mount device - optional parameter" \
                        "\-\-list_gp:               list gpart devices" \
                        "\-\-list_dev:              list devices" \
                        "\-\-umount:                umount device" \
                        "\-\-persistent:            mount persistent" \
                        "\-\-help:                  help"
                ;;
    esac
}


# check folder
check_folder() {

    if [ -d $mountpath ]; then
        log -info "folder ${mountpath} found"
    else
        log -info "folder ${mountpath} not found"
        mkdir -m 777 $mountpath #for all users         
    fi
# include extenal scripts
if [ -f  ../../lib/shared_lib.sh ]; then
    . ../../lib/shared_lib.sh
elif [ -f  ../lib/shared_lib.sh ]; then
    . ../lib/shared_lib.sh
else
    log -info "$0: shared lib not found."
    cleanup_exit err
fi
check_gpart() {

    log -info "list part devices"

    if [ "$1" = "/dev/da0s1" ]; then
	    log -info "use /dev/da0"
        gpart show /dev/da0
    else
        gpart show $1   
	fi
}

# check devices
check_devices() {

    log -info "list dev devices (most $1)"

    if [ "$1" = "/dev/da0s1" ]; then
	    log -info "use /dev/da0"
        ls -l /dev/da0* 
    else
        ls -l $1   
	fi
}

# mount ntfs device
mount_ntfs() {

    log -info "mount device readonly (standard $1)"

    if [ -d $1 ]; then
        log -info "device $1 found"
        ntfs-3g $1 ${mountpath} -o ro
    elif [ -d "/dev/da0p1" ]; then
        log -info "folder /dev/da0p1 found"
        ntfs-3g /dev/da0p1 ${mountpath} -o ro
    else
        log -info "no mount device in /dev found"
    fi   
}

# umount ntfs device
umount_ntfs() {

    log -info "unmount ${mountpath}"
    umount ${mountpath}
}

# setup persisetnt into config files
setup_persistent() {

    add_or_replace_in /boot/loader.conf 'fuse_load=' '"yes"'
    add_or_replace_in /etc/sysctl.conf 'vfs.usermount=' '"1"'
}

# check requirements
check_requirements() {

    # check root
    check_root

    # check command
    if command -v ls >/dev/null 2>&1 ; then
        log -info "program found"
    else
        log -info "program not found"
        cleanup_exit err
    fi 

    # check fusefs package
    if pkg info fusefs | grep fusefs-ntfs; then
        log -info "fusefs package found"
    else
        pkg install -y fusefs-ntfs
    fi

    # check kernel modules
    if kldstat | grep fusefs; then
        log -info "kernel module fusefs found"
    else
        log -info "load kernel module fusefs"
        kldload fusefs
        sysctl vfs.usermount=1
    fi
}

# call main function manually - if not need uncomment
main "$@"; exit
