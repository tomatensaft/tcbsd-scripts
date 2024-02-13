#!/bin/sh
#SPDX-License-Identifier: MIT

#Virtual Network configuration bridge

#Print Header
print_header 'setup virtual networking'

#Get actual interface names
#bridge=$(ifconfig -a | sed 's/[ \t:].*//;/^$/d' | grep ${bridge_name})

#Main Functions
main() {

    log -info "create virtual network bridge ${net_bridge_name} ${net_bridge_ip}"

    log -info "check nic device ${net_external_if} for bridge interface"

    if ifconfig | grep ${net_external_if}; then
        log -info "nic found ${net_external_if}"
     
        update_rc_conf           
        create_bridge
        setup_packetfilter

    else
        log -error "nic not found ${net_external_if}"
        cleanup_exit ERR 
    fi
              
}


#Update rc.conf
update_rc_conf() {

    log -info "update rc.conf"
    sysrc -f /etc/rc.conf gateway_enable="YES"
    sysrc -f /etc/rc.conf pf_enable="YES"
    sysrc -f /etc/rc.conf pflog_enable="YES"

    #Add Default Router
    if [ -z ${bsd_tools} ]; then
        log -info "no default router ${jail_name}"
    else
        sysrc -f /etc/rc.conf defaultrouter="${net_defaultrouter}"
    fi
    
}


#Create Brigde for virtual guests
create_bridge() {

    #awk '/ifconfig/ { print; print "new line"; next }1' rc.conf

    #Check if Bridge exists
    if grep ${net_bridge_name} /etc/rc.conf; then
        log -info "bridge ${net_bridge_name} found in rc.conf"
    else
    log -info "bridge ${net_bridge_name} creating/update - create persistent"
    sysrc -f /etc/rc.conf cloned_interfaces+="${net_bridge_name}"

    #Config bridge without external interface - safe mode
    sysrc -f /etc/rc.conf ifconfig_${net_bridge_name}="inet ${net_bridge_ip} netmask ${net_bridge_sm} descr ${net_bridge_desc}"

    #Config bridge with external interface
    sysrc -f /etc/rc.conf ifconfig_${net_bridge_name}="inet ${net_bridge_ip} netmask ${net_bridge_sm} descr ${net_bridge_desc} addm ${net_external_if}"


    #Packetfilter for bridge
    if [ ${net_bridge_filter} == '1' ]; then
        log -info "pf for bridge - switched on"
    else
        log -info "pf for bridge - switched off"
        sysrc -f /etc/sysctl.conf net.link.bridge.pfil_member="0"
        sysrc -f /etc/sysctl.conf net.link.bridge.pfil_bridge="0"
    fi

    #Start Bridge
    service netif start ${net_bridge_name}

    fi

    #Check if Jail entry is found
    if  grep jail_enable /etc/rc.conf ; then
        log -info "rc.conf - jail_enabled found - set to the end"
        
        #Remove entry
        sysrc -x jail_enable

        #Add to the end - bridge must start bevoce all the jails
        sysrc -f /etc/rc.conf jail_enable=YES

    else
        log -info "rc.conf - jail_enabled not found"
    fi

}

#Set firewall parameter
setup_packetfilter() {

    log -info "write pf anchor file"

    #Write rules for virutal network config
    cat << EOF > /etc/pf.conf.d/virtual
#configuration for virtual networkig bhyve/jail

#udp services
pass in proto udp to port 53

#tcp services
pass in proto tcp to port {22, 53, 80, 443, 1883, 8883, 8086, 4443}

EOF

    log -info "set pf.conf anchors"

#Check Content
if grep "anchor virtual" "/etc/pf.conf"; then
    log -info "pf anchor found"
else

    log -info "pf anchor not found - creating"

    if check_bhf_device ; then

    log -info "write pf anchor for tcbsd device"

    #Firewall rules - tcbsd device - normally scrub in all should be there
    sed -i "" "s|scrub in all|&\n\\
#allow dynamic virtual if configuration\\
nat-anchor "\"virtual\/*\""\\
rdr-anchor "\"virtual\/*\"" \n|" /etc/pf.conf

    #Append fo Firewall
    cat << EOF >> /etc/pf.conf

#allow comfiguration for bhyve/jail networking
anchor virtual
load anchor virtual from "/etc/pf.conf.d/virtual"

EOF



    
    else
    log -info "write firewall config for standard-bsd device"
    #Firewall rules - Bsd Device
    cat << EOF >> /etc/pf.conf
#custom /etc/pf.conf configuration

#Skip localhost data
set skip on lo

#Scrub data - complete frames
scrub in all

#allow dynamic virtual if configuration
nat-anchor "virtual/*"
rdr-anchor "virtual/*"

#block return and allow out
block return in all
pass out quick all

#allow ping
pass in quick inet proto icmp all icmp-type {echoreq, unreach}

#allow ssh
pass in quick proto tcp to port ssh

#allow comfiguration for bhyve/jail networking
anchor virtual
load anchor virtual from "/etc/pf.conf.d/virtual

EOF
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


#Call main Function manually - if not need uncomment - Lib Function
main "$@";
