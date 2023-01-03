#!/bin/bash

TARGETS="/storage/HOWTO|/storage/.config/system.d/*.service|/storage/.config/default/:systemd  \
         /storage/.config:dot-config  \
         /storage/bin:storage-bin  \
         /storage/.bashrc_ubuntu|/storage/.bashrc|/storage/.profile:env \
         /storage/UBUNTU/etc/:ubuntu-etc \
         /storage/UBUNTU/var/lib/vdr:ubuntu-var-lib-vdr "

BACKUP_DIR="/storage/backup"
# DROPBOX_DIR="/root/dropbox-dec"
HOST=`hostname`
STORE_AT="gate:/tank/system/backup/uhdvdr/"
DATE=`date +%Y%m%d`
DATE="."
LOG="/storage/backup/backup.log"


echo "==========================================================" >> $LOG 2>&1
date  >> $LOG 2>&1
echo "----------------------------------------------------------" >> $LOG 2>&1

if [ ! -d "${BACKUP_DIR}" ]; then
    echo "Fatal, folder ${BACKUP_DIR} missing, aborting!"  >> $LOG 2>&1
    exit
fi

mkdir -p "${BACKUP_DIR}/${DATE}"

for d in $TARGETS; do

   WHAT=`echo $d | sed s/":.*"/""/`
   NAME=`echo $d | sed s/".*:"/""/`

   FILENAME="${BACKUP_DIR}/$DATE/$HOST-$NAME.tgz"

   WHAT=`echo ${WHAT} | sed s/"|"/" "/g`
   echo "Packing ${WHAT} to ${FILENAME}" >> $LOG 2>&1

   tar czf "${FILENAME}" --exclude='tmp' --exclude='*~' --exclude='temp' --exclude='.npm' --exclude='.mozilla' --exclude='.cache' ${WHAT} >> $LOG 2>&1

done

scp ${BACKUP_DIR}/* ${STORE_AT}

echo "==========================================================" >> $LOG 2>&1
