#!/bin/bash

echo `date` >> /storage/ire.log

/usr/sbin/chroot /storage/UBUNTU /usr/bin/irexec /etc/lirc/lircrc
