#!/bin/sh
# SPDX-License-Identifier: MIT

set -u

#header functions
#$1 header
print_header()
{

	printf "\n################################################\n"
	printf "$1"
	printf "\n################################################\n\n"
}

#print header
print_header 'load shared lib'

#check if file exists

#find & replace
#$1 file
#$2 parameter
#$3 value
add_or_replace_in() {
	
	if grep "^$2" "$1" > /dev/null; then
		sed -i "" "s|^$2.*|$2$3|g" "$1"
	else
		echo "$2$3" >> "$1"
	fi
}

#check git client - needed for different software
#$1 exit (EXT) or return (RET)
check_git() {

	#Preconfigure ExitState
	exit_state=${1:-RET}

    if pkg info git | grep git; then
        log -info "git Found"
    else
		log -info "install git"
        pkg install -y git 
    fi

}

#Check if Jail exists
#$1 JailName
#$2 Exit (EXT) or Return (RET)
check_jail() {

	#Preconfigure ExitState
	exit_state=${2:-RET}

    if jls | grep $1; then
        log -info "jail ${1} found"
		cleanup_exit RET 0	#Allways returns 0 on success
    else
		log -info "jail ${1} not found"
		cleanup_exit $exit_state 1
        
    fi
}

#Log Message
#$1 Option
log() {

	#Check Inputargs
		case $1 in
				-info)
					printf "\nINFO [$(date +'%Y-%m-%dT%H:%M:%S')]: $2 \n"
					;;
				-header)
					printf "$2 \n"
					;;

				-error)
					printf "\nERROR [$(date +'%Y-%m-%dT%H:%M:%S')]: $2 \n"
					;;	

				-file)
					printf "\n[$(date +'%Y-%m-%dT%H:%M:%S')]: $2 \n"
					;;	

				*)
					printf "$0 Usage: -"
					printf "[info,header,error,file]\n\n"
					exit 1
					;;
		esac
}


#Usage
usage() {
	printf "\n++++++++++++ Usage / Help ++++++++++++++++\n\n"
	for help in "$@"
		do
			printf "$help\n"
		done
	printf "++++++++++++++++++++++++++++++++++++++++++\n"
    cleanup_exit ERR
}

#Cleanup & Exit
#$1 Option
#$2 Exit (EXT) or Return (RET)
cleanup_exit() {

	#Preconfigure ExitState
	exit_state=${2:-0}

    case $1 in
            OK)
                log -info "cleanup & exit state -> EXIT - OK\n"
                exit 0
                ;;

            ERR)
                log -info "cleanup & exit state -> EXIT - ERROR\n"
                exit 1
                ;;
			EXT)
                log -info "cleanup & exit state -> EXIT ${exit_state}\n"
                exit $exit_state
                ;;		
			RET)
                log -info "cleanup & exit state -> RETURN ${exit_state}\n"
                return $exit_state
                ;;	
            *)
                log -info "cleanup & exit state -> EXIT - DEFAULT\n"
                exit 1      
                ;;
    esac
}

#Check Root
#$1 Exit (EXT) or Return (RET)
check_root() {
	
	#Preconfigure ExitState
	exit_state=${1:-ERR}

    if [ $(id -u) -ne 0 ]; then
        log -info "usage: run '$0' as root."
        cleanup_exit $exit_state
    fi
}

#Check Arguements ($# Arguments / Count of Args)
#$1 Requestet Args
#$2 Actual Args
#$3 Exit (EXT) or Return (RET)
check_args() {

	#Preconfigure ExitState
	exit_state=${3:-ERR}

	if [ "$1" -lt "$2" ]; then
		log -error "number of parameters wrong. see --help."
        cleanup_exit $exit_state
	fi
}

#Check Beckhoff device
#$1 Exit (EXT) or Return (RET)
check_bhf_device() {

	#Preconfigure ExitState
	exit_state=${1:-RET}

	if uname -a | grep BHF; then
		log -info "beckhoff device found."
		cleanup_exit $exit_state 0
	else	
		log -info "no beckhoff device found."
        cleanup_exit $exit_state 1
	fi
}


#Check nic
#$1 nic interface
#$2 Exit (EXT) or Return (RET)
check_nic_device() {

	#Preconfigure ExitState
	nic=${1:-invalid}
	exit_state=${2:-RET}

	if ifconfig | grep $nic; then
		log -info "nic ${nic} device found."
		cleanup_exit $exit_state 0
	else	
		log -info "no nic ${nic} device found."
        cleanup_exit $exit_state 1
	fi
}


#Check VirtualBox device
#$1 Exit (EXT) or Return (RET)
check_vbox_device() {

	#Preconfigure ExitState
	exit_state=${1:-RET}

	if sysctl -a | grep VBOX; then
		log -info "vbox device found."
		cleanup_exit $exit_state 0
	else	
		log -info "no vbox device found."
        cleanup_exit $exit_state 1
	fi
}


#Set Vbox defaults
#Extend to CX and IPC devices
load_device_defaults() {

	if sysctl -a | grep VBOX; then
		log -info "vbox device found - set default values for virtualbox"

		log -info "set external interfaces to em0"
		net_external_if="em0"  #external for network/internet
		vpn_jail_external_if="em0" #External Jail interface for RDR

	else	
		log -info "no vbox device found - use parameterfile"
	fi
	
}


#Load Config File
#$1 configuration file
#$2 Exit (EXT) or Return (RET)
load_config() {

	#Preconfigure ExitState
	exit_state=${2:-ERR}

    #Load Parameter file
    #Define Parameters in Configfile
    if [ -f $1 ]; then
        log -info "$0: $1 parameter file found."
        . $1
    else
        log -info "$0: $1 no parameter file found."
        cleanup_exit $exit_state
    fi

}

#Check Software package
#$1 command/program
#$2 Exit (EXT) or Return (RET)
check_software_pkg() {

	#Preconfigure ExitState
	exit_state=${2:-ERR}

	#Find Command
    if command -v $1 >/dev/null 2>&1 ; then
        log -info "[ $1 ] command found"
    else
        log -info "[ $1 ] command not found"

		#Find package
		if pkg info $1 | grep $1; then
			log -info "[ $1 ] package found, but command not working"
			cleanup_exit $exit_state
		else
			log -info "[ $1 ] package installed"
			pkg install -y $1 
		fi
    fi 
}


#Switch Repot at TcBSD device
#$1 freebsd/bhf (freebsd / bhf)
#$2 Exit (EXT) or Return (RET)
switch_tcbsd_repo() {

	#Preconfigure ExitState
	exit_state=${2:-ERR}

	#tcbsd config file for official repo
	pkg_file="/usr/local/etc/pkg/repos/FreeBSD.conf"

	#check option
	if [ $1 == "bhf" ] ; then
		log -info "switch to beckoff repo"
		sed -i '' 's|yes|no|g' $pkg_file
		
		#update metadata
		pkg update

	elif [ $1 == "freebsd" ] ; then
		log -info "switch to official repo"
        sed -i '' 's|no|yes|g' $pkg_file

		#update metadata
		pkg update

	else
		log -info "repo option not found - use freebsd or bhf"
		cleanup_exit $exit_state
	fi

}