#!/bin/sh
#SPDX-License-Identifier: MIT
#Not finished - Not tested

#Small Telegram Example

#Print Header
printf 'Telegram Example\n'

#Parameter/Arguments
message=$1
bottoken="token_template"
chatid="chatid_template"


#################################### REMOVE WHEN NOT NEED#############################
######only for testing with repo and private credentials

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
print_header 'send teleram message with repo'

#Check number of args
check_args $# 1

#Parameter/Arguments
config_file=${2:-"template_file"}

load_config ${config_file}
log -info "init setup ${setup_name} from configfile"

#################################### REMOVE WHEN NOT NEED#############################


#check if curl command exists
if command -v curl >/dev/null 2>&1 ; then
	printf "curl found\n"
else
	printf "curl not found - please install\n"
        exit 0
fi 

#check if argument exists
if [ $# -lt 1 ]; then
    printf "Usage: $0 EnterMessageTestHere\n"
    exit 0
fi

#check if message not null
if [ -z $1 ]; then
    printf "No Message\n"
    exit 0
fi

#execute command
printf "start sending\n"
curl "https://api.telegram.org/bot${bottoken}/sendMessage?chat_id=${chatid}&text=${message}"
printf "\nsending finished\n"