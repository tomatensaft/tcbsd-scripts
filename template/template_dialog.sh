#!/bin/sh
#SPDX-License-Identifier: MIT
#Not finished - Not tested

#Short Info

#Include extenal scripts
if [ -f  ../../lib/shared_lib.sh ]; then
    . ../../lib/shared_lib.sh
elif [ -f  ../lib/shared_lib.sh ]; then
    . ../lib/shared_lib.sh
else
    log -info "$0: shared lib not found."
    cleanup_exit ERR 
fi


set -u

dialog_msgbox() {
	local _msg="${1}"
	local _title="${2-"Error"}"
	local _backtitle="${3-"${DIALOG_BACKTITLE-""}"}"
	local _vsize="${4-"0"}"
	local _hsize="${5-"0"}"
	${DIALOG-dialog} -title "${_title}" -backtitle "${_backtitle}" -msgbox "${_msg}" "${_vsize}" "${_hsize}"
}

dialog_msgbox Test TitelTest backtitel 300 300