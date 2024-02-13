#!/bin/sh
#spdx-license-identifier: mit


#template for debugging

#include extenal scripts
if [ -f  ../../lib/shared_lib.sh ]; then
    . ../../lib/shared_lib.sh
elif [ -f  ../lib/shared_lib.sh ]; then
    . ../lib/shared_lib.sh
else
    log -info "$0: shared lib not found."
    cleanup_exit err 
fi

#print header
print_header 'debug started'

#check existing jail
jail_name="test"
    if ! check_jail $jail_name; then
        log -info "$0: jail ${jail_name} not found."
    else
        log -info "$0: jail ${jail_name} allready exists."
    fi

#check vbox device
if  ! check_vbox_device; then
    log -info "$0: vbox not found."
else
    log -info "$0: vbox found."
fi

#test eof
log -info "$0: test eof"
    cat << eof >> /tmp/pf.conf
    test contentdf
eof

#test read file
log -info "$0: test read"
jail_id="$(cat /tmp/jail_id)"
echo $jail_id
echo $((jail_id+1)) > /tmp/jail_id


#find rc entry
log -info "$0: test rc.conf"
if  grep jail_enable /etc/rc.conf ; then
    echo found
else
    echo not found
fi

#test parameter
log -info "$0: test param"
param1="test"
param2="ok"

#include extenal scripts
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

log -info "$0: init parameters"

test_parameter abs abs asa

#find rc entry
log -info "$0: test zfs find"
if  zfs list | grep zroot/jail ; then
    echo found
else
    echo not found
fi

touch $home/test

#adjust infuxd config file
        sed  "" "s/^\[http\]/\n\\
        #custom configuration\\
        enabled=true""\\
        bind-address=:8086""\n/" /jails/influxdb//usr/local/etc/influxd.conf

jails="$(jls | awk 'nr>1 { print $1 }')"

for jail in $jails; do
    jexec $jail uname -a
done

test=""

if [ -z "$test"]; then
    echo empty
else
    echo not empty
fi

  log -info "test zfs ---------"



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
#check_jail wireguard err



#if ! [ "$(ping -c1 8.84.84.8)" ]; then
#    log -info "no connection"
#else
#    log -info "connection ok"
#fi


#set_vbox_defaults

switch_tcbsd_repo freebsd
switch_tcbsd_repo bhf
