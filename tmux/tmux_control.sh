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
print_header 'tmux control'

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

            --start)
                check_requirements
                log -info "start tmux control"
                start_tmux
                ;;


            --delete)
                log -info "delete"
                ;;

            --help | --info | *)
                usage   "\-\-test:      test command" \
                        "\-\-start:     start tmux" \
                        "\-\-help:      help" 
                ;;
    esac
}


#Check requirements
check_requirements() {
    #Check Root
    #check_root

    #Check Command
    if command -v ls >/dev/null 2>&1 ; then
        log -info "program found"
    else
        log -info "program not found"
        cleanup_exit ERR
    fi

    #Check Grub Uefi Loader
    if pkg info tmux | grep tmux; then
        log -info "tmux found"
    else
        pkg install -y tmux 
    fi


}


#Start Tmux
start_tmux() {
    log -info "program found"

    tmux new-session \; \
    send-keys 'tail -f /var/log/messages' C-m \; \
    split-window -v -p 75 \; \
    split-window -h -p 25 \; \
    send-keys 'top -SPT' C-m \; \
    select-pane -t 1 \; \
    set status-left "#(~/tmux_status.sh tc) "\; \
    set status-right-length 120 \; \
    set status-right "#(~/tmux_status.sh net) ";

}

#Call main Function manually - if not need uncomment
main "$@"; exit


