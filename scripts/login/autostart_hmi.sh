#!/bin/sh
#SPDX-License-Identifier: MIT

printf "\n################################################\n"
printf "\n#             startup options                  #\n"
printf "\n################################################\n\n\n"
printf "(h)mi webclient (standard)\n\n"
printf "(s)ervice mode - kde\n\n"
printf "(c)console\n\n\n"

read -t 8 -p "choose startoption and hit ENTER [h,s,c]: " startOption
: "${startOption:=h}"

case $startOption in
        h)
                printf "starting standalone browser chromium\n"
			echo "exec /usr/local/bin/chrome" > ~/.xinitrc
			startx
                ;;
        s)
                printf "starting servicemode - kde\n"
			echo "exec ck-launch-session startplasma-x11" > ~/.xinitrc
			startx
                ;;
        c)
                printf "starting console\n"
				clear
                ;;
        *)
                printf "invalid option!\n\n"
                ;;
esac
