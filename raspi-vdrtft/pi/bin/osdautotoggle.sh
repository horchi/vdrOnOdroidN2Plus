#!/bin/bash

if [[ -f ~/.config/default/browser ]]; then
   source ~/.config/default/browser
fi

current=""

while true; do
   ODROID_VDR_RUN=0
   LOCAL_VDR_RUN=0

   systemctl --user is-active --quiet vdr && LOCAL_VDR_RUN=1
   systemctl --user is-active --quiet musicosd && current="musicosd"
   systemctl --user is-active --quiet vdrosd && current="vdrosd"

   if svdrpsend -d ${ODROID_VDR_HOST} CHAN >/dev/null 2>&1; then
      ODROID_VDR_RUN=1
   fi

#   ping -W 1 -c 1 ${ODROID_VDR_HOST} > /dev/null

#   if [ ${?} == "0" ]; then
#      ODROID_VDR_RUN=1
#   fi

   if [[ "${current}" == "vdrosd" ]]; then

      if [[ ${ODROID_VDR_RUN} == 0 &&  ${ODROID_VDR_RUN} == 0 ]]; then
         ~/bin/toggle.sh musicosd
      fi
   fi

   sleep 60
done

echo "exiting"
