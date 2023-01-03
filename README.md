# vdrOnOdroidN2Plus
Setup VDR on ODROID N2+

Installation on an SD card, is sufficient from my point of view if you have the data (recordings, ...) on a Sever/NAS. Otherwise, the installation on an SSD works in principle the same.

CoreELEC is used as the base installation, the VDR is installed in a chrooted Ubuntu environment.
The idea and procedure come from here from the VDR portal
https://www.vdr-portal.de/forum/index.php?thread/135070-howto-installation-eines-vdr-innerhalb-von-coreelec-amlogic-only/&postID=1349603#post1349603

The scripts for building the environment and starting and stopping the services are new. The communication of the chroot Environment with the basis installation of the CoreELEC and the systemd are based on a named pipe. The VDR is set up using it's configuration in /etc/vdr/conf.d and /etc/vdr/conf.avail instead of a runvdr script.
For the VDR and the plugins the ready packages from the repositories of Alexander and Christian are used.

# 1 Prepare SD card

In this step the SD card is prepared for the first boot, this takes place completely on the PC (with me under Linux).

## CoreELEC image
### Download CoreELEC image
```
wget https://github.com/CoreELEC/CoreELEC/releases/download/19.5-Matrix_rc3/CoreELEC-Amlogic-ng.arm-19.5-Matrix_rc3-Odroid_N2.img.gz
```
and flush to SD card.
Now mount the data partition of the SD card to \<your-coreelec-sd-moint-point\>

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
mkdir <your-coreelec-sd-moint-point>/storage
```
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
- Tastatur
- Sprache
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

Now we are prepared to use UBUNTU/chroot by calling ```chg-ubuntu``` this command can always be used to get into the UBUNTU/chroot environment.

### Setup the timezone for Ubuntu
```
dpkg-reconfigure tzdata
```

### Add VDR repositories from Alexander and Christian
```
apt install software-properties-common
add-apt-repository ppa:seahawk1986-hotmail/jammy-main
add-apt-repository ppa:ckone/jammy-vdr
apt update
apt dist-upgrade
```

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
