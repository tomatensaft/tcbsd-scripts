#!/bin/sh
#spdx-license-identifier: mit
#not finished - not tested

#short info

#include extenal scripts
if [ -f  ../../lib/shared_lib.sh ]; then
    . ../../lib/shared_lib.sh
elif [ -f  ../lib/shared_lib.sh ]; then
    . ../lib/shared_lib.sh
else
    log -info "$0: shared lib not found."
    cleanup_exit err 
fi


set -u

dialog_msgbox() {
	local _msg="${1}"
	local _title="${2-"error"}"
	local _backtitle="${3-"${dialog_backtitle-""}"}"
	local _vsize="${4-"0"}"
	local _hsize="${5-"0"}"
	${dialog-dialog} -title "${_title}" -backtitle "${_backtitle}" -msgbox "${_msg}" "${_vsize}" "${_hsize}"
}

dialog_msgbox test titeltest backtitel 300 300