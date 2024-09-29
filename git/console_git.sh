#!/bin/sh
#spdx-license-identifier: mit

#set -x

# set absolute path of root app for global use - relative path from this point
# ${pwd%/*} -> one folder up / ${pwd%/*/*} -> two folders up
# adjust script application path/folder
# configuration file will be the same main name as the shell script - but only with .conf extension

# option
option=${1}

# script parameter
root_path="${pwd%/*}/tomatoe-lib/" # "${pwd%/*}/tomatoe-lib/"
main_lib="${root_path}/main_lib.sh"
app_name="${0##*/}"
app_fullname="${pwd}/${app_name}"
#conf_default="$(echo "$app_fullname" | sed 's/.\{2\}$/conf/')"
conf_default="${pwd%/*}/tomatoe_lib.conf"
conf_custom=${2:-"none"}


# header of parameter
printf "\nparameters load - $(date +%y-%m-%d-%h-%m-%s)\n"
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

# check number of args
check_args $# 1

# print header
print_header 'small git commandline helper'

# parameter/arguments
option=$1
repository="shellrepository"
working_dir="/tmp/git"
#pull options
#git config pull.ff only 
git config pull.rebase true 

# main functions
main() {

    # check inputargs
    case $option in

        --test)
            log -info "test command for debugging $0"
            ;;

        --pull)
            log -info "git pull ${repository}"
            repo_pull
            ;;

        --changes)
            log -info "git changes ${repository}"
            repo_changes
            ;;

        --push)
            log -info "git push ${repository}"
            repo_push
            ;;  

        --clone)
            log -info "git clone ${repository}"
            repo_clone
            ;;

        --help | --info | *)
                usage   "\-\-test:                  test command" \
                        "\-\-pull:                  pull repo - download" \
                        "\-\-push:                  push repo - upload" \
                        "\-\-changes:               list changes" \
                        "\-\-clone:                 clone repo" \
                        "\-\-help:                  help"
                ;;
    esac

}

# https://lerneprogrammieren.de/git/

# repo pull
repo_pull() {

    log -info "git pull ${repository} - not implementet"
}

# repo pull
repo_changes() {

    git status
    git config -global -list
}

# repo pull
repo_clone() {

    git clone https://github.com/tomatensaft/tomatoe-lib.git $working_dir
}

# commit and push
repo_push() {

    # user
    printf "git username: "
    read username

    # token - maybe file
    echo "git token: "
    read token

    # check via curl
    curl "https://api.github.com/repos/${username}/${repository}.git"


    if [ $? -eq 0 ]; then
        cd $repository
        git status #unstaged files
        git remote set-url origin https://${token}@github.com/${username}/${repository}.git
        if [ "$(git status --porcelain)" ]; then
            printf "please commit: "
            read committment
            git add .
            git commit -m "$committment"
            git push
            log -info "git committed and pushed"
        else
            git push
            log -info "git pushed"

        fi

        if [ "$(git status --porcelain)" ]; then
            log -info "no files to push"
        fi
    else
        log -err "repo ${repository} not found"
    fi
}

# check requirements
check_requirements() {

    # check root
    check_root

    # check command
    if command -v ls >/dev/null 2>&1 ; then
        log -info "program found"
    else
        log -info "program not found"
        cleanup_exit err
    fi 
}

# call main function manually - if not need uncomment
main "$@"; exit
