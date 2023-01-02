# vdrOnOdroidN2Plus
Setup VDR on ODROID N2+

Installation on an SD card, is sufficient from my point of view if you have the data (recordings, ...) on a Sever/NAS. Otherwise, the installation on an SSD works in principle the same.

CoreELEC is used as the base installation and the VDR is installes in a chrooted Ubuntu environment.
The idea and procedure come from here from the VDR portal
https://www.vdr-portal.de/forum/index.php?thread/135070-howto-installation-eines-vdr-innerhalb-von-coreelec-amlogic-only/&postID=1349603#post1349603

The scripts for building the environment and starting and stopping the services are new. The communication of the chroot Environment with the basis installation of the CoreELEC and the systemd are based on a named pipe. The VDR is set up using it's configuration in /etc/vdr/conf.d and /etc/vdr/conf.avail instead of a runvdr script.

# 1 Prepare SD card

## CoreELEC image
### Download CoreELEC image
```
wget https://github.com/CoreELEC/CoreELEC/releases/download/19.5-Matrix_rc3/CoreELEC-Amlogic-ng.arm-19.5-Matrix_rc3-Odroid_N2.img.gz
```
and flush to SD card.
Now mount the data partition of the DS card to \<your-coreelec-sd-moint-piont\>

## Download Ubutu image and uncompress
```
wget https://odroid.in/ubuntu_22.04lts/N2/ubuntu-22.04-4.9-minimal-odroid-n2-20220622.img.xz
unxz ubuntu-22.04-4.9-minimal-odroid-n2-20220622.img.xz
```
### Mount the Ubuntu image to /mnt
Theretofore get the postion of the partition
```
fdisk -l ubuntu-22.04-4.9-minimal-odroid-n2-20220622.img | grep Linux
ubuntu-22.04-4.9-minimal-odroid-n2-20220622.img2      264192 7944191  7680000  3,7G 83 Linux
```
Here 264192 blocks, now calculate the postion/offset in bytes: offset = 264192 * 512 = 135266304
And mount it using this offset:
```
sudo mount -o loop,offset=135266304 ./ubuntu-22.04-4.9-minimal-odroid-n2-20220622.img /mnt
```
### Copy the Ubuntu to the SD card below the CodeELEC installation
mkdir <your-coreelec-sd-moint-piont>/storage
```
sudo cp -a /mnt/ <your-sd-moint-piont>/storage/UBUNTU/
umount /mnt
rm <your-sd-moint-piont>/storage/UBUNTU/aafirstboot
rm <your-sd-moint-piont>/storage/UBUNTU/.first_boot
umount <your-sd-moint-piont>

# 2 First boot

put the SD card into your ODROD N2+ and boot

Use kodi to make the following settings
```
- Timezone
- Tastatur
- Sprache
- WOL
```
