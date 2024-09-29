#!/bin/sh
#SPDX-License-Identifier: MIT

#set -x

# set absolute path of root app for global use - relative path from this point
# ${PWD%/*} -> one folder up / ${PWD%/*/*} -> two folders up
# adjust script application path/folder
# configuration file will be the same main name as the shell script - but only with .conf extension

# option
option=${1}

# script parameter
root_path="${PWD%/*}/tomatoe-lib/" # "${PWD%/*}/tomatoe-lib/"
main_lib="${root_path}/main_lib.sh"
app_name="${0##*/}"
app_fullname="${PWD}/${app_name}"
#conf_default="$(echo "$app_fullname" | sed 's/.\{2\}$/conf/')"
conf_default="${PWD%/*}/tomatoe_lib.conf"
conf_custom=${2:-"none"}


# header of parameter
printf "\nparameters load - $(date +%Y-%m-%d-%H-%M-%S)\n"
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

#Print Header
print_header 'setup NFS server'

#Print usage information
usage   "$0 [nfs folder]:    optional parameter" 

#Optional Parameter
nfs_folder=${1:-"/usr/home/Administrator"}

#Check Root
check_root

#set rc.conf services
log -info "write rc.conf parameter"
add_or_replace_in /etc/rc.conf 'nfs_server_enable' '"YES"'
add_or_replace_in /etc/rc.conf 'nfsv4_server_enable' '"YES"'
add_or_replace_in /etc/rc.conf 'nfsuserd_enable=' '"YES"'

#set port
add_or_replace_in /etc/rc.conf 'mountd_flags=' '"-p 831"'

#set firewall
log -info "write pf.conf parameter"
add_or_replace_in /etc/pf.conf "pass in quick proto tcp to port 111" ""
add_or_replace_in /etc/pf.conf "pass in quick proto tcp to port 831" ""
add_or_replace_in /etc/pf.conf "pass in quick proto tcp to port 2049" ""

#Export Home directory
log -info "write exports"
if [ -f "/etc/resolv.conf" ]; then
    log -info "resolv.conf found"
else
    touch /etc/resolf.conf           
fi

#add parameter
add_or_replace_in /etc/exports "V4: /" ""
add_or_replace_in /etc/exports ${nfs_folder}

#Reload
/etc/rc.d/mountd onereload

#Mount nfs share - client side
#mount -t nfs <nfs-server-ip>:/usr/home/Administrator /mnt

#Show mountes
#showmount -e

#Last info
log -info "setup finished - nfs server"
