#!/bin/sh
#spdx-license-identifier: mit

#copy git repo to local machine
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

#copy repo
curl -lo tcbsd-scripts.tar.gz https://github.com/tomatensaft/${repo_name}/archive/main.tar.gz

#extract repo
tar -xzf ${repo_name}.tar.gz

#remove tar.gz file
rm ${repo_name}.tar.gz

#make shell script executeable
chmod -r 755 ${repo_name}-main