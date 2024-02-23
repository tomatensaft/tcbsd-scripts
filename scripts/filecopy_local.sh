#!/bin/sh
#SPDX-License-Identifier: MIT

#Copy git repo to local machine
repo_name="tcbsd-scripts"

printf "\n\ncopy ${repo_name} to local machine\\
------------------------------------\n"

#check if repo exist
if [ -f  ${repo_name}.tar.gz ]; then
    printf "repo found - remove archive\n\n"
    rm ${repo_name}.tar.gz
else
    printf "no repo found\n\n"    
fi

#check if folder  exist
if [ -d  ./${repo_name}-main ]; then
    printf "folder found - remove folder\n\n"
    rm -r ${repo_name}-main
else
    printf "no folder found\n\n"    
fi

#Copy repo
curl -Lo tcbsd-scripts.tar.gz https://github.com/tomatensaft/${repo_name}/archive/main.tar.gz

#extract Repo
tar -xzf ${repo_name}.tar.gz

#remove tar.gz file
rm ${repo_name}.tar.gz

#Make shell script executeable
chmod -R 755 ${repo_name}-main