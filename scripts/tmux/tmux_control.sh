#!/bin/sh
#SPDX-License-Identifier: MIT

#tmus control

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


