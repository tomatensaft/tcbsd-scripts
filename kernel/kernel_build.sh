#!/bin/sh
#SPDX-License-Identifier: MIT

#Edit kernel config file
#cd  /usr/src/sys/`uname -m`/conf
#cp GENERIC MYKERNEL

#Checl if source exists
if [ -d "/usr/srv" ]; then
  echo "installing config files in ${DIR}..."
fi

#Backup Kernel
cp -a /boot/kernel /boot/kernel.good

#Build Kernerl
cd /usr/src/sys/`uname -m`/conf
cp GENERIC NAN_FIRST_BUILD
cd /usr/src
make buildkernel KERNCONF="NAN_FIRST_BUILD"
make installkernel KERNCONF="NAN_FIRST_BUILD"
reboot
uname -a

#Move Kernel
mv /boot/kernel.old /boot/kernel.good   
mv /boot/kernel /boot/kernel.bad
mv /boot/kernel.good /boot/kernel