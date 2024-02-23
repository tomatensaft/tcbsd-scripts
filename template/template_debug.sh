#!/bin/sh
#SPDX-License-Identifier: MIT


#Template for debugging

#Include extenal scripts
if [ -f  ../../lib/shared_lib.sh ]; then
    . ../../lib/shared_lib.sh
elif [ -f  ../lib/shared_lib.sh ]; then
    . ../lib/shared_lib.sh
else
    log -info "$0: shared lib not found."
    cleanup_exit ERR 
fi

#Print Header
print_header 'debug started'

#Check Existing Jail
jail_name="test"
    if ! check_jail $jail_name; then
        log -info "$0: jail ${jail_name} not found."
    else
        log -info "$0: jail ${jail_name} allready exists."
    fi

#Check VBox device
if  ! check_vbox_device; then
    log -info "$0: vbox not found."
else
    log -info "$0: vbox found."
fi

#Test EOF
log -info "$0: Test EOF"
    cat << EOF >> /tmp/pf.conf
    Test Contentdf
EOF

#Test read file
log -info "$0: Test read"
jail_id="$(cat /tmp/jail_id)"
echo $jail_id
echo $((jail_id+1)) > /tmp/jail_id


#Find Rc Entry
log -info "$0: Test rc.conf"
if  grep jail_enable /etc/rc.conf ; then
    echo found
else
    echo not found
fi

#Test Parameter
log -info "$0: Test param"
param1="Test"
param2="OK"

#Include extenal scripts
if [ -f param.conf ]; then
    log -info "$0: parameter file found -use parameter."
    . param.conf
else
    log -info "$0: no parameter file found."
fi

echo $param1
echo $param2


test_parameter() {

    #echo $@
    #echo $1
    #echo $2

    for arg in "$@"
    do
    echo "$arg"
    done

}

log -info "$0: Init Parameters"

test_parameter ABS ABS ASA

#Find Rc Entry
log -info "$0: Test zfs find"
if  zfs list | grep zroot/jail ; then
    echo found
else
    echo not found
fi

touch $HOME/test

#Adjust infuxd config file
        sed  "" "s/^\[http\]/\n\\
        #custom configuration\\
        enabled=true""\\
        bind-address=:8086""\n/" /jails/influxdb//usr/local/etc/influxd.conf

JAILS="$(jls | awk 'NR>1 { print $1 }')"

for JAIL in $JAILS; do
    jexec $JAIL uname -a
done

test=""

if [ -z "$test"]; then
    echo empty
else
    echo not empty
fi

  log -info "Test ZFS ---------"



  if zfs list | grep "zroot/jails"; then
        log -info "zfs dataset exists for jails"
    else
        log -info "create zfs dataset for jails"
        
    fi

    #check file exists allready
    if [ -f "/jails/config/pf.jail_wireguard.conf" ]; then
        log -info "jail wireguardpacketfilter config allready found"
    else
        log -info "jail wireguard packetfilter config not found - creating"
    fi
log -info "check jail"
#check_jail wireguard ERR



#if ! [ "$(ping -c1 8.84.84.8)" ]; then
#    log -info "No Connection"
#else
#    log -info "Connection OK"
#fi


#set_vbox_defaults

switch_tcbsd_repo freebsd
switch_tcbsd_repo bhf
