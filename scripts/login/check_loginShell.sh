#!/bin/sh
#PDX-License-Identifier: MIT

printf "\n################################################\n"
printf "\n#             check login shell                #\n"
printf "\n################################################\n\n\n"

printf "\n$(tty)\n"

#Check User ant tty
if [ $(tty) = "/dev/ttyv0" ] && [ "$USER" = "Administrator" ]
then
        printf "\nexecute autostart file\n"
        ./autostart.sh
else
	printf "\nlogging in into an interactive shell - no autostart\n"	
fi