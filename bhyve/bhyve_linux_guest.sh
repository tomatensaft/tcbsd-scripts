#!/bin/sh
#SPDX-License-Identifier: MIT

#set -x

# set absolute path of root app for global use - relative path from this point
# ${PWD%/*} -> one folder up / ${PWD%/*/*} -> two folders up 
SCRIPT_ROOT_PATH="${PWD%/*}/posix-lib-utils"

# test include external libs from tcbsd submodule
if [ -f  ${SCRIPT_ROOT_PATH}/tcbsd_lib.sh ]; then
    . ${SCRIPT_ROOT_PATH}/tcbsd_lib.sh
else
    printf "$0: tcbsd external libs not found - exit.\n"
    exit 1
fi

#Check number of args
check_args $# 1

#Print Header
print_header 'setup bhyve/linux guest from configfile'

#Parameter/Arguments
option=$1
config_file=${2:-./conf/bhyhve_standard.conf}

#Main Functions
main() {

    #Check Inputargs
    case ${option} in
            --test)
                log -info "test Command for debugging $0"
                ;;

            --init)
                load_config ${config_file}
                log -info "init bhyve ${jail_name} from configfile"
                check_requirements
                create_zfs_host
                check_vnet_host
                network_init
                ;;

            --create)
                load_config ${config_file}
                log -info "create bhyve linux guest ${bhyve_name}"
                check_requirements
                check_vnet_host
                create_zfs_host
                download_base
                create_net_config
                write_pf_conf
                start_pf_conf
                install_linux_guest
                ;;

            --start)
                load_config ${config_file}
                log -info "start bhyve linux guest ${bhyve_name}"
                check_requirements
                create_net_config
                start_pf_conf
                start_linux_guest
                ;;

            --clean)
                log -info "clean bhyve"
                check_root
                clean_bhyve_data
                ;;

            --list)
                log -info "list bhyve linux guests"
                list_bhyve
                ;;

            --help | --info | *)
                usage   "\-\-test:                          test command" \
                        "\-\-init (configfile):             init jail system from configfile" \
                        "\-\-create (configfilename):       create bhyve instance from configfile" \
                        "\-\-start (configfilename):        start bhyve instance from configfile" \
                        "\-\-clean:                         clean bhyve instances" \
                        "\-\-stop:                          stop bhyve instances" \
                        "\-\-list:                          list bhyve instances" \
                        "\-\-help:                          help"
                ;;
    esac
}


#List running bhyve instances
list_bhyve(){
    log -info "list running bhyve instances"
    ls -la /dev/vmm
}

#Clean Jail Data
clean_bhyve_data() {

    log -info "stop bhyve"
    killall bhyve
    
    #bhyvectl --vm=${bhyve_name} --destroy

    log -info "clean bhyve data - zfs"
    zfs destroy -f -r zroot/${location_main}

    log -info "clean jail data - rc.conf - remove manually"
}


#Check Vnet Host Interface
check_vnet_host() {

    #Virtual Net Host
    if [ -f  ../net/setup_virtual_net.sh ]; then
        . ../net/setup_virtual_net.sh
    else
        log -info "$0: virtual net script not found."
        cleanup_exit ERR 
    fi
}

#Download base and update system
download_base() { 

    #Download base system
    if [ -f "/${location_main}/${location_media}/${image_file}" ]; then
        log -info "base file found"
    else
        log -info "download base system"
        fetch -o "/${location_main}/${location_media}/${image_file}" "${image_url}"

        #Check again if file exists
        if [ -f "/${location_main}/${location_media}/${image_file}" ]; then
            log -info "base file download ok"
        else    
            log -info "base file download failed"
            cleanup_exit ERR 
        fi
    fi  
}

#Network init flag
network_init() {

    #Write network init
    log -info "write network initialization"
    touch "/${location_main}/${location_config}/network_init"

    log -info "$0: network not initialized - please reboot hostmachine"
    log -info "$0: after rebbot use --add_sw parameter for install only software part"
}

#Set firewall parameter
write_pf_conf() {

    log -info "write packetfilter to bhyve"

    #check file exists allready
    if [ -f "/${location_main}/${location_config}/pf.bhyve_${bhyve_name}.conf" ]; then
        log -info "bhyve ${bhyve_name} packetfilter config allready found"
    else
        log -info "bhyve ${bhyve_name} packetfilter config not found - creating"

    #Firewall rules - Standard Device
    cat << EOF >> /${location_main}/${location_config}/pf.bhyve_${bhyve_name}.conf
#dynamic packetfilter rules for ${bhyve_name}
nat pass on ${net_external_if} from ${net_range} to any -> (${net_external_if})
pass out all keep state
EOF
    fi
}

