#!/bin/bash

if [[ -z "${1}" ]]; then
   echo "Missing arguments {restart, toggle, vdrosd, musicosd, vdr} [force]"
   exit 1
fi

force="no"
command=${1}
force=${2}
current=""

if [[ "$#" -ge 2 ]]; then
   force="yes"
fi

systemctl --user stop browser

systemctl --user is-active --quiet musicosd && current="musicosd"
systemctl --user is-active --quiet vdrosd && current="vdrosd"
systemctl --user is-active --quiet vdr && current="vdr"

# echo "DEBUG: command: ${command}; current: ${current}; force: ${force}"

if [[ "${command}" == "${current}" && "${force}" != "yes" ]]; then
   echo "nothing to do"
   exit 0
fi

if [[ -n "${current}" ]]; then
   # echo "stopping ${current}"
   systemctl --user stop "${current}";
fi

if [[ "${command}" == "restart" ]]; then
   systemctl --user start "${current}";
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
elif [[ "${current}" != "vdr" ]]; then
   sudo systemctl start squeezelite.service
   sudo systemctl start lightdm.service
fi


if [[ "${command}" != "restart" ]]; then
   # echo "DEBUG: starting ${command}"
   systemctl --user start "${command}";
fi

exit 0
