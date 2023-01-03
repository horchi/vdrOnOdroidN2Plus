#!/bin/bash

echo "shutdown called" > /tmp/log

sudo hwclock --systohc --utc

NextTimer=$(($1 - 600))  # 10 minutes earlier
sudo bash -c "echo 0 > /sys/class/rtc/rtc0/wakealarm"
sudo bash -c "echo $NextTimer > /sys/class/rtc/rtc0/wakealarm"

/storage/bin/pwrite.sh "/storage/chroot-commands.pipe" "shutdown -h now"
