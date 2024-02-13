#!/bin/sh
#SPDX-License-Identifier: MIT

#Setup jail guest

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
print_header 'setup jail guest from configfile'

#Check number of args
check_args $# 1

#Parameter/Arguments
option=$1
config_file=${2:-"./conf/jail_standard.conf"}

#Main Functions
main() {

    #Check Inputargs
    case ${option} in
            --test)
                log -info "test Command for debugging $0"
                ;;

             --init)
                load_config ${config_file}
                log -info "init jail ${jail_name} from configfile"
                check_requirements
                create_zfs_host
                check_vnet_host
                network_init
                ;;

            --create)
                load_config ${config_file}
                log -info "create jail ${jail_name} from configfile"
                check_requirements
                create_zfs_host
                download_base
                check_vnet_host
                set_rc_sysctl_local
                write_devfs_rules
                copy_hostdata
                write_jail_conf
                write_pf_conf
                write_fstab
                start_jail
                add_software
                ;;

            --clone)
                load_config ${config_file}
                log -info "clone jail ${jail_name} "
                check_root
                clone_zfs_snapshot
                write_jail_conf
                write_pf_conf
                start_jail
                ;;

            --snapshot)
                load_config ${config_file}
                log -info "snapshot jail ${jail_name} "
                check_root
                create_zfs_snapshot
                ;;

            --start)
                load_config ${config_file}
                log -info "start jail ${jail_name} from configfile"
                check_requirements
                start_jail
                ;;

            --attach)
                load_config ${config_file}
                log -info "attach jail ${jail_name} "
                check_requirements
                attach_jail
                ;;

            --list)
                log -info "list jails"
                list_jail
                ;;

            --list_snapshots)
                log -info "list jail snapshots"
                list_zfs_snapshots
                ;;

            --stop)
                log -info "stop jails"
                check_root
                stop_jail
                ;;

            --clean)
                load_config ${config_file}
                log -info "clean jails"
                check_root
                clean_jail_data
                ;;

            --upgrade)
                load_config ${config_file}
                log -info "upgrade jail"
                check_requirements
                install_updates
                ;;

            --add_sw)
                load_config ${config_file}
                log -info "add software"
                check_root
                add_software
                ;;

            --help | --info | *)
                usage   "\-\-test:                          test command" \
                        "\-\-init (configfile):             init jail system from configfile" \
                        "\-\-create (configfile):           create jail from configfile" \
                        "\-\-clone (configfile):            clone jail" \
                        "\-\-snapshot (cnfigfile):          snapshot jail" \
                        "\-\-start (configfile):            start jail" \
                        "\-\-stop:                          stop all jails" \
                        "\-\-attach (configfile):           attach jail" \
                        "\-\-clean:                         clean all jails instances" \
                        "\-\-list:                          list jails" \
                        "\-\-upgrade (configfile):          upgrade jails" \
                        "\-\-add_sw (configfile):           install software from configfile" \
                        "\-\-list_snapshots:                list jails snapshots" \
                        "\-\-help:                          help"
                ;;
    esac
}


#Execute external script
execute_script() {

    log -info "$0: external script: ${ext_script}"

    #Create Jail standard guest
    if [ ! -z  ${ext_script} ]; then
        log -info "$0: external script found."

        #Execute External script
        if [ -f  ${ext_script} ]; then
            . ${ext_script}
        else
            log -info "$0: external script not found."
            cleanup_exit ERR 
        fi  

    else
        log -info "$0: external script not used."
    fi  

}


#Create Jail Snapshot
#$1 Snapshot number
create_zfs_snapshot() {

    #Create ZFS Snapshot
    log -info "clone ${jail_name}"
    zfs snapshot zroot/${location_main}/${location_release}/${bsd_release}@${jail_name} 
}

#Clone Jail Snapshot
#$1 Snapshot number
#$2 New Jail Name
clone_zfs_snapshot() {

    #Clone Snapshot
    log -info "clone ${jail_clone}"
    zfs clone zroot/${location_main}/${location_release}/${bsd_release}@${jail_name} zroot/${location_main}/${jail_clone}
}

#List Zfs Snapshots
list_zfs_snapshots() {

    log -info "list jail snapshots"
    zfs list -t snapshot zroot/${location_main}
}

