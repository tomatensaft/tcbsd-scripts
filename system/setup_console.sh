#!/bin/sh
#SPDX-License-Identifier: MIT

#set -x

# set absolute path of root app for global use - relative path from this point
# ${PWD%/*} -> one folder up / ${PWD%/*/*} -> two folders up 
SCRIPT_ROOT_PATH="${PWD%/*}/posix-lib-utils"

# test include external libs from tcbsd submodule
if [ -f  ${SCRIPT_ROOT_PATH}/tcbsd_lib.sh ]; then
    . ${SCRIPT_ROOT_PATH}/tcbsd_lib.sh
else
    printf "$0: tcbsd external libs not found - exit.\n"
    exit 1
fi

#Print Header
print_header 'setup console'

#Check number of args
check_args $# 1

#Parameter/Arguments
option=$1
username=${2:-$(users)} #whoami

#Main Functions
main() {

    #Check Inputargs
    case $option in
            --test)
                log -info "test Command for debugging $0"
                ;;

            --doas_pwd)
                log -info "set doas without password"
                check_requirements
                set_doas_pwd
                ;;

            --kbd_layout)
                check_requirements
                log -info "set german keyboard layout"
                set_kbd_layout
                ;;


            --kbd_shortcuts)
                check_requirements
                log -info "reactivate keyboard shortcuts"
                set_kbd_shortcuts
                ;;

            --sshd_weaken)
                check_requirements
                log -info "weaken sshd server"
                set_sshd_weaken
                ;;    

            --set_autologon)
                check_requirements
                log -info "set autologon"
                set_autologon
                ;;    

            --tools_tcbsd)
                check_requirements
                log -info "install tools tcbsd source"
                install_tools_tcbsd
                ;;   

            --tools_freebsd)
                check_requirements
                log -info "install tools freebsd source"
                install_tools_freebsd
                ;;      

            --help | --info | *)
                usage   "\-\-test:                      test command" \
                        "\-\-doas_pwd [user]:           set doas without password" \
                        "\-\-kbd_layout:                set keyboard layout" \
                        "\-\-kbd_shortcuts:             set keyboard shortcuts" \
                        "\-\-sshd_weaken:               set sshd weaken params" \
                        "\-\-set_autologon [user]:      set autologon" \
                        "\-\-tools_freebsd:             install tools from freebsd source" \
                        "\-\-tools_tcbsd:               install tools from tcbsd source" \
                        "\-\-help:                      help" 
                ;;
    esac
}


#Check requirements
check_requirements() {

    #Check Root
    check_root

    #Check Command
    if command -v ls >/dev/null 2>&1 ; then
        log -info "program found"
    else
        log -info "program not found"
        cleanup_exit ERR
    fi 
}




#Set sshd weaken
set_sshd_weaken() {

    log -info "set sshd.conf parameters"
    # weaken sshd_config to allow Microsoft ssh tools to connect ...
    sed -i -e 's/^Ciphers/#Ciphers/g' /etc/ssh/sshd_config
    sed -i -e 's/^HostKeyAlgorithms/#HostKeyAlgorithms/g' /etc/ssh/sshd_config
    sed -i -e 's/^KexAlgorithms/#KexAlgorithms/g' /etc/ssh/sshd_config
    sed -i -e 's/^MACs/#MACs/g' /etc/ssh/sshd_config
    sed -i -e 's/#PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config

}

#Set keyboard shortcuts
set_kbd_shortcuts() {

    log -info "set sysctl values"
    # reenable keyboard shortcuts f.e. "CTRL+ALT+DEL"
    #sysctl kern.vt.kbd_debug=1
    #sysctl kern.vt.kbd_halt=1
    #sysctl kern.vt.kbd_panic=1
    #sysctl kern.vt.kbd_poweroff=1
    #sysctl kern.vt.kbd_reboot=1

    # make the above changes permanent
    add_or_replace_in /etc/sysctl.conf 'kern.vt.kbd_debug=' '"1"'
    add_or_replace_in /etc/sysctl.conf 'kern.vt.kbd_halt=' '"1"'
    add_or_replace_in /etc/sysctl.conf 'kern.vt.kbd_panic=' '"1"'
    add_or_replace_in /etc/sysctl.conf 'kern.vt.kbd_poweroff=' '"1"'
    add_or_replace_in /etc/sysctl.conf 'kern.vt.kbd_reboot=' '"1"'

}

#Set keyboard layou
set_kbd_layout() {

    log -info "write rc.conf"
    add_or_replace_in /etc/rc.conf 'keymap=' '"de.noacc.kbd"'
    kbdcontrol -l de.noacc.kbd
}

#Set doas withouf password
set_doas_pwd() {

    log -info "write doas.conf for ${username}"
    # Allow Administrator to use doas without password
    log -info "insert nopass for user ${username}"
    add_or_replace_in /usr/local/etc/doas.conf "permit nopass ${username}" ""
}

#Set autologon
set_autologon() {

    log -info "write gettytab for user ${username}"
    #Adjust Username - Append to Gettytab
    $ cat << EOF >> /etc/gettytab
autoLogin.Pc:\
    :ht:np:sp#9600:al=${username}
EOF

    #Change terminal login mode
    add_or_replace_in /etc/ttys 'ttyv0' '"/usr/libexec/getty autoLogin.Pc"   xterm on  secure'


}

#install tools tsbsd source
install_tools_tcbsd() {

    log -info "install tools - tcbsd"
    env ASSUME_ALWAYS_YES=YES pkg install \
        bash \
        fusefs-sshfs \
        git \
        htop \
        jq \
        nmap \
        tmux \
        doas \
        rsync \
        vim \
        wget

}

#install tools freebsd source
install_tools_freebsd() {

    log -info "install tools - freebsd"
    env ASSUME_ALWAYS_YES=YES pkg install \
        fusefs-ntfs
}

#Call main Function manually - if not need uncomment
main "$@"; exit