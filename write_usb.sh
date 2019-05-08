#!/bin/bash


DEFAULT_ISO="/mnt/livecdcreator/fc29_mbp14_mate.iso"

USB="usb-TOSHIBA_TOSHIBA_USB_DRV_0708544A1F20BD47-0:0"

if [[ -z "$1" ]]; then
  ISO=$DEFAULT_ISO
fi

OUT_DEVICE=
dd if="${ISO}" of="${OUT_DEVICE}" bs=4M status=progress
"/dev/disk/by-id/${USB}"
sync
eject 