#List Jails
list_jail() {

    printf "\n\n"
    
    printf "ID\t\tNAME\t\t\t\t\t\IP\n"
    JAILS="$(jls | awk 'NR>1 { print $1 }')"
    for JAIL in $JAILS; do
        printf "$JAIL\t\t$(jexec $JAIL hostname)\t\t$(jexec $JAIL ifconfig | grep inet | grep -v inet6 | grep -v 127.0.0.1)\n"
    done

    printf "\n\n"

}

#Install Updates - Attention ZFS files changes
install_updates(){

        env ASSUME_ALWAYS_YES=YES pkg -j ${jail_name} update
        env ASSUME_ALWAYS_YES=YES pkg -j ${jail_name} upgrade -f
}

#Install software from configfile
add_software() {

    log -info "install software in jail"

    #install tools when defined
    install_tools

    #install software via script
    execute_script


}

#Add Software
install_tools() {

    log -info "install software in jail"
    
    #Check Jail
    check_jail ${jail_name} ERR
    
    #Insatll Software Tools
    if [ -z ${bsd_tools} ]; then
        log -info "no software for install defined ${jail_name}"
    else
        env ASSUME_ALWAYS_YES=YES pkg -j ${jail_name} install ${bsd_tools}
    fi
}


#stop Jails
stop_jail() {

    service jail stop
}

#Network init flag
network_init() {

    #Write network init
    log -info "write network initialization"
    touch "/${location_main}/${location_config}/network_init"

    log -info "$0: network not initialized - please reboot hostmachine"
    log -info "$0: after rebbot use --add_sw parameter for install only software part"
}

#Start Jail
start_jail() {

    #Check init or network
     if [ -f "/${location_main}/${location_config}/network_init" ]; then
        log -info "$0: network initialized - release jail start"
        log -info "start jail ${jail_name}"
        service jail start ${jail_name}
    else
        #Network init flag
        network_init
        
        #exit
        cleanup_exit ERR 
    fi

   
}


#Attach jail
attach_jail() {

    log -info "attach jail ${jail_name}"
    jexec ${jail_name} sh
}


#Clean Jail Data
clean_jail_data() {

    #Checl location main
    if [ -z ${location_main} ]; then
        log -info "location main variable set ${location_main}"
    else
        if [ -z "/jails" ]; then
            location_main=/jails
        fi
    fi

    log -info "stop jails"
    service jail stop
    
    log -info "clean jail data - zfs"
    zfs destroy -f -r zroot/${location_main}

    log -info "clean jail data - rc.conf"
    sysrc -x jail_enable
    sysrc -x jail_list 

    log -info "clean jail data - jail.conf.d"
    rm /etc/jail.conf.d/*

}



#Create zfs host
create_zfs_host() {

#ZFS for jails
    if zfs list | grep "zroot/${location_main}"; then
        log -info "zfs dataset exists for ${location_main}"
    else
        log -info "create zfs dataset for ${location_main}"
        zfs create -o mountpoint=/${location_main} zroot/${location_main}
    fi

    #Folder for jails
    if [ -d "/${location_main}/${jail_name}" ]; then
        log -info "zfs dataset exists for ${jail_name}"
    else
        log -info "create zfs dataset for ${jail_name}"
        zfs create zroot/${location_main}/${jail_name}
    fi

    #Folder for releases
    if [ -d "/${location_main}/${location_release}" ]; then
        log -info "folder exists for releases"
    else
        log -info "create folder for releases"
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

}

#Download base and update system
download_base() { 

    #Check if linuxOS or BSD is used
    if [ -z ${linux_version} ]; then

        #Download base system
        if [ -f "/${location_main}/${location_media}/${bsd_release}_${bsd_arch}_base.txz" ]; then
            log -info "bsd base file found"
        else
            log -info "download bsd base system"
            fetch http://ftp.freebsd.org/pub/FreeBSD/releases/$bsd_arch/$bsd_release/base.txz -o /${location_main}/${location_media}/${bsd_release}_${bsd_arch}_base.txz
        fi  

        #Extract & Update
        if [ -d "/${location_main}/${jail_name}/bin" ]; then
            log -info "tar allready extracted"
        else
            log -info "extract tar ball"
            tar -xvf /${location_main}/${location_media}/${bsd_release}_${bsd_arch}_base.txz -C /jails/${jail_name}
        fi

    else

        #debootstrap
        if [ ${linux_bootstrap} == 'debootstrap' ]; then

            if [ -d "/${location_main}/${jail_name}/bin" ]; then
                log -info "debootstrap system found"
            else
                log -info "debootstrap not found - execute debootstrap"
                #Debootstrap system
                debootstrap --foreign --arch=amd64 ${linux_version} /${location_main}/${jail_name} ${linux_url}
            fi

        #tar ball bottstrap - eg. alpine
        elif [ ${linux_bootstrap} == 'tar' ]; then
            
            log -info "bootstrap tarball"
            
            #Download base system
            if [ -f "/${location_main}/${location_media}/${linux_version}" ]; then
                log -info "linux base file found"
            else
                log -info "download linux base system"
                fetch ${linux_url} -o /${location_main}/${location_media}/${linux_version}
            fi  

            #Extract & Update
            if [ -d "/${location_main}/${jail_name}/bin" ]; then
                log -info "tar allready extracted"
            else
                log -info "extract tar ball"
                tar -xvf /${location_main}/${location_media}/${linux_version} -C /${location_main}/${jail_name}
            fi

        else
            log -info "$0: no valid bottstrap option selected."
            cleanup_exit ERR 
        fi
        
        #Check if folder exists
        if [ -d "/${location_main}/${jail_name}/bin" ]; then
            log -info "bin folder found - ok"
        else
            log -info "bin folder ot found - abort"
            cleanup_exit ERR 
        fi

        #Create Additional folder
        log -info "create additional folder"
        if [ ! -d "/${location_main}/${jail_name}/dev" ]; then
            mkdir -p /${location_main}/${jail_name}/dev
        fi
        if [ ! -d "/${location_main}/${jail_name}/dev/shm" ]; then
            mkdir -p /${location_main}/${jail_name}/dev/shm
        fi
        if [ ! -d "/${location_main}/${jail_name}/proc" ]; then
            mkdir -p /${location_main}/${jail_name}/proc
        fi
        if [ ! -d "/${location_main}/${jail_name}/sys" ]; then
            mkdir -p /${location_main}/${jail_name}/sys
        fi        

        #check symbolic links for network tools
        log -info "check symbolic links for network tools"
        if [ -L "/${location_main}/${jail_name}/bin/ifconfig" ]; then
            log -info "remove symbolic link for ifconfig"
            rm "/${location_main}/${jail_name}/bin/ifconfig"
        fi
        if [ -L "/${location_main}/${jail_name}/sbin/ifconfig" ]; then
            log -info "remove symbolic link for ifconfig"
            rm "/${location_main}/${jail_name}/sbin/ifconfig"
        fi   
        if [ -L "/${location_main}/${jail_name}/bin/route" ]; then
            log -info "remove symbolic link for route"
            rm "/${location_main}/${jail_name}/bin/route" 
        fi
        if [ -L "/${location_main}/${jail_name}/sbin/route" ]; then
            log -info "remove symbolic link for route"
            rm "/${location_main}/${jail_name}/sbin/route" 
        fi   

        #copy ifconfig & route for jail
        log -info "copy network tools"
        cp /rescue/ifconfig /${location_main}/${jail_name}/bin/
        cp /rescue/ifconfig /${location_main}/${jail_name}/sbin/
        cp /rescue/route /${location_main}/${jail_name}/bin/
        cp /rescue/route /${location_main}/${jail_name}/sbin/

    fi      
}

#Update Jail-Id - read from File
update_jail_id() {

    #Read/Write Jail Id
    if [ -f "/${location_main}/${location_config}/jail_id" ]; then
        log -info "jail id file found"
        jail_id="$(cat /${location_main}/${location_config}/jail_id)"
        echo $((jail_id+1)) > /${location_main}/${location_config}/jail_id
    else
        log -info "jail id not found - create"
        $jail_id > /${location_main}/${location_config}/jail_id
    fi    
}

#write empty fstab entry
write_fstab() {

    log -info "write fstab"  

#Check if linuxOS or BSD is used
    if [ -z ${linux_version} ]; then

    cat << EOF > ${fstab_name}
#custom bsd jail fstab
EOF
    else
    cat << EOF > ${fstab_name}
#custom linux jail fstab
devfs   /${location_main}/${jail_name}/dev    devfs    rw    0    0
linprocfs   /${location_main}/${jail_name}/proc    linprocfs    rw,late    0    0
linsysfs    /${location_main}/${jail_name}/sys    linsysfs    rw,late    0    0
tmpfs    /${location_main}/${jail_name}/dev/shm    tmpfs    rw,late,mode=1777    0    0
EOF
    fi
}

#Set firewall parameter
write_pf_conf() {

    log -info "write packetfilter to jail"

    #check file exists allready
    if [ -f "/${location_main}/${location_config}/pf.jail_${jail_name}.conf" ]; then
        log -info "jail ${jail_name} packetfilter config allready found"
    else
        log -info "jail ${jail_name} packetfilter config not found - creating"

    #Firewall rules - Standard Device
    cat << EOF > /${location_main}/${location_config}/pf.jail_${jail_name}.conf
#dynamic packetfilter rules for ${jail_name}

#standard nat for jails/bhyve
nat pass on ${net_external_if} from ${net_range} to any -> (${net_external_if})
EOF

    #replace dynamic nat
    if [ -z ${pfrule_nat} ]; then
        log -info "jail ${jail_name} additional nat rule not configured"
    else
        log -info "jail ${jail_name} additional nat rule found - append to file"
        echo "" >> /${location_main}/${location_config}/pf.jail_${jail_name}.conf
        echo ${pfrule_nat} >> /${location_main}/${location_config}/pf.jail_${jail_name}.conf
    fi
    
    #sed -i "" "s/echo load_dynamic_nat/pfctl -a virtual/wireguard rdr pass log on { igb1 } inet proto udp to (igb1) port 51820 -> 10.99.0.24/"
    #replace dynamic rdr
    if [ -z ${pfrule_rdr} ]; then
        log -info "jail ${jail_name} additional rdr rule not configured"
    else
        log -info "jail ${jail_name} additional rdr rule found - append to file"
        echo "" >> /${location_main}/${location_config}/pf.jail_${jail_name}.conf
        echo ${pfrule_rdr} >> /${location_main}/${location_config}/pf.jail_${jail_name}.conf
    fi

    fi

    #load rules
     if [ -z ${pfrule_reload} ]; then
        log -info "jail ${jail_name} do not reload pf.conf"
    else
    log -info "jail ${jail_name} reload pf.conf"
         pfctl -f /etc/pf.conf
    fi
   
}


#Set rc.conf parameter - on local system
set_rc_sysctl_local() {

    log -info "set local rc.conf and sysctl.conf"

    #write rc.conf
    sysrc -f /etc/rc.conf jail_enable=YES
    sysrc -f /etc/rc.conf jail_list+="${jail_name}" 

    #Check if linuxOS or BSD is used
    if [ -z ${linux_version} ]; then
        log -info "bsd jail found"
    else
        log -info "set linux enable"
        sysrc -f /etc/rc.conf linux_enable=YES
    fi

}

#Write devfs.rules
write_devfs_rules(){

cat << EOF > /etc/devfs.rules

[hideall_ruleset=0]
add include \$devfsrules_hide_all

[standard_ruleset=99]
add path 'ugen*' unhide
add path 'usb/*' unhide
add path 'usbctl' unhide
add path 'da/*' unhide

[devfsrules_wireguard=5]
add include \$devfsrules_hide_all
add include \$devfsrules_unhide_basic
add include \$devfsrules_unhide_login
add path 'tun*' unhide
add path 'bpf*' unhide
add path zfs unhide

EOF

}

#Check Vnet Host Interface
check_vnet_host() {

    #Check init or network
     if [ -f "/${location_main}/${location_config}/network_init" ]; then
        log -info "$0: network allready initialized."
    else
    
        #Include virtual net host
        if [ -f  ../net/setup_virtual_net.sh ]; then
            . ../net/setup_virtual_net.sh
        else
            log -info "$0: virtual net script not found."
            cleanup_exit ERR 
        fi

    fi

}

#Copy hostdate
copy_hostdata() {

    log -info "copy host data"
    if [ -f "/etc/resolv.conf" ]; then
        cp /etc/resolv.conf /${location_main}/${jail_name}/etc/resolv.conf
    fi
    if [ -f "/etc/localtime" ]; then
        cp /etc/localtime /${location_main}/${jail_name}/etc/localtime
    fi
}

#create jail config for each jail
write_jail_conf() {

    #check file exists allready
    if [ -f "/etc/jail.conf.d/${jail_name}.conf" ]; then
        log -info "jail ${jail_name} config allready found"
    else
        log -info "jail ${jail_name} config not found - creating"

    #check if linux is selected
    if [ -z ${linux_version} ]; then

        #create header for linux or bsd jail
        cat << EOF > /etc/jail.conf.d/${jail_name}.conf
#BSD Jail
exec.stop  = "/bin/sh /etc/rc.shutdown";
exec.clean;
allow.mount;
EOF


    else
        #create header for linux or bsd jail
        cat << EOF > /etc/jail.conf.d/${jail_name}.conf
#Linux Jail
allow.mount;
allow.mount.procfs;
allow.mount.linprocfs;
allow.mount.linsysfs;
allow.sysvipc = 0;
EOF

fi

#create seperate jail main config for each jail - with vnet adapter
cat << EOF >> /etc/jail.conf.d/${jail_name}.conf
allow.raw_sockets = 1;
allow.mount.devfs;
allow.mount.tmpfs;
devfs_ruleset = ${devfs_ruleset}; 
mount.devfs;
mount.fstab = ${fstab_name};

${jail_name} {
    \$id     = "${jail_id}";
    \$ipaddr_jail = "${net_address_jail}";
    \$ipaddr_host = "${net_address_host}";
    \$mask   = "${net_bridge_sm}";
    \$gw     = "${net_bridge_ip}";
    vnet;
    vnet.interface = "epair\${id}b";

    host.hostname = "\${name}.jail-host";
    path = "/jails/\${name}";
    exec.consolelog = "/var/log/jail-\${name}.log";

    exec.prestart   = "logger ${jail_name} create jail";
    
EOF

    #Load Additional Kernel Module
    if [ -z ${kernel_module} ]; then
        log -info "jail ${jail_name} additional kernel module not configured"
    else
        cat << EOF >> /etc/jail.conf.d/${jail_name}.conf
    exec.prestart  += "if [ -f ${kernel_module} ]; then kldload ${kernel_module};fi";
EOF
    fi
    
    cat << EOF >> /etc/jail.conf.d/${jail_name}.conf
    exec.prestart  += "ifconfig epair\${id} create up";
    exec.prestart  += "ifconfig epair\${id}a up descr vnet-\${name}";
    exec.prestart  += "ifconfig epair\${id}a inet \${ipaddr_host} netmask \${mask} up";
    exec.prestart  += "sleep 1";
EOF

 #Load Additional Kernel Module
    if [ -z ${net_bridge_add} ]; then
        log -info "jail ${jail_name} do not add jail to system bridge"
    else
        cat << EOF >> /etc/jail.conf.d/${jail_name}.conf
    exec.prestart  += "ifconfig ${net_bridge_name} addm epair\${id}a up";
    exec.prestart  += "sleep 1";
EOF
    fi
    
    #Write Footer
    cat << EOF >> /etc/jail.conf.d/${jail_name}.conf
    exec.prestart  += "pfctl -a virtual/${jail_name} -f /${location_main}/${location_config}/pf.jail_${jail_name}.conf";

    exec.start      = "/sbin/ifconfig lo0 inet 127.0.0.1 up";
    exec.start     += "/sbin/ifconfig epair\${id}b inet \${ipaddr_jail} netmask \${mask} up";
    exec.start     += "/sbin/route add default \${gw}";

    exec.start     += "${exec_rc_start}";
    exec.stop       = "${exec_rc_stop}";

    exec.prestop    = "ifconfig epair\${id}b -vnet \${name}";

    exec.poststop   = "logger ${jail_name} end jail";
    exec.poststop  += "ifconfig ${net_bridge_name} deletem epair\${id}a";
    exec.poststop  += "ifconfig epair\${id}a destroy";

    persist;
}

EOF


fi
}

#Check requirements
check_requirements() {

    #Check Root
    check_root

    #Check Command
    if command -v jls >/dev/null 2>&1 ; then
        log -info "jls program Found"
    else
        log -info "jls program Not Found"
        cleanup_exit ERR
    fi 

}

#Call main Function manually - if not need uncomment
main "$@"; exit

#grep : missing nach jls program found
