#!/bin/bash

if [[ -z "${1}" ]]; then
   echo "Missing arguments"
   exit 1
fi

/storage/bin/pwrite.sh "/storage/chroot-commands.pipe" "systemctl ${*}"
