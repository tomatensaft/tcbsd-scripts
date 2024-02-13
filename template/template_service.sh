#!/bin/sh
#
# provide: templateservice
# require: daemon sshd netif
# keyword: shutdown

. /etc/rc.subr

name=templateservice
rcvar=templateservice_enable

command="/usr/local/sbin/anyapplication" #replace

load_rc_config $name

#
# do not change these default values here
# set them in the /etc/rc.conf file
#
templateservice_enable=${myutility_enable-"no"}
pidfile=${templateservice_pidfile-"/var/run/templateservice.pid"}

run_rc_command "$1"