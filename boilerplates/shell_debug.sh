#!/bin/sh
# SPDX-License-Identifier: MIT

# set -x

# set absolute path of root app for global use - relative path from this point
SCRIPT_ROOT_PATH="../"

# include external libs from git submodule
if [ -f  ${SCRIPT_ROOT_PATH}/posix-lib-utils/tcbsd_lib.sh ]; then
    . ${SCRIPT_ROOT_PATH}/posix-lib-utils/tcbsd_lib.sh
else
    printf "$0: external libs not found - exit.\n"
    exit 1
fi

#print header
print_header 'debug template'