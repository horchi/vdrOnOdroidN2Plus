#!/bin/bash

spipe=${1}
cpipe=${1}.${BASHPID}
message=${2}

trap "rm -f ${cpipe}" EXIT

if [[ ! -p ${cpipe} ]]; then
   mkfifo ${cpipe}
fi

if [[ -z "${spipe}" ]]; then
   echo "Missing pipe name"
   exit 1
fi

if [[ -z "${message}" ]]; then
   echo "Missing message"
   exit 1
fi

if [[ ! -p ${spipe} ]]; then
   echo "Reader not running"
   exit 1
fi

echo "${cpipe}:${message}" > ${spipe}

while true; do
   if read line < ${cpipe}; then
      if [[ "${line}" == '__quit__' ]]; then
         break
      fi
      echo "${line}"
   fi
done

rm -f ${cpipe}
