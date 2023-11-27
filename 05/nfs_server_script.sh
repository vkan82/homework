#!/bin/bash
sudo -i
#устанавливаем nfs-utils и запускаем
yum -y install nfs-utils
systemctl enable nfs
systemctl start nfs
mkdir /srv/share
chmod 0777 /srv/share
chown root:root /srv/share
mkdir /srv/share/upload
chown -R nfsnobody:nfsnobody /srv/share
chmod 0777 /srv/share/upload
cat <<EOF> /etc/exports
/srv/share 192.168.50.11/32(rw,sync,root_squash)
EOF
exportfs -r
systemctl restart nfs
#устанавливаем firewall и запускаем
yum -y install firewalld
systemctl enable firewalld
systemctl start firewalld
#открываем порты 111 и 2049, и доступ к сервисам nfs и mount
firewall-cmd --permanent --add-port=111/udp
firewall-cmd --permanent --add-port=111/tcp
firewall-cmd --permanent --add-port=2049/udp
firewall-cmd --permanent --add-port=2049/tcp
firewall-cmd --permanent --add-port=20048/udp
firewall-cmd --permanent --add-port=20048/tcp
firewall-cmd --permanent --zone=public --add-service=nfs3
firewall-cmd --permanent --zone=public --add-service=rpc-bind
firewall-cmd --permanent --zone=public --add-service=mountd
firewall-cmd --reload
systemctl restart firewalld
#
exit 0
