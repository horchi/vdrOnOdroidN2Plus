#!/bin/bash

if [[ -f ~/.config/default/browser ]]; then
   source ~/.config/default/browser
fi

date >> ${LOG}

forceMusicOsd=0
forceVdrOsd=0

# check parameter

if [[ -n "${1}" ]] && [[ "${1}" = "musicosd" ]] ; then
   forceMusicOsd=1
elif [[ -n "${1}" ]] && [[ "${1}" = "vdrosd" ]] ; then
   forceVdrOsd=1
fi

# check month for snow and santa

month=$(date +%-m)  # do not pad month number with leading zero

if [[ "${SHOW_SNOW}" == "YES" ]]; then
   [[ $month -ge 11 || $month -le 2 ]] && URL_VDR_OSD+='&xsnow=1'
fi

if [[ "${SHOW_SANTA}" == "YES" ]]; then
   [[ $month -eq 12 ]] && URL_VDR_OSD+='&santa=1'
fi

ODROID_VDR_RUN=0

if svdrpsend -d ${ODROID_VDR_HOST} CHAN >/dev/null 2>&1; then
   ODROID_VDR_RUN=1
fi

ping -W 1 -c 1 ${ODROID_VDR_HOST} > /dev/null

if [ ${?} == "0" ]; then
   ODROID_VDR_RUN=1
fi

while [ 1 ]; do
  PID=`pidof openbox`

  if [ -n "${PID}" ]; then
    echo "  openbox running with pid ${PID}" >> ${LOG}
    break
  fi

  if [ $SECONDS -gt 120 ]; then
    exit 1
  fi

  echo "  waiting for openbox .." >> ${LOG}
  sleep 0.5
done

URL=${URL_MUSIC}

echo "  ODROID_VDR_RUN: ${ODROID_VDR_RUN}; forceMusicOsd: ${forceMusicOsd}" >> ${LOG}

if [[ "${forceVdrOsd}" == 1 ]]; then
   URL=${URL_VDR_OSD}
elif [[ "${forceMusicOsd}" == 1 ]]; then
   URL=${URL_MUSIC}
elif [[ ${ODROID_VDR_RUN} == 1 ]]; then
   URL=${URL_VDR_OSD}
fi

sleep 1
echo "  starting ${BROWSER} with ${BROWSER_OPTIONS} ${URL} / ${DISPLAY}" >> ${LOG}

if [[ "${BROWSER}" =~ "chromium-browser" ]]; then
   echo "  cleanup for ${BROWSER}" >> ${LOG}
   sed -i 's/"exited_cleanly":false/"exited_cleanly":true/' ~/.config/chromium/'Local State'
   sed -i 's/"exited_cleanly":false/"exited_cleanly":true/; s/"exit_type":"[^"]\+"/"exit_type":"Normal"/' ~/.config/chromium/Default/Preferences
fi

exec env DISPLAY=${DISPLAY} ${BROWSER} ${BROWSER_OPTIONS} "${URL}"