#Start Fireall parameter
start_pf_conf() {

    #Check File
    if [ -f "/${location_main}/${location_config}/pf.bhyve_${bhyve_name}.conf" ]; then
        log -info "firewall rule file found - load rule"
        pfctl -a virtual/${bhyve_name} -f /${location_main}/${location_config}/pf.bhyve_${bhyve_name}.conf;
    else
        log -info "no firewall rule found - check"
    fi
    
}

#Create Network configuration
create_net_config() {

    #Check if tap exists
    if ifconfig | grep ${net_tap_if}; then
        log -info "tap allready exists"
    else
        log -info "tap not found - create"
        tap=$(ifconfig tap create name ${net_tap_if})
    fi


    #Check if Bridge exists
    if ifconfig | grep ${net_bridge_name}; then
        log -error "bridge ${net_bridge_name} found"
        ifconfig ${net_bridge_name} addm ${net_tap_if} up
    else
        log -info "bridge ${net_bridge_name} not found"
    fi
}


#Create zfs host
create_zfs_host() {

    #ZFS for bhyve
    if zfs list | grep "zroot/${location_main}"; then
        log -info "zfs dataset for byhve exists"
    else
        log -info "create dataset for bhyve"
        zfs create -o mountpoint=/${location_main} zroot/${location_main}
    fi

    #Folder for releases
    if [ -d "/${location_main}/${location_release}" ]; then
        log -info "folder exists for releases"
    else
        log -info "create zfs dataset for release"
        mkdir /${location_main}/${location_release}
    fi

    #Folder for media
    if [ -d "/${location_main}/${location_media}" ]; then
        log -info "folder exists for media"
    else
        log -info "create folder for media"
        mkdir /${location_main}/${location_media}
    fi

    #Folder for config
    if [ -d "/${location_main}/${location_config}" ]; then
        log -info "folder exists for config"
    else
        log -info "create folder for config"
        mkdir /${location_main}/${location_config}
    fi

    #Folder for bhyve dev image
    if zfs list | grep ${bhyve_name}; then
        log -info "zfs dev volume exists for ${bhyve_name}"
    else
        log -info "create zfs dev volume for ${bhyve_name}"
        zfs create -V 10G -o volmode=dev zroot/${location_main}/${bhyve_name}
    fi

}


#Start Bhyve linux Guest
install_linux_guest() {

    log -info "install linux guest"
    log -info "bootrom ${bhyve_uefi_bootrom} "
    log -info "imagefile /${location_main}/${location_media}/${image_file}"
    
    #2 Cores / 2 GigRAM / VirtIO / Uefi - Change BHF UEFI Firmware

    bhyve -c 2 -m 2G \
    -A -H \
    -l bootrom,${bhyve_uefi_bootrom} \
    -s 0:0,hostbridge \
    -s 1:0,virtio-blk,/dev/zvol/zroot/${location_main}/${bhyve_name} \
    -s 2:0,virtio-net,${net_tap_if} \
    -s 10:0,ahci-cd,"/${location_main}/${location_media}/${image_file}" \
    -s 29,fbuf,tcp=0.0.0.0:"${bhyve_vnc_port}",w=1024,h=768,wait \
    -s 30,xhci,tablet \
    -s 31:0,lpc \
    ${bhyve_name}
}

#Start Bhyve linux Guest
start_linux_guest() {

    log -info "start linux guest"
    bhyve -c 2 -m 2G \
    -A -H \
    -l bootrom,${bhyve_uefi_bootrom} \
    -s 0:0,hostbridge \
    -s 1:0,virtio-blk,/dev/zvol/zroot/${location_main}/${bhyve_name} \
    -s 2:0,virtio-net,"${net_tap_if}" \
    -s 29,fbuf,tcp=0.0.0.0:"${bhyve_vnc_port}",w=1024,h=768,wait \
    -s 30,xhci,tablet \
    -s 31:0,lpc \
    ${bhyve_name}
}


#Check requirements
check_requirements() {

    #Check Root
    check_root

    #Check Bhyve
    if command -v bhyve >/dev/null 2>&1 ; then
        log -info "bhyve grub program found"
    else
        log -info "bhyve grub program not found"
        c
    fi 

    #Check Grub Uefi Loader
    if pkg info grub2-bhyve | grep bhyve; then
        log -info "bhyve grub uefi loader found"
    else
        pkg install -y grub2-bhyve 
    fi

    #Check Uefi Firmware
    if pkg info bhyve-firmware | grep bhyve; then
        log -info "bhyve uefi firmware found"
    else
        pkg install -y bhyve-firmware 
    fi

    #Check Kernel Modules
    if kldstat | grep vmm; then
        log -info "kernel module vmm found"
    else
        log -info "load kernel module vmm"
        kldload vmm
    fi
}


#Call main Function manuall - if not need uncomment
main "$@"; exit