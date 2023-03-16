#!/bin/bash

if [[ -f /storage/.config/default/vdrtft ]]; then
   source /storage/.config/default/vdrtft
fi

if [[ -n ${TFT_HOST} ]]; then
   /usr/bin/ssh pi@${TFT_HOST} /home/pi/bin/toggle.sh vdrosd force
fi

exit 0
