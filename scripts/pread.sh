#!/bin/bash

spipe=${1}

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

      if [[ "${command}" == 'quit' ]]; then
         break
      fi

      echo "Info: executing '${command}'"
      eval " ${command}" > ${cpipe}

      usleep 100
      echo "quit" > ${cpipe}
   fi
done

echo "exiting"
