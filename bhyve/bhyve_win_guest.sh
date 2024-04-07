#!/bin/sh
#SPDX-License-Identifier: MIT

#set -x

# set absolute path of root app for global use - relative path from this point
# ${PWD%/*} -> one folder up / ${PWD%/*/*} -> two folders up 
SCRIPT_ROOT_PATH="${PWD%/*}"

# test include external libs from tcbsd submodule
if [ -f  ${SCRIPT_ROOT_PATH}/tcbsd_lib.sh ]; then
    . ${SCRIPT_ROOT_PATH}/tcbsd_lib.sh
else
    printf "$0: tcbsd external libs not found - exit.\n"
    exit 1
fi

doas bhyve -c 2 -m 2G \
-A -H -S -w \
-l bootrom,/usr/local/share/uefi-firmware/BHYVE_BHF_UEFI.fd \
-s 0:0,hostbridge \
-s 1:0,ahci-hd,/home/Administrator/windows10.img \
-s 7,passthru,0/2/0,igd \
-s 9:0,virtio-net,tap0 \
-s 10:0,ahci-cd,/home/Administrator/virtio-win-0.1.217.iso  \
-s 29,fbuf,tcp=0.0.0.0:5900,w=1024,h=768,wait \
-s 30,xhci,tablet \
-s 31:0,lpc \
win10-vm