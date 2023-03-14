# Setup VDR on ODROID N2+

# Overview

CoreELEC is used as the base installation, the VDR is installed in a chrooted Ubuntu environment.
The basic idea comes from here on the VDR portal https://www.vdr-portal.de/forum/index.php?thread/135070-howto-installation-eines-vdr-innerhalb-von-coreelec-amlogic-only/&postID=1349603#post1349603

The communication of the chroot Environment with the basis installation of the CoreELEC and the systemd are based on a named pipe. The VDR is set up using it's configuration in /etc/vdr/conf.d and /etc/vdr/conf.avail which is more flexible than a run script.
For the VDR and the plugins the ready prepared and build packages from the repositories of seahawk1986 (Alexander) and ckone (Christian) are used.

Installation on an SD card as described below, is sufficient from my point of view, especially if you have the data (recordings, ...) on a central storage like a Sever or NAS.
Otherwise, the installation on an eMMC works in principle the same.

With the setup/scripts described here it is possible to execute commands like systemctl directly from the UBUNTU/chroot environment on the CoreELEC base system.

After the described installation one comes to a client VDR assuming that the data medium for recordings is mounted as a network drive and the DVB stream is provided via the satip or the streamdev plugin.
The extension to a 'full-fledged' VDR by a DVB card (if this is supported by the kernel installed with CoreELEC) and a HDD / SSD for the recordings based on this setup is of course nothing in the way.

# 1 Prepare SD card

In this step the SD card is prepared for the first boot, this takes place completely on the Linux PC.
If you want to use Windows to prepare the SD card, you only have to solve the step to mount the Ubuntu image with a loop device in a different way,
I don't know what Windows offers for this. One simple solution would be to use another SD card from which you can copy the Ubuntu file tree.
## CoreELEC image
### Download CoreELEC image
```
wget https://github.com/CoreELEC/CoreELEC/releases/download/19.5-Matrix/CoreELEC-Amlogic-ng.arm-19.5-Matrix-Odroid_N2.img.gz
```
and flush to SD card (or use the actuall image from https://github.com/CoreELEC/CoreELEC/releases).

### Put the SD card into your ODROD N2+ and boot

Now follow the installation wizard and activate at least the ssh access,
then use kodi to make the following settings
```
- Timezone
- Keyboard
- Language
- WOL
- IR remote Power Code like MCE (or what you need)
- adjust the resolution according to your need (3840 x 2160 for UHD)
```
Shutdown the ODROD, renmove the SD card and put it back into the Linux desctop PC,
mount the data (STORAGE) partition of the SD card to \<your-coreelec-sd-moint-point\>

## Download Ubutu image and uncompress
```
wget https://odroid.in/ubuntu_22.04lts/N2/ubuntu-22.04-4.9-minimal-odroid-n2-20220622.img.xz
unxz ubuntu-22.04-4.9-minimal-odroid-n2-20220622.img.xz
```
(or use the actuall *minimal* Ubuntu image from https://odroid.in/ubuntu_22.04lts/N2/)

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
sudo cp -a /mnt/ <your-sd-moint-point>/UBUNTU/
sudo umount /mnt
rm <your-sd-moint-point>/UBUNTU/aafirstboot
rm <your-sd-moint-point>/UBUNTU/.first_boot
```

Finally umount the card

# 2 Prepare UBUNTU/chroot environment

Put the SD card into your ODROD N2+, boot and login as root via ssh

### Setup name resolution for UBUNTU/chroot

Replace the IP with that of the name server to be used:
```
rm /storage/UBUNTU/etc/resolv.conf
echo 'nameserver 192.168.200.101' > /storage/UBUNTU/etc/resolv.conf
```

### Setup UBUNTU/chroot environment

We fetch these files manually because we miss the git command under CoreELEC

```
mkdir /storage/UBUNTU/storage
mkdir /storage/bin
curl -o /storage/.config/system.d/ubuntu.service https://raw.githubusercontent.com/horchi/vdrOnOdroidN2Plus/main/systemd/units/ubuntu.service
curl -o /storage/bin/ubuntu-init.sh https://raw.githubusercontent.com/horchi/vdrOnOdroidN2Plus/main/scripts/ubuntu-init.sh
curl -o /storage/bin/chg-ubuntu https://raw.githubusercontent.com/horchi/vdrOnOdroidN2Plus/main/scripts/chg-ubuntu
curl -o /storage/.bashrc https://raw.githubusercontent.com/horchi/vdrOnOdroidN2Plus/main/env/.bashrc
curl -o /storage/.bashrc_ubuntu https://raw.githubusercontent.com/horchi/vdrOnOdroidN2Plus/main/env/.bashrc_ubuntu
curl -o /storage/.profile https://raw.githubusercontent.com/horchi/vdrOnOdroidN2Plus/main/env/.profile

chmod 755 /storage/bin/*
source ~/.bashrc
systemctl enable ubuntu.service
systemctl start ubuntu.service      # start only once! Will be started automatically from the next boot.
```

Now we are prepared to enter UBUNTU/chroot just by calling ```chg-ubuntu```, this command can always be used to get into the UBUNTU/chroot environment.

Now change to the UBUNTU/chroot ```chg-ubuntu``` to perform the next steps under UBUNTU!

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
apt install -y htop aptitude telnet psmisc git make g++
apt install -y vdr vdrctl
apt install -y libgl-dev libglu-dev libfreetype-dev libgles2-mesa-dev freeglut3-dev libglm-dev libavcodec-dev libdrm-dev libasound2-dev vdr-dev
apt install -y vdr-plugin-skindesigner vdr-plugin-menuorg
apt install -y vdr-plugin-epg2vdr vdr-plugin-scraper2vdr vdr-plugin-osd2web
apt install -y vdr-plugin-satip vdr-plugin-remote
apt install -y vdr-plugin-seduatmo vdr-plugin-squeezebox
apt install vdr-plugin-weatherforecast
mkdir -p /var/lib/video
```

Install the softhdodroid plugin
```
mkdir /storage/build/
cd /storage/build/
git clone https://github.com/jojo61/vdr-plugin-softhdodroid
cd vdr-plugin-softhdodroid
make clean all install
echo
```

### Install scripts and systemd unit files

```
cd /storage/build
git https://github.com/horchi/vdrOnOdroidN2Plus.git
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

# 3 Setup the channel logos for skindesigner and osd2web

I use the logos as described here https://www.vdr-portal.de/forum/index.php?thread/133497-kanallogos-f%C3%BCr-den-vdr-skript-mp-logos/&postID=1324745#post1324745

### The installation steps
```
chg-ubuntu
cd /storage/build
git clone https://github.com/MegaV0lt/MP_Logos
cd MP_Logos
cp mp_logos.conf.dist /etc/mp_logos.conf
cp mp_logos.sh /storage//bin/
mkdir /usr/share/vdr/plugins/skindesigner/logos
```

### Now adjust settings in /etc/mp_logos.conf, here's my configuration
```
CHANNELSCONF='/etc/vdr/channels.conf'  # VDR's Kanalliste
LOGODIR='/usr/share/vdr/plugins/skindesigner/logos'
MP_LOGODIR='/usr/share/vdr/plugins/skindesigner/mediaportal-de-logos'
LOGO_VARIANT='Light'                   # Logos für dunklen Hintergrund
USE_SVG='true'  # Auf 'true' setzen um SVG-Logos zu verwenden [Experimentell]
CHANNELSCONF='/etc/vdr/channels.conf'  # VDR's Kanalliste
```
now (assuming the above paths settings) clone the logos from git
```
cd /storage/UBUNTU/usr/share/vdr/plugins/skindesigner/
git clone https://github.com/Jasmeet181/mediaportal-de-logos.git
```
finally create the links
```
mp_logos.sh -c /etc/mp_logos.conf
```
and set the logo path option for the osd2web plugin to ```-l /usr/share/vdr/plugins/skindesigner/logos``` by calling ```vdrctl edit osd2web```

# 4 Customize

If more mounts or other things are needed for the chroot environment this can be done useing the file ```/storage/bin/ubuntu-init-user.sh```
it will not be overwritten when updating the scripts provided here.
The same can be done with your own settings for the .bashrc using ```/storage/.bash_user```

# 5 Sensor data

To display the cpu, memory and system temperatures with teh skindesigner plugin some sensore data is needed.
The script is allready installed from this git and has to be linked to the skindesigner folder
```
chg-ubuntu
rm -f /storage/UBUNTU/usr/lib/vdr/plugins/skindesigner/scripts/temperatures
ln -s /storage/bin/temperatures.odroid  /storage/UBUNTU/usr/lib/vdr/plugins/skindesigner/scripts/temperatures
```

# 6 Power key

If you like to power on by a key the power on switch can be enabled as described here:
https://www.bachmann-lan.de/odroid-n2-mit-einfachem-power-switch/

# 7 sshd in chroot

Prepare to use same home folder:
```
chg-ubuntu
mv /root /root.bak
ln -s /storage /root
```
add ```Port 2022``` to /etc/ssh/sshd_config
Start sshd by calling ```/usr/sbin/sshd```
Now you can login directly to the chroot environment by ```ssh  -p 2022 root@uhdvdr```
or open a File remotly by emacs tramp protocol using URL: ```/scp:root@uhdvdr#2022:/root/build/vdrOnOdroidN2Plus/```
assuming uhdvdr is your DNS or IP

# 8 GPIO port

To control GPIO port with python scripts
```
chg-ubuntu
sudo add-apt-repository -y ppa:hardkernel/ppa
sudo apt update
sudo apt install -y python3 python3-dev python3-pip odroid-wiringpi libwiringpi-dev
ln -s /usr/include/wiringpi2/wiringPi.h /usr/local/include/wiringPi.h
python3 -m pip install -U --user pip Odroid.GPIO
```

# 9 TFT Display

To control a separate TFT with the osd2web plugin, the ODROID lacks a second HDMI output and another GPU to run X simultaneously with the VDR.
My solution to this - since I don't want to do without the TFT with current information - is an additional Raspberry Pi on which only X and a browser are running.
According to my power meter the Raspberry Pi (3B) needs ~2.1 Watt (without display) in this operation.


here follows soon the description of the setup ...

# To be described later

- nfs mount
/etc/vdr/svdrphosts.conf
