#!/bin/bash

spipe=${1}

source /storage/.bashrc

if [[ -z "${spipe}" ]]; then
   echo "Missing pipe name"
   exit 1
fi

trap "rm -f ${spipe}" EXIT

if [[ ! -p ${spipe} ]]; then
   mkfifo ${spipe}
fi

while true; do
   if read line < ${spipe}; then
      cpipe=`echo ${line} | cut -d':' -f1`
      command=`echo ${line} | cut -d':' -f2`

      if [[ "${command}" == '__quit__' ]]; then
         break
      fi

      echo "Info: executing '${command}'"
      eval " ${command} 2>&1" > ${cpipe}

      usleep 100
      echo "__quit__" > ${cpipe}
   fi
done

echo "exiting"
