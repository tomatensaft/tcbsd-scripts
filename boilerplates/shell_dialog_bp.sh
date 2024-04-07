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

dialog_msgbox() {
	local _msg="${1}"
	local _title="${2-"error"}"
	local _backtitle="${3-"${DIALOG_BACKTITLE-""}"}"
	local _vsize="${4-"0"}"
	local _hsize="${5-"0"}"
	${DIALOG-dialog} -title "${_title}" -backtitle "${_backtitle}" -msgbox "${_msg}" "${_vsize}" "${_hsize}"
}

dialog_msgbox test TitelTest backtitel 300 300