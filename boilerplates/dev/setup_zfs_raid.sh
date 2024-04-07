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
print_header 'setup zfs raid system'

#Check number of args
check_args $# 1

#Parameter/Arguments
option=$1

#Main Functions
main() {

    #Check Inputargs
    case ${option} in
            --test)
                log -info "test Command for debugging $0"
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
                usage   "******FIRST ADJUST PARAMETER IN THE SRIPT*******" \
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


#Check Gpart
check_devlist() {

    log -info "list devices"
    camcontrol devlist
}

#Copy partition sheme
copy_partsheme() {

    log -info "copy partition sheme"
    gpart backup ada0 | gpart restore ada1
}

#Attach drive to mirror
attach_mirror() {

    #Parmater adjustet ?  uncomment if OK
    log -err "parameter adjusted ?"
    exit 1

    log -info "attach mirror drive"
    zpool attach zroot ada0p2 ada1p2
}

##Create mirror
create_mirror() {

    #Parmater adjustet ?  uncomment if OK
    log -err "parameter adjusted ?"
    exit 1

    log -info "create mirror drive"
    zpool create db mirror gpt/zfs3 gpt/zfs4     
}

#Create striped pool
create_stripe() {

    #Parmater adjustet ?  uncomment if OK
    log -err "parameter adjusted ?"
    exit 1

    log -info "create stripe"
    #gpt label style
    zpool create scratch gpt/zfs3 gpt/zfs4 
}

#Create raidz
create_raidz() {

    #Parmater adjustet ?  uncomment if OK
    log -err "parameter adjusted ?"
    exit 1

    log -info "create raidz"
    zpool create db raidz gpt/zfs3 gpt/zfs4 gpt/zfs5
}

#Set autoreplace on
set_autoreplace() {

    log -info "switch on autoreplace"
    zpool set autoreplace=on zroot 
}

#Copy mbr Bootload
copy_mbr_loader() {

    #Parmater adjustet ?  uncomment if OK
    log -err "parameter adjusted ?"
    exit 1

    log -info "copy mbr loader"
    gpart bootcode -b /boot/pmbr -p /boot/gptzfsboot -i 1 ada1
}

#Copy EFI partition
copy_efi_part() {

    #Parmater adjustet ?  uncomment if OK
    log -err "parameter adjusted ?"
    exit 1

    log -info "copy efi partition"
    dd if=/dev/ada0p1 of=/dev/ada1p1 bs=4096
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
}

#Call main Function manually - if not need uncomment
main "$@"; exit