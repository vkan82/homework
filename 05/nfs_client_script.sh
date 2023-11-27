#!/bin/bash
sudo -i
#устанавливаем nfs-utils и запускаем
yum install -y nfs-utils
systemctl enable nfs
systemctl start nfs
#устанавливаем firewall и запускаем
yum -y install firewalld
systemctl enable firewalld
systemctl start firewalld
#добавляем /mnt в /etc/fstab
echo "192.168.50.10:/srv/share/ /mnt nfs vers=3,proto=udp,noauto,x-systemd.automount 0 0" >> /etc/fstab
systemctl daemon-reload 
systemctl restart remote-fs.target 
ls /mnt
