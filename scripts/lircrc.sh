#!/bin/bash

if [[ -f /storage/.config/default/vdrtft ]]; then
   source /storage/.config/default/vdrtft
fi

PIP_RUN=0

if svdrpsend -d ${TFT_HOST} CHAN >/dev/null 2>&1; then
   PIP_RUN=1
fi

# echo "Debug: PIP_RUN=${PIP_RUN} at ${TFT_HOST}"

if [ "$1" == "WUP" ]; then
   if [ ${PIP_RUN} == 1 ]; then
      /usr/bin/svdrpsend -d ${TFT_HOST} CHAN "+"
   else
      /usr/bin/svdrpsend PLUG osd2web NEXT
   fi
fi

if [ "$1" == "WDOWN" ]; then
   if [ ${PIP_RUN} == 1 ]; then
      /usr/bin/svdrpsend -d ${TFT_HOST} CHAN "-"
   else
      /usr/bin/svdrpsend PLUG osd2web PREV
   fi
fi
