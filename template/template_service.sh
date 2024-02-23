#!/bin/sh
#
# PROVIDE: templateservice
# REQUIRE: DAEMON sshd netif
# KEYWORD: shutdown

. /etc/rc.subr

name=templateservice
rcvar=templateservice_enable

command="/usr/local/sbin/anyapplication" #replace

load_rc_config $name

#
# DO NOT CHANGE THESE DEFAULT VALUES HERE
# SET THEM IN THE /etc/rc.conf FILE
#
templateservice_enable=${myutility_enable-"NO"}
pidfile=${templateservice_pidfile-"/var/run/templateservice.pid"}

run_rc_command "$1"