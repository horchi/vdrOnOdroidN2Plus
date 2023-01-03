#!/bin/sh

# should be called at system init by systend unit file (only once)

do_mount() {
   mount -t proc none /storage/UBUNTU/proc
   mount -o bind /dev /storage/UBUNTU/dev
   mount -o bind /dev/pts /storage/UBUNTU/dev/pts
   mount -o bind /sys /storage/UBUNTU/sys
   mount -o bind / /storage/UBUNTU/ce
   mount -o bind /storage /storage/UBUNTU/storage
   mount -o bind /run /storage/UBUNTU/run

   if [ -f /storage/bin/ubuntu-init-user.sh ]; then
      /storage/bin/ubuntu-init-user.sh
   fi
}

[ ! -d "/storage/UBUNTU/dev/usb" ] && do_mount

systemctl stop kodi
systemctl mask kodi
killall -q splash-image

modprobe amlcm
modprobe videobuf-res
modprobe amlvideodri
