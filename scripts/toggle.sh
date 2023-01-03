#!/bin/bash

if [[ -z "${1}" ]]; then
   echo "Missing arguments"
   exit 1
fi

command=${1}
current=""

systemctl is-active --quiet vdr  && current="vdr"
systemctl is-active --quiet kodi && current="kodi"

# echo "command: ${command}; current: ${current}"

if [[ "${command}" == "${current}" ]]; then
   echo "nothing to do"
   exit 0
fi

if [[ -n "${current}" ]]; then
   # echo "stopping ${current}"
   systemctl stop "${current}";
fi

if [[ "${command}" == "toggle" ]]; then
   if [[ -z "${current}" ]]; then
      command="vdr"
   elif [[ "${current}" = "kodi" ]]; then
      command="vdr"
   elif [[ "${current}" = "vdr" ]]; then
      command="kodi"
   fi
fi

if [[ "${command}" == "kodi" ]]; then
   systemctl unmask kodi
else
   systemctl mask kodi
fi

# echo "starting ${command}"
systemctl start "${command}";
