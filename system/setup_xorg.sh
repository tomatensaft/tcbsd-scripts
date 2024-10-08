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
print_header 'setup xorg'

#Check number of args
check_args $# 1

#Parameter/Arguments
option=$1
username=${2:-$(users)} #whoami

#Main Functions
main() {

    #Check Inputargs
    case ${option} in
            --test)
                log -info "test Command for debugging $0"
                ;;

            --install_chrome)
                log -info "install chrome base system"
                check_requirements
                install_chromium
                ;;

            --install_kde)
                check_requirements
                log -info "install kde base system"
                install_kde_base
                ;;


            --init_kbd)
                check_requirements
                log -info "init x keyboard"
                init_keyboard
                ;;

            --help | --info | *)
                usage   "\-\-test:                      test command" \
                        "\-\-install_chrome (user):     Install x-server and chrome standalone" \
                        "\-\-install_kde (user):        install base kde system" \
                        "\-\-init_kbd:                  init x keyboard" \
                        "\-\-help:                      help" 
                ;;
    esac
}

#Init Keyboard
init_keyboard() {

#use german keyboard layout within X
log -info "write file for german layout without x"
cat << EOF > /usr/local/etc/X11/xorg.conf.d/13-keyboard-evdev.conf

Section "InputClass"
	Identifier "KeyboardEvdev"
	MatchIsKeyboard "on"
	Option "XkbRules" "evdev"
EndSection

EOF

#use german keyboard layout
log -info "write file for german layout with x"
cat << EOF > /usr/local/etc/X11/xorg.conf.d/94-keyboard-de.conf

Section "InputClass"
	Identifier "KeyboardLayout"
	MatchIsKeyboard "on"
	Option "XkbLayout" "de"
EndSection

EOF
}

#Install Chromium
install_chromium() {

    log -info "install software"
    env ASSUME_ALWAYS_YES=YES pkg install \
        xorg \
        drm-kmod \
        webcamd \
        chromium

    log -info "add users to group"
    pw groupmod video -m ${username}
    pw groupmod wheel -m ${username}

    #use german keyboard layout within X
    log -info "write fstab"
    if grep "proc" "/etc/fstab"; then
        log -info "proc allready found"
    else
        log -info "insert proc into fstab"
        cat << EOF >> /etc/fstab
        proc           /proc       procfs  rw  0   0
EOF
    fi

    log -info "write rc.conf"
    sysrc -f /etc/rc.conf dbus_enable=YES
    sysrc -f /etc/rc.conf webcamd_enable=YES
    sysrc -f /boot/loader.conf cuse_load=YES
    sysrc -f /etc/rc.conf kld_list+=/boot/modules/i915kms.ko

    #mit addorreplace
    log -info "write xinitrc"
    echo "exec /usr/local/bin/chrome" > /home/${username}/.xinitrc

    log -info "setup finished -xorg with chromium"

}

#Install Kde Base
install_kde_base() {

    log -info "install kde base software"
    env ASSUME_ALWAYS_YES=YES pkg install \
        xorg-minimal \
        drm-kmod \
        plasma5-plasma \
        kate \
        konsole \
        tigervnc-viewer \
        dolphin \
        vscode \
        firefox \
        git-gui \
        kde-baseapps \
        snappy \
        wget \
        webcamd \
        xterm


    # configure driver, login and window manager
    log -info "add user to group"
    pw groupmod video -m ${username}
    pw groupmod wheel -m ${username}

    #use german keyboard layout within X
    log -info "write fstab"
    if grep "proc" "/etc/fstab"; then
        log -info "proc allready found"
    else
        log -info "insert proc into fstab"
        cat << EOF >> /etc/fstab
        proc           /proc       procfs  rw  0   0
EOF
    fi


    ##Adjust rc.conf
    log -info "write rc.conf"
    sysrc -f /etc/rc.conf dbus_enable=YES
    sysrc -f /etc/rc.conf webcamd_enable=YES
    sysrc -f /boot/loader.conf cuse_load=YES
    sysrc -f /etc/rc.conf kld_list+=/boot/modules/i915kms.ko

    #/boot/loader.conf ums_load="YES"

    #Insert Command for startx
    log -info "write xinitrc"
    echo "exec ck-launch-session startkde" > /home/${username}/.xinitrc

    #Last info
    log -info "setup finished -xorg kde base system"
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

#Call main Function manually - if not need uncomment
main "$@"; exit
