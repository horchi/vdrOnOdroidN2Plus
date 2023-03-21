#!/bin/bash

if [[ -z "${1}" ]]; then
   echo "Missing arguments {restart, toggle, vdrosd, musicosd, vdr} [force]"
   exit 1
fi

force="no"
command=${1}
current=""
log="/tmp/toggle.log"

if [[ "$#" -ge 2 && "${2}" == "force" ]]; then
   force="yes"
fi

if [[ "${command}" == "restart" ]]; then
   force="yes"
fi

systemctl --user stop browser

systemctl --user is-active --quiet musicosd && current="musicosd"
systemctl --user is-active --quiet vdrosd && current="vdrosd"
systemctl is-active --quiet vdr && current="vdr"

echo "------------------------------" >> ${log}
echo "DEBUG: command: ${command}; current: ${current}; force: ${force}" >> ${log}

if [[ "${command}" == "${current}" && "${force}" != "yes" ]]; then
   echo "nothing to do"  >> ${log}
   exit 0
fi

if [[ -n "${current}" ]]; then
   echo "stopping ${current}" >> ${log}
   if [[ "${current}" == "vdr" ]]; then
      sudo systemctl stop "${current}";
   else
      systemctl --user stop "${current}";
   fi
fi

if [[ "${command}" == "restart" ]]; then
   if [[ "${current}" == "vdr" ]]; then
      sudo systemctl restart "${current}";
   else
      systemctl --user restart "${current}";
   fi
fi

if [[ "${command}" == "toggle" ]]; then
   if [[ -z "${current}" ]]; then
      command="vdrosd"
   elif [[ "${current}" = "vdrosd" ]]; then
      command="musicosd"
   elif [[ "${current}" = "musicosd" ]]; then
      command="vdrosd"
   fi
fi

if [[ "${command}" == "vdr" ]]; then
   sudo systemctl stop squeezelite.service
   sudo systemctl stop lightdm.service
   echo "stopped squeezelite and lightdm" >> ${log}
elif [[ "${current}" == "vdr" ]]; then
   sudo systemctl start squeezelite.service
   sudo systemctl start lightdm.service
   echo "started squeezelite and lightdm" >> ${log}
fi

# start service

if [[ "${command}" != "restart" ]]; then
   echo "starting ${command}" >> ${log}
   if [[ "${command}" == "vdr" ]]; then
      sudo systemctl start "${command}";
   else
      systemctl --user start "${command}";
   fi
fi

exit 0
