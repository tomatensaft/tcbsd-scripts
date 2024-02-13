#!/bin/sh
#spdx-license-identifier: mit

printf "\n-----------sync to local machine for debug----------\n"
printf "copy data\n"

#copy with scp
#scp -rp /home/tec/repos/tcbsd-scripts administrator@192.168.1.150:/home/administrator/tcbsd-scripts

#copy with rsync
rsync -au /home/tec/repos/tcbsd-scripts administrator@192.168.1.150:/home/administrator

printf "\nfinish copy\n".