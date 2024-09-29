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
print_header 'setup zfs raid system'

# check number of args
check_args $# 1

# parameter/arguments
option=$1

# main functions
main() {

    # check inputargs
    case ${option} in
            --test)
                log -info "test command for debugging $0"
                ;;

            --stripe)
                log -info "create zfs stripe"
                check_requirements
                create_stripe
                ;;

            --mirror_new)
                log -info "create new zfs mirror"
                check_requirements
                create_mirror
                ;;

            --mirror_attach)
                log -info "attach existing zfs drive"
                check_requirements
                copy_partsheme
                attach_mirror
                set_autoreplace
                copy_efi_part
                ;;

            --raidz)
                log -info "create new zfs raidz"
                check_requirements
                create_raidz
                ;;

            --list_dev)
                log -info "list devices"
                check_requirements
                check_devlist
                ;;

            --delete)
                log -info "delete zfs drive"
                ;;

            --help | --info | *)
                usage   "******first adjust parameter in the sript*******" \
                        "\-\-test:                  test command" \
                        "\-\-stripe:                create stripe" \
                        "\-\-mirror_new:            create new mirror" \
                        "\-\-mirror_attach:         attach mirror" \
                        "\-\-raidz:                 create raidz" \
                        "\-\-list_dev:              list deveices" \
                        "\-\-delete:                delete part" \
                        "\-\-help:                  help"
                ;;
    esac
}


# check gpart
check_devlist() {

    log -info "list devices"
    camcontrol devlist
}

# copy partition sheme
copy_partsheme() {

    log -info "copy partition sheme"
    gpart backup ada0 | gpart restore ada1
}

# attach drive to mirror
attach_mirror() {

    # parmater adjustet ?  uncomment if ok
    log -err "parameter adjusted ?"
    exit 1

    log -info "attach mirror drive"
    zpool attach zroot ada0p2 ada1p2
}

# create mirror
create_mirror() {

    # parmater adjustet ?  uncomment if ok
    log -err "parameter adjusted ?"
    exit 1

    log -info "create mirror drive"
    zpool create db mirror gpt/zfs3 gpt/zfs4     
}

# create striped pool
create_stripe() {

    # parmater adjustet ?  uncomment if ok
    log -err "parameter adjusted ?"
    exit 1

    log -info "create stripe"
    # gpt label style
    zpool create scratch gpt/zfs3 gpt/zfs4 
}

# create raidz
create_raidz() {

    # parmater adjustet ?  uncomment if ok
    log -err "parameter adjusted ?"
    exit 1

    log -info "create raidz"
    zpool create db raidz gpt/zfs3 gpt/zfs4 gpt/zfs5
}

# set autoreplace on
set_autoreplace() {

    log -info "switch on autoreplace"
    zpool set autoreplace=on zroot 
}

# copy mbr bootload
copy_mbr_loader() {

    # parmater adjustet ?  uncomment if ok
    log -err "parameter adjusted ?"
    exit 1

    log -info "copy mbr loader"
    gpart bootcode -b /boot/pmbr -p /boot/gptzfsboot -i 1 ada1
}

# copy efi partition
copy_efi_part() {

    # parmater adjustet ?  uncomment if ok
    log -err "parameter adjusted ?"
    exit 1

    log -info "copy efi partition"
    dd if=/dev/ada0p1 of=/dev/ada1p1 bs=4096
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
}

# call main function manually - if not need uncomment
main "$@"; exit
