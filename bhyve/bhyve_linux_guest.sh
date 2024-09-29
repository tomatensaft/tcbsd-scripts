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

# check number of args
check_args $# 1

# print header
print_header 'setup bhyve/linux guest from configfile'

# parameter/arguments
option=$1
config_file=${2:-./conf/bhyhve_standard.conf}

# main functions
main() {

    # check inputargs
    case ${option} in
            --test)
                log -info "test command for debugging $0"
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


# list running bhyve instances
list_bhyve(){
    log -info "list running bhyve instances"
    ls -la /dev/vmm
}

# clean jail data
clean_bhyve_data() {

    log -info "stop bhyve"
    killall bhyve
    
    #bhyvectl --vm=${bhyve_name} --destroy

    log -info "clean bhyve data - zfs"
    zfs destroy -f -r zroot/${location_main}

    log -info "clean jail data - rc.conf - remove manually"
}


# check vnet host interface
check_vnet_host() {

    # virtual net host
    if [ -f  ../net/setup_virtual_net.sh ]; then
        . ../net/setup_virtual_net.sh
    else
        log -info "$0: virtual net script not found."
        cleanup_exit err
    fi
}

# download base and update system
download_base() { 

    # download base system
    if [ -f "/${location_main}/${location_media}/${image_file}" ]; then
        log -info "base file found"
    else
        log -info "download base system"
        fetch -o "/${location_main}/${location_media}/${image_file}" "${image_url}"

        # check again if file exists
        if [ -f "/${location_main}/${location_media}/${image_file}" ]; then
            log -info "base file download ok"
        else    
            log -info "base file download failed"
            cleanup_exit err
        fi
    fi  
}

# network init flag
network_init() {

    # write network init
    log -info "write network initialization"
    touch "/${location_main}/${location_config}/network_init"

    log -info "$0: network not initialized - please reboot hostmachine"
    log -info "$0: after rebbot use --add_sw parameter for install only software part"
}

# set firewall parameter
write_pf_conf() {

    log -info "write packetfilter to bhyve"

    # check file exists allready
    if [ -f "/${location_main}/${location_config}/pf.bhyve_${bhyve_name}.conf" ]; then
        log -info "bhyve ${bhyve_name} packetfilter config allready found"
    else
        log -info "bhyve ${bhyve_name} packetfilter config not found - creating"

    # firewall rules - standard device
    cat << eof >> /${location_main}/${location_config}/pf.bhyve_${bhyve_name}.conf
#dynamic packetfilter rules for ${bhyve_name}
nat pass on ${net_external_if} from ${net_range} to any -> (${net_external_if})
pass out all keep state
eof
    fi
}

# start fireall parameter
start_pf_conf() {

    # check file
    if [ -f "/${location_main}/${location_config}/pf.bhyve_${bhyve_name}.conf" ]; then
        log -info "firewall rule file found - load rule"
        pfctl -a virtual/${bhyve_name} -f /${location_main}/${location_config}/pf.bhyve_${bhyve_name}.conf;
    else
        log -info "no firewall rule found - check"
    fi
    
}

# create network configuration
create_net_config() {

    # check if tap exists
    if ifconfig | grep ${net_tap_if}; then
        log -info "tap allready exists"
    else
        log -info "tap not found - create"
        tap=$(ifconfig tap create name ${net_tap_if})
    fi


    # check if bridge exists
    if ifconfig | grep ${net_bridge_name}; then
        log -error "bridge ${net_bridge_name} found"
        ifconfig ${net_bridge_name} addm ${net_tap_if} up
    else
        log -info "bridge ${net_bridge_name} not found"
    fi
}


# create zfs host
create_zfs_host() {

    # zfs for bhyve
    if zfs list | grep "zroot/${location_main}"; then
        log -info "zfs dataset for byhve exists"
    else
        log -info "create dataset for bhyve"
        zfs create -o mountpoint=/${location_main} zroot/${location_main}
    fi

    # folder for releases
    if [ -d "/${location_main}/${location_release}" ]; then
        log -info "folder exists for releases"
    else
        log -info "create zfs dataset for release"
        mkdir /${location_main}/${location_release}
    fi

    # folder for media
    if [ -d "/${location_main}/${location_media}" ]; then
        log -info "folder exists for media"
    else
        log -info "create folder for media"
        mkdir /${location_main}/${location_media}
    fi

    # folder for config
    if [ -d "/${location_main}/${location_config}" ]; then
        log -info "folder exists for config"
    else
        log -info "create folder for config"
        mkdir /${location_main}/${location_config}
    fi

    # folder for bhyve dev image
    if zfs list | grep ${bhyve_name}; then
        log -info "zfs dev volume exists for ${bhyve_name}"
    else
        log -info "create zfs dev volume for ${bhyve_name}"
        zfs create -v 10g -o volmode=dev zroot/${location_main}/${bhyve_name}
    fi

}


# start bhyve linux guest
install_linux_guest() {

    log -info "install linux guest"
    log -info "bootrom ${bhyve_uefi_bootrom} "
    log -info "imagefile /${location_main}/${location_media}/${image_file}"
    
    # 2 cores / 2 gigram / virtio / uefi - change bhf uefi firmware

    bhyve -c 2 -m 2g \
    -a -h \
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

# start bhyve linux guest
start_linux_guest() {

    log -info "start linux guest"
    bhyve -c 2 -m 2g \
    -a -h \
    -l bootrom,${bhyve_uefi_bootrom} \
    -s 0:0,hostbridge \
    -s 1:0,virtio-blk,/dev/zvol/zroot/${location_main}/${bhyve_name} \
    -s 2:0,virtio-net,"${net_tap_if}" \
    -s 29,fbuf,tcp=0.0.0.0:"${bhyve_vnc_port}",w=1024,h=768,wait \
    -s 30,xhci,tablet \
    -s 31:0,lpc \
    ${bhyve_name}
}


# check requirements
check_requirements() {

    # check root
    check_root

    # check bhyve
    if command -v bhyve >/dev/null 2>&1 ; then
        log -info "bhyve grub program found"
    else
        log -info "bhyve grub program not found"
        c
    fi 

    # check grub uefi loader
    if pkg info grub2-bhyve | grep bhyve; then
        log -info "bhyve grub uefi loader found"
    else
        pkg install -y grub2-bhyve 
    fi

    # check uefi firmware
    if pkg info bhyve-firmware | grep bhyve; then
        log -info "bhyve uefi firmware found"
    else
        pkg install -y bhyve-firmware 
    fi

    # check kernel modules
    if kldstat | grep vmm; then
        log -info "kernel module vmm found"
    else
        log -info "load kernel module vmm"
        kldload vmm
    fi
}


# call main function manuall - if not need uncomment
main "$@"; exit
