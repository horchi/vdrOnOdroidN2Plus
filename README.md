# Setup VDR on ODROID N2+

# Overview

CoreELEC is used as the base installation, the VDR is installed in a chrooted Ubuntu environment.
The basic idea comes from here on the VDR portal https://www.vdr-portal.de/forum/index.php?thread/135070-howto-installation-eines-vdr-innerhalb-von-coreelec-amlogic-only/&postID=1349603#post1349603

The communication of the chroot Environment with the basis installation of the CoreELEC and the systemd are based on a named pipe. The VDR is set up using it's configuration in /etc/vdr/conf.d and /etc/vdr/conf.avail which is more flexible than a run script.
For the VDR and the plugins the ready prepared and build packages from the repositories of seahawk1986 (Alexander) and ckone (Christian) are used.

Installation on an SD card as described below, is sufficient from my point of view, especially if you have the data (recordings, ...) on a central storage like a Sever or NAS.
Otherwise, the installation on an eMMC works in principle the same.

With the setup/scripts described here it is possible to execute commands like systemctl directly from the UBUNTU/chroot environment on the CoreELEC base system.

# 1 Prepare SD card

In this step the SD card is prepared for the first boot, this takes place completely on the Linux PC.
If you want to use Windows to prepare the SD card, you only have to solve the step to mount the Ubuntu image with a loop device in a different way,
I don't know what Windows offers for this. One simple solution would be to use another SD card from which you can copy the Ubuntu file tree.
## CoreELEC image
### Download CoreELEC image
```
wget https://github.com/CoreELEC/CoreELEC/releases/download/19.5-Matrix/CoreELEC-Amlogic-ng.arm-19.5-Matrix-Odroid_N2.img.gz
```
or use the actuall image from https://github.com/CoreELEC/CoreELEC/releases

and flush to SD card.
Now mount the data partition of the SD card to \<your-coreelec-sd-moint-point\>

## Download Ubutu image and uncompress
```
wget https://odroid.in/ubuntu_22.04lts/N2/ubuntu-22.04-4.9-minimal-odroid-n2-20220622.img.xz
unxz ubuntu-22.04-4.9-minimal-odroid-n2-20220622.img.xz
```
or use the actuall image from https://odroid.in/ubuntu_22.04lts/N2/

### Mount the Ubuntu image to /mnt
To do so we have to get the position of the partition
```
fdisk -l ubuntu-22.04-4.9-minimal-odroid-n2-20220622.img | grep Linux
ubuntu-22.04-4.9-minimal-odroid-n2-20220622.img2      264192 7944191  7680000  3,7G 83 Linux
```
Here 264192 blocks, now calculate the postion/offset in bytes: offset = 264192 * 512 = 135266304
And mount it using this offset:
```
sudo mount -o loop,offset=135266304 ./ubuntu-22.04-4.9-minimal-odroid-n2-20220622.img /mnt
```
Now we can access the filesystem of the image without flushing it to a card.
### Copy the entire Ubuntu filesystem tree to the SD card below the CodeELEC installation
```
mkdir -p <your-coreelec-sd-moint-point>/storage
sudo cp -a /mnt/ <your-sd-moint-point>/storage/UBUNTU/
umount /mnt
rm <your-sd-moint-point>/storage/UBUNTU/aafirstboot
rm <your-sd-moint-point>/storage/UBUNTU/.first_boot
```

Finally umount the card
```
umount <your-sd-moint-point>
```

# 2 First boot

Put the SD card into your ODROD N2+ and boot

Use kodi to make the following settings
```
- Timezone
- Keyboard
- Language
- WOL
```

# 3 Prepare UBUNTU/chroot environment

### Setup name resolution for UBUNTU/chroot

Replace the IP with that of the name server to be used:
```
rm /storage/UBUNTU/etc/resolv.conf
echo 'nameserver 192.168.200.101' > /storage/UBUNTU/etc/resolv.conf
```

### Setup UBUNTU/chroot environment

We fetch these files manually because we miss the git command under CoreELEC

```
mkdir /storage/scripts/
curl -o /storage/.config/system.d/ubuntu.service https://github.com/horchi/vdrOnOdroidN2Plus/blob/main/systemd.units/ubuntu.service
curl -o /storage/bin/ubuntu-init.sh https://github.com/horchi/vdrOnOdroidN2Plus/blob/main/scripts/ubuntu-init.sh
curl -o /storage/bin/chg-ubuntu https://github.com/horchi/vdrOnOdroidN2Plus/blob/main/scripts/chg-ubuntu
curl -o /storage/.profile https://github.com/horchi/vdrOnOdroidN2Plus/blob/main/env/.profile
curl -o /storage/.bashrc https://github.com/horchi/vdrOnOdroidN2Plus/blob/main/env/.bashrc

source .bashrc
systemctl enable ubuntu.service
systemctl start ubuntu.service      # start only once! Will be started automatically from the next boot.

echo "source ~/.bashrc" > ~/.profile
```

Now we are prepared to enter UBUNTU/chroot just by calling ```chg-ubuntu```, this command can always be used to get into the UBUNTU/chroot environment.

Now change to the UBUNTU/chroot to perform the next steps under UBUNTU!

### Setup the timezone for Ubuntu
```
dpkg-reconfigure tzdata
```

### Add VDR ppa from seahawk1986
```
apt install software-properties-common
add-apt-repository ppa:seahawk1986-hotmail/jammy-main
add-apt-repository ppa:seahawk1986-hotmail/jammy-vdr
apt update
apt dist-upgrade
```
or replace alternatively ```ppa:seahawk1986-hotmail/jammy-vdr``` with the ppa of ckone ```ppa:ckone/jammy-vdr```
it contains the menuselections and zapcockpit patches, but the selection of available plugins is a bit smaller.

### Now we install some essential packages as well as the VDR and some plugins

Select the plugins below as you like
```
apt install libgl-dev libglu-dev libgles2-mesa-dev freeglut3-dev libglm-dev libavcodec-dev libdrm-dev libasound2-dev vdr-dev
apt install htop aptitude telnet psmisc git
apt install vdr vdrctl
apt install vdr-plugin-skindesigner vdr-plugin-menuorg
apt install vdr-plugin-epg2vdr vdr-plugin-scraper2vdr vdr-plugin-osd2web
apt install vdr-plugin-satip vdr-plugin-remote
apt install vdr-plugin-seduatmo vdr-plugin-squeezebox
```

Install the softhdodroid plugin
```
cd /storage/build/
git clone https://github.com/jojo61/vdr-plugin-softhdodroid
cd vdr-plugin-softhdodroid
make clean all install
```

### Install scripts and systemd unit files

```
mkdir /storage/build
cd /storage/build
git clone git@github.com:horchi/vdrOnOdroidN2Plus.git
cd vdrOnOdroidN2Plus
make install
```

Now adjust the settings of the vdr and the plugins as you like
```
vdrctl edit vdr
vdrctl edit <plugin name>
```

Enable/disable the plugins as you like
```
vdrctl enable softhdodroid
vdrctl enable satip
vdrctl disable remote
```
To show the plugin state ```vdrctl```

Show how the VDR will be started with all his plugins and arguments
```vdr --show```

Now leave the chroot ```exit``

## Enable Services and re-boot
```
systemctl daemon-reload
systemctl enable chroot-command.service
systemctl enable vdr.service
systemctl enable irexec.service
systemctl enable ubuntu.service
reboot
```

After reboot the VDR should run

To use systemctl from the chroot environment the script systemctl.sh can be used. For example:

```
systemctl.sh status vdr
● vdr.service - Video Disk Recorder
Loaded: loaded (/storage/.config/system.d/vdr.service; enabled; vendor preset: disabled)
Active: active (running) since Tue 2023-01-03 15:31:53 CET; 2min 37s ago
Main PID: 3602 (vdr)
Status: "Ready"
Tasks: 26 (limit: 3686)
Memory: 683.5M
CGroup: /system.slice/vdr.service
└─3602 /usr/bin/vdr

Jan 03 15:33:44 uhdvdr vdr[3602]: epg2vdr: Got 0 images from database in 0 seconds (0 updates, 0 new) and created 0 links
```
or to restart
```
systemctl.sh restart vdr
```
....

/storage/bin/ubuntu-init-user.sh
~/.bash_user
