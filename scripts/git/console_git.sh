#!/bin/sh
#SPDX-License-Identifier: MIT

#Script for Git Interaction
#Usage git console [option] [comment]

#Replave static parameters

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

#Check number of args
check_args $# 1

#Print Header
print_header 'small git commandline helper'

#Parameter/Arguments
option=$1
repository="ShellRepository"
working_dir="/tmp/git"
#Pull Options
#git config pull.ff only 
git config pull.rebase true 

#Main Functions
main() {

    #Check Inputargs
    case $option in

        --test)
            log -info "test Command for debugging $0"
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

#https://lerneprogrammieren.de/git/

#Repo pull
repo_pull() {

    log -info "git pull ${repository} - NOT IMPLEMENTET"
}

#Repo pull
repo_changes() {

    git status
    git config -global -list
}

#Repo pull
repo_clone() {

    git clone https://github.com/tomatensaft/ShellRepository.git $working_dir
}

#Commit and Push
repo_push() {

    #user
    printf "git username: "
    read username

    #token - maybe file
    echo "git token: "
    read token

    #check via curl
    curl "https://api.github.com/repos/${username}/${repository}.git"


    if [ $? -eq 0 ]; then
        cd $repository
        git status #unstaged files
        git remote set-url origin https://${token}@github.com/${username}/${repository}.git
        if [ "$(git status --porcelain)" ]; then
            printf "please Commit: "
            read committment
            git add .
            git commit -m "$committment"
            git push
            log -info "git committed and pushed"
        else
            git push
            log -info "git Pushed"

        fi

        if [ "$(git status --porcelain)" ]; then
            log -info "no files to push"
        fi
    else
        log -ERR "repo ${repository} not found"
    fi
}

#Check requirements
check_requirements() {

    #Check Root
    check_root

    #Check Command
    if command -v ls >/dev/null 2>&1 ; then
        log -info "program Found"
    else
        log -info "program Not Found"
        cleanup_exit ERR
    fi 
}

#Call main Function manually - if not need uncomment
main "$@"; exit