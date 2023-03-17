
tar cvf vdrtft-raspi.tgz \
    /home/pi/.config/default/ \
    /home/pi/.config/systemd/ \
    /home/pi/bin \
    /root/bin \
    /usr/lib/systemd/system/cooler-control.service \
    /usr/local/bin/cooler_control.py \
    /boot/config.txt \
    /etc

scp vdrtft-raspi.tgz root@gate:
