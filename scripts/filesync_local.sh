#!/bin/sh
#SPDX-License-Identifier: MIT

printf "\n-----------sync to local machine for debug----------\n"
printf "copy data\n"

#Copy with scp
#scp -rp /home/tec/repos/tcbsd-scripts Administrator@192.168.1.150:/home/Administrator/tcbsd-scripts

#Copy with rsync
rsync -au -I /home/tec/repos/tcbsd-scripts Administrator@192.168.1.187:/home/Administrator

printf "\nfinish copy\n".