#!/bin/bash

if [[ -f /storage/.config/default/vdrtft ]]; then
   source /storage/.config/default/vdrtft
fi

if [[ -n ${TFT_HOST} ]]; then

   if [[ "${TFT_SHUTDOWN}" == "yes" ]]; then
      ssh root@${TFT_HOST} shutdown -h now
   elif [[ "${TFT_SHUTDOWN}" == "on-vdrosd" ]]; then
      ssh pi@${TFT_HOST} systemctl --user is-active --quiet status vdrosd
      if [ ${?} == "0" ]; then
         ssh root@${TFT_HOST} shutdown -h now
      fi
   fi

fi
