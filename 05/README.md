#  NFS
********************************************************************************
1. _Создаём тестовые виртуальные машины_
********************************************************************************
_# Запускаем сервер и клиента с помощью Vagrantfile (/homework/05/v0/Vagrantfile), указанный в домашнем задании. Подключаемся к серверу vagrant ssh nfss, устанавливаем "nfs-utils":_
```shell
vkan@l04-ubuntu:~/Documents/DZ/nfs$ vagrant ssh nfss
[vagrant@nfss ~]$ sudo -i
[root@nfss ~]# yum install nfs-utils
Failed to set locale, defaulting to C
Loaded plugins: fastestmirror
Determining fastest mirrors
 * base: ftp.agh.edu.pl
 * extras: ftp.agh.edu.pl
 * updates: ftp.agh.edu.pl
base                                                                          | 3.6 kB  00:00:00     
extras                                                                        | 2.9 kB  00:00:00     
updates                                                                       | 2.9 kB  00:00:00     
(1/4): base/7/x86_64/group_gz                                                 | 153 kB  00:00:01     
(2/4): extras/7/x86_64/primary_db                                             | 250 kB  00:00:01     
(3/4): updates/7/x86_64/primary_db                                            |  24 MB  00:00:04     
(4/4): base/7/x86_64/primary_db                                               | 6.1 MB  00:00:07     
Resolving Dependencies
--> Running transaction check
---> Package nfs-utils.x86_64 1:1.3.0-0.66.el7 will be updated
---> Package nfs-utils.x86_64 1:1.3.0-0.68.el7.2 will be an update
--> Finished Dependency Resolution

Dependencies Resolved

=====================================================================================================
 Package               Arch               Version                          Repository           Size
=====================================================================================================
Updating:
 nfs-utils             x86_64             1:1.3.0-0.68.el7.2               updates             413 k

Transaction Summary
=====================================================================================================
Upgrade  1 Package

Total download size: 413 k
Is this ok [y/d/N]: y
Downloading packages:
No Presto metadata available for updates
warning: /var/cache/yum/x86_64/7/updates/packages/nfs-utils-1.3.0-0.68.el7.2.x86_64.rpm: Header V3 RSA/SHA256 Signature, key ID f4a80eb5: NOKEY
Public key for nfs-utils-1.3.0-0.68.el7.2.x86_64.rpm is not installed
nfs-utils-1.3.0-0.68.el7.2.x86_64.rpm                                         | 413 kB  00:00:01     
Retrieving key from file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
Importing GPG key 0xF4A80EB5:
 Userid     : "CentOS-7 Key (CentOS 7 Official Signing Key) <security@centos.org>"
 Fingerprint: 6341 ab27 53d7 8a78 a7c2 7bb1 24c6 a8a7 f4a8 0eb5
 Package    : centos-release-7-8.2003.0.el7.centos.x86_64 (@anaconda)
 From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
Is this ok [y/N]: y
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Updating   : 1:nfs-utils-1.3.0-0.68.el7.2.x86_64                                               1/2
  Cleanup    : 1:nfs-utils-1.3.0-0.66.el7.x86_64                                                 2/2
  Verifying  : 1:nfs-utils-1.3.0-0.68.el7.2.x86_64                                               1/2
  Verifying  : 1:nfs-utils-1.3.0-0.66.el7.x86_64                                                 2/2

Updated:
  nfs-utils.x86_64 1:1.3.0-0.68.el7.2                                                                

Complete!
```
_# Запускаем firewall и проверяем, что он работает, разрешаем в firewall доступ к сервисам NFS:_
```shell
[root@nfss ~]# systemctl enable firewalld --now
Created symlink from /etc/systemd/system/dbus-org.fedoraproject.FirewallD1.service to /usr/lib/systemd/system/firewalld.service.
Created symlink from /etc/systemd/system/multi-user.target.wants/firewalld.service to /usr/lib/systemd/system/firewalld.service.
[root@nfss ~]# firewall-cmd --add-service="nfs3" \
> --add-service="rpc-bind" \
> --add-service="mountd" \
> --permanent
success
[root@nfss ~]# firewall-cmd --reload
success
```
_# Включаем сервис NFS:_
 ```shell
[root@nfss ~]# systemctl enable nfs --now
Created symlink from /etc/systemd/system/multi-user.target.wants/nfs-server.service to /usr/lib/systemd/system/nfs-server.service.
[root@nfss ~]# ss -tnplu
Netid State      Recv-Q Send-Q   Local Address:Port                  Peer Address:Port              
udp   UNCONN     0      0            127.0.0.1:871                              *:*                   users:(("rpc.statd",pid=3663,fd=5))
udp   UNCONN     0      0                    *:111                              *:*                   users:(("rpcbind",pid=400,fd=6))
udp   UNCONN     0      0                    *:55718                            *:*                  
udp   UNCONN     0      0                    *:977                              *:*                   users:(("rpcbind",pid=400,fd=7))
udp   UNCONN     0      0                    *:2049                             *:*                  
udp   UNCONN     0      0                    *:41267                            *:*                   users:(("rpc.statd",pid=3663,fd=8))
udp   UNCONN     0      0            127.0.0.1:323                              *:*                   users:(("chronyd",pid=339,fd=5))
udp   UNCONN     0      0                    *:68                               *:*                   users:(("dhclient",pid=2511,fd=6))
udp   UNCONN     0      0                    *:20048                            *:*                   users:(("rpc.mountd",pid=3672,fd=7))
udp   UNCONN     0      0                 [::]:111                           [::]:*                   users:(("rpcbind",pid=400,fd=9))
udp   UNCONN     0      0                 [::]:50803                         [::]:*                  
udp   UNCONN     0      0                 [::]:977                           [::]:*                   users:(("rpcbind",pid=400,fd=10))
udp   UNCONN     0      0                 [::]:49644                         [::]:*                   users:(("rpc.statd",pid=3663,fd=10))
udp   UNCONN     0      0                 [::]:2049                          [::]:*                  
udp   UNCONN     0      0                [::1]:323                           [::]:*                   users:(("chronyd",pid=339,fd=6))
udp   UNCONN     0      0                 [::]:20048                         [::]:*                   users:(("rpc.mountd",pid=3672,fd=9))
tcp   LISTEN     0      64                   *:2049                             *:*                  
tcp   LISTEN     0      128                  *:111                              *:*                   users:(("rpcbind",pid=400,fd=8))
tcp   LISTEN     0      128                  *:20048                            *:*                   users:(("rpc.mountd",pid=3672,fd=8))
tcp   LISTEN     0      128                  *:51283                            *:*                   users:(("rpc.statd",pid=3663,fd=9))
tcp   LISTEN     0      128                  *:22                               *:*                   users:(("sshd",pid=669,fd=3))
tcp   LISTEN     0      64                   *:35609                            *:*                  
tcp   LISTEN     0      100          127.0.0.1:25                               *:*                   users:(("master",pid=908,fd=13))
tcp   LISTEN     0      64                [::]:2049                          [::]:*                  
tcp   LISTEN     0      128               [::]:111                           [::]:*                   users:(("rpcbind",pid=400,fd=11))
tcp   LISTEN     0      128               [::]:20048                         [::]:*                   users:(("rpc.mountd",pid=3672,fd=10))
tcp   LISTEN     0      64                [::]:40022                         [::]:*                  
tcp   LISTEN     0      128               [::]:22                            [::]:*                   users:(("sshd",pid=669,fd=4))
tcp   LISTEN     0      128               [::]:43671                         [::]:*                   users:(("rpc.statd",pid=3663,fd=11))
tcp   LISTEN     0      100              [::1]:25                            [::]:*                   users:(("master",pid=908,fd=14))
```
_# создаём и настраиваем директорию, которая будет экспортирована в будущем:_
```shell
[root@nfss ~]# mkdir -p /srv/share/upload
[root@nfss ~]# chown -R nfsnobody:nfsnobody /srv/share
[root@nfss ~]# chmod 0777 /srv/share/upload
```
_# создаём в файле /etc/exports структуру, которая позволит экспортировать ранее созданную директорию:_
```shell
[root@nfss ~]# cat << EOF > /etc/exports
> /srv/share 192.168.50.11/32(rw,sync,root_squash)
> EOF
[root@nfss ~]# exportfs -r
[root@nfss ~]# exportfs -s
/srv/share  192.168.50.11/32(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)
[root@nfss ~]# exit
logout
[vagrant@nfss ~]$ exit
logout
```
_# Настраиваем клиент NFS_
_Подключаемся к клиенту vagrant ssh nfsc и устанавливаем nfs-utils:_
```shell
vkan@l04-ubuntu:~/Documents/DZ/nfs$ vagrant ssh nfsc
[vagrant@nfsc ~]$ sudo -i
[root@nfsc ~]# yum install nfs-utils
Failed to set locale, defaulting to C
Loaded plugins: fastestmirror
Determining fastest mirrors
 * base: centos.hitme.net.pl
 * extras: mirror.karneval.cz
 * updates: ftp.sh.cvut.cz
base                                                                          | 3.6 kB  00:00:00     
extras                                                                        | 2.9 kB  00:00:00     
updates                                                                       | 2.9 kB  00:00:00     
(1/4): base/7/x86_64/group_gz                                                 | 153 kB  00:00:01     
(2/4): extras/7/x86_64/primary_db                                             | 250 kB  00:00:01     
(3/4): base/7/x86_64/primary_db                                               | 6.1 MB  00:00:02     
(4/4): updates/7/x86_64/primary_db                                            |  24 MB  00:00:18     
Resolving Dependencies
--> Running transaction check
---> Package nfs-utils.x86_64 1:1.3.0-0.66.el7 will be updated
---> Package nfs-utils.x86_64 1:1.3.0-0.68.el7.2 will be an update
--> Finished Dependency Resolution

Dependencies Resolved

=====================================================================================================
 Package               Arch               Version                          Repository           Size
=====================================================================================================
Updating:
 nfs-utils             x86_64             1:1.3.0-0.68.el7.2               updates             413 k

Transaction Summary
=====================================================================================================
Upgrade  1 Package

Total download size: 413 k
Is this ok [y/d/N]: y
Downloading packages:
No Presto metadata available for updates
warning: /var/cache/yum/x86_64/7/updates/packages/nfs-utils-1.3.0-0.68.el7.2.x86_64.rpm: Header V3 RSA/SHA256 Signature, key ID f4a80eb5: NOKEY
Public key for nfs-utils-1.3.0-0.68.el7.2.x86_64.rpm is not installed
nfs-utils-1.3.0-0.68.el7.2.x86_64.rpm                                         | 413 kB  00:00:01     
Retrieving key from file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
Importing GPG key 0xF4A80EB5:
 Userid     : "CentOS-7 Key (CentOS 7 Official Signing Key) <security@centos.org>"
 Fingerprint: 6341 ab27 53d7 8a78 a7c2 7bb1 24c6 a8a7 f4a8 0eb5
 Package    : centos-release-7-8.2003.0.el7.centos.x86_64 (@anaconda)
 From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
Is this ok [y/N]: y
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Updating   : 1:nfs-utils-1.3.0-0.68.el7.2.x86_64                                               1/2
  Cleanup    : 1:nfs-utils-1.3.0-0.66.el7.x86_64                                                 2/2
  Verifying  : 1:nfs-utils-1.3.0-0.68.el7.2.x86_64                                               1/2
  Verifying  : 1:nfs-utils-1.3.0-0.66.el7.x86_64                                                 2/2

Updated:
  nfs-utils.x86_64 1:1.3.0-0.68.el7.2                                                                

Complete!
```
_# включаем firewall и проверяем, что он работает:_
```shell
[root@nfsc ~]# systemctl enable firewalld --now
Created symlink from /etc/systemd/system/dbus-org.fedoraproject.FirewallD1.service to /usr/lib/systemd/system/firewalld.service.
Created symlink from /etc/systemd/system/multi-user.target.wants/firewalld.service to /usr/lib/systemd/system/firewalld.service.
[root@nfsc ~]# systemctl status firewalld
● firewalld.service - firewalld - dynamic firewall daemon
   Loaded: loaded (/usr/lib/systemd/system/firewalld.service; enabled; vendor preset: enabled)
   Active: active (running) since Sun 2023-11-26 23:31:51 UTC; 19ms ago
     Docs: man:firewalld(1)
 Main PID: 3508 (firewalld)
   CGroup: /system.slice/firewalld.service
           ├─3508 /usr/bin/python2 -Es /usr/sbin/firewalld --nofork --nopid
           └─3510 /usr/sbin/iptables -w -L -n

Nov 26 23:31:51 nfsc systemd[1]: Starting firewalld - dynamic firewall daemon...
Nov 26 23:31:51 nfsc systemd[1]: Started firewalld - dynamic firewall daemon.
```
_# добавляем в /etc/fstab автозагрузку /mnt:_
```shell
[root@nfsc ~]# echo "192.168.50.10:/srv/share/ /mnt nfs vers=3,proto=udp,noauto,x-systemd.automount 0 0" >> /etc/fstab
[root@nfsc ~]# systemctl daemon-reload
[root@nfsc ~]# systemctl restart remote-fs.target
[root@nfsc /]# cd /mnt
[root@nfsc mnt]# mount | grep mnt
systemd-1 on /mnt type autofs (rw,relatime,fd=46,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=27074)
192.168.50.10:/srv/share/ on /mnt type nfs (rw,relatime,vers=3,rsize=32768,wsize=32768,namlen=255,hard,proto=udp,timeo=11,retrans=3,sec=sys,mountaddr=192.168.50.10,mountvers=3,mountport=20048,mountproto=udp,local_lock=none,addr=192.168.50.10)
[root@nfsc mnt]# exit
logout
[vagrant@nfsc ~]$ exit
logout
```
_#  Проверка работоспособности_
_Заходим на сервер, создаем в каталоге /srv/share/upload любой файл для проверки:_
```shell
vkan@l04-ubuntu:~/Documents/DZ/nfs$ vagrant ssh nfss
Last login: Sun Nov 26 23:28:00 2023 from 10.0.2.2
[vagrant@nfss ~]$ sudo -i
[root@nfss ~]# cd /srv/share/upload
[root@nfss upload]# touch check_file
[root@nfss upload]# ls
check_file
[root@nfss upload]# exit
logout
[vagrant@nfss ~]$ exit
logout
```
_# Заходим на клиента и проверяем в каталоге /mnt/upload файл, созданный на сервере для проверки:_
```shell
vkan@l04-ubuntu:~/Documents/DZ/nfs$ vagrant ssh nfsc
Last login: Sun Nov 26 23:30:47 2023 from 10.0.2.2
[vagrant@nfsc ~]$ cd /mnt/upload
[vagrant@nfsc upload]$ ls
check_file
```
_# Создаем другой файл в каталоге /mnt/upload для проверки на сервере и перезагружаем клиента:_
```shell
[vagrant@nfsc upload]$ touch client_file
[vagrant@nfsc upload]$ ll
total 0
-rw-r--r--. 1 root    root    0 Nov 26 23:53 check_file
-rw-rw-r--. 1 vagrant vagrant 0 Nov 26 23:54 client_file
[vagrant@nfsс ~]$ sudo -i
[root@nfsс ~]# reboot
Connection to 127.0.0.1 closed by remote host.
```
_Заходим на сервер и проверяем наличие файла, ранее созданного на клиенте, также проверяем статус firewall, NSF, RPC:_
```shell
vkan@l04-ubuntu:~/Documents/DZ/nfs$ vagrant ssh nfss
Last login: Sun Nov 26 23:54:27 2023 from 10.0.2.2
[vagrant@nfss ~]$ ls /srv/share/upload
check_file  client_file
[vagrant@nfss ~]$ systemctl status nfs
● nfs-server.service - NFS server and services
   Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; enabled; vendor preset: disabled)
  Drop-In: /run/systemd/generator/nfs-server.service.d
           └─order-with-mounts.conf
   Active: active (exited) since Sun 2023-11-26 23:55:30 UTC; 1min 31s ago
  Process: 829 ExecStartPost=/bin/sh -c if systemctl -q is-active gssproxy; then systemctl reload gssproxy ; fi (code=exited, status=0/SUCCESS)
  Process: 804 ExecStart=/usr/sbin/rpc.nfsd $RPCNFSDARGS (code=exited, status=0/SUCCESS)
  Process: 801 ExecStartPre=/usr/sbin/exportfs -r (code=exited, status=0/SUCCESS)
 Main PID: 804 (code=exited, status=0/SUCCESS)
   CGroup: /system.slice/nfs-server.service
[vagrant@nfss ~]$ systemctl status firewalld
● firewalld.service - firewalld - dynamic firewall daemon
   Loaded: loaded (/usr/lib/systemd/system/firewalld.service; enabled; vendor preset: enabled)
   Active: active (running) since Sun 2023-11-26 23:55:27 UTC; 1min 45s ago
     Docs: man:firewalld(1)
 Main PID: 403 (firewalld)
   CGroup: /system.slice/firewalld.service
           └─403 /usr/bin/python2 -Es /usr/sbin/firewalld --nofork --nopid
[vagrant@nfss ~]$ exportfs -s
exportfs: could not open /var/lib/nfs/.etab.lock for locking: errno 13 (Permission denied)
[vagrant@nfss ~]$ showmount -a 192.168.50.10
All mount points on 192.168.50.10:
192.168.50.11:/srv/share
```
_На клиенте проделываем тоже самое и делаем финальную проверку создания файла:_
```shell
vkan@l04-ubuntu:~/Documents/DZ/nfs$ vagrant ssh nfsc
Last login: Sun Nov 26 23:53:22 2023 from 10.0.2.2
[vagrant@nfsc ~]$ ls /mnt/upload
check_file  client_file
[vagrant@nfsc ~]$ showmount -a 192.168.50.10
All mount points on 192.168.50.10:
192.168.50.11:/srv/share
[vagrant@nfsc ~]$ cd /mnt/upload
[vagrant@nfsc upload]$ mount | grep mnt
systemd-1 on /mnt type autofs (rw,relatime,fd=46,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=27074)
192.168.50.10:/srv/share/ on /mnt type nfs (rw,relatime,vers=3,rsize=32768,wsize=32768,namlen=255,hard,proto=udp,timeo=11,retrans=3,sec=sys,mountaddr=192.168.50.10,mountvers=3,mountport=20048,mountproto=udp,local_lock=none,addr=192.168.50.10)
[vagrant@nfsc upload]$ touch final_check
[vagrant@nfsc upload]$ ls
check_file  client_file  final_check
[vagrant@nfss ~]$ ll /srv/share/upload
total 0
-rw-r--r--. 1 root    root    0 Nov 26 23:53 check_file
-rw-rw-r--. 1 vagrant vagrant 0 Nov 26 23:54 client_file
-rw-rw-r--. 1 vagrant vagrant 0 Nov 26 23:58 final_check

```
_# Все проверки прошли успешно, а значит стенд работоспособен._

********************************************************************************
2. _Создание автоматизированного Vagrantfile_
********************************************************************************
_# Редактируем ранее предложенный Vagrantfile (homework/v5/v0/Vagrantfile), дополнив 2 скриптами nfs_server_script.sh и nfs_client_script.sh (homework/v5/nfs_server_script.sh):_
```shell
# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure(2) do |config|
 config.vm.box = "centos/7"
 config.vm.box_version = "2004.01"
 config.vm.provider "virtualbox" do |v|
 v.memory = 256
 v.cpus = 1
 end
 config.vm.define "nfss" do |nfss|
 nfss.vm.network "private_network", ip: "192.168.50.10",  virtualbox__intnet: "net1"
 nfss.vm.hostname = "nfss"
 nfss.vm.provision "shell", path: "nfs_server_script.sh"  end
 config.vm.define "nfsc" do |nfsc|
 nfsc.vm.network "private_network", ip: "192.168.50.11",  virtualbox__intnet: "net1"
 nfsc.vm.hostname = "nfsc"
 nfsc.vm.provision "shell", path: "nfs_client_script.sh"  end
end
```
_# Проверка работоспособности автоматизированного Vagrantfile_
Перед запуском удаляем предыдущие машины vagrant destroy -f.
Запускаем сервер и клиента с помощью автоматизированного Vagrantfile (homework/v5/Vagrantfile).
```shell
vkan@l04-ubuntu:~/Documents/DZ/nfs$ vagrant destroy -f
==> nfsc: Forcing shutdown of VM...
==> nfsc: Destroying VM and associated drives...
==> nfss: Forcing shutdown of VM...
==> nfss: Destroying VM and associated drives...
vkan@l04-ubuntu:~/Documents/DZ/nfs$ vagrant up
```
_Заходим на сервер, создаем в каталоге /srv/share/upload любой файл для проверки:_
```shell
vkan@l04-ubuntu:~/Documents/DZ/nfs$ vagrant ssh nfss
[vagrant@nfss ~]$ sudo -i
[root@nfss ~]# cd /srv/share/upload
[root@nfss upload]# touch check_file
[root@nfss upload]# ls
check_file
```
_# Заходим на клиента и проверяем в каталоге /mnt/upload файл check_file:_
```shell
vkan@l04-ubuntu:~/Documents/DZ/nfs$ vagrant ssh nfsc
[vagrant@nfsc ~]$ ls /mnt/upload
check_file
```
_# Создаем другой файл в каталоге /mnt/upload для проверки на сервере и перезагружаем клиента:_
```shell
[vagrant@nfsc upload]$ touch client_file
[vagrant@nfsc upload]$ ls
check_file client_file
[vagrant@nfsс ~]$ sudo -i
[root@nfsс ~]# reboot
Connection to 127.0.0.1 closed by remote host.
```
_На клиенте проверяем статус firewall, NSF, RPC и создаем файл для финальной проверки finel_check:_
```shell
vkan@l04-ubuntu:~/Documents/DZ/nfs$ vagrant ssh nfsc
Last login: Mon Nov 27 05:15:00 2023 from 10.0.2.2
[vagrant@nfsc ~]$ cd /mnt/upload
[vagrant@nfsc upload]$ ls
check_file  client_file
[vagrant@nfsc upload]$ systemctl status nfs
● nfs-server.service - NFS server and services
   Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; enabled; vendor preset: disabled)
   Active: active (exited) since Mon 2023-11-27 05:21:16 UTC; 2min 5s ago
  Process: 826 ExecStartPost=/bin/sh -c if systemctl -q is-active gssproxy; then systemctl reload gssproxy ; fi (code=exited, status=0/SUCCESS)
  Process: 800 ExecStart=/usr/sbin/rpc.nfsd $RPCNFSDARGS (code=exited, status=0/SUCCESS)
  Process: 797 ExecStartPre=/usr/sbin/exportfs -r (code=exited, status=0/SUCCESS)
 Main PID: 800 (code=exited, status=0/SUCCESS)
   CGroup: /system.slice/nfs-server.service
[vagrant@nfsc upload]$ systemctl status firewalld
● firewalld.service - firewalld - dynamic firewall daemon
   Loaded: loaded (/usr/lib/systemd/system/firewalld.service; enabled; vendor preset: enabled)
   Active: active (running) since Mon 2023-11-27 05:21:13 UTC; 2min 15s ago
     Docs: man:firewalld(1)
 Main PID: 401 (firewalld)
   CGroup: /system.slice/firewalld.service
           └─401 /usr/bin/python2 -Es /usr/sbin/firewalld --nofork --nopid
[vagrant@nfsc upload]$ showmount -a 192.168.50.10
All mount points on 192.168.50.10:
192.168.50.11:/srv/share
[vagrant@nfsc upload]$ mount | grep mnt
systemd-1 on /mnt type autofs (rw,relatime,fd=31,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=11150)
192.168.50.10:/srv/share/ on /mnt type nfs (rw,relatime,vers=3,rsize=32768,wsize=32768,namlen=255,hard,proto=udp,timeo=11,retrans=3,sec=sys,mountaddr=192.168.50.10,mountvers=3,mountport=20048,mountproto=udp,local_lock=none,addr=192.168.50.10)
[vagrant@nfsc upload]$ touch finel_check
[vagrant@nfsc upload]$ ls
check_file  client_file  finel_check
```
_Заходим на сервер и проверяем наличие файла finel_check, также проверяем статус firewall, NSF, RPC:_
```shell
vkan@l04-ubuntu:~/Documents/DZ/nfs$ vagrant ssh nfss
[vagrant@nfss ~]$ sudo -i
[root@nfss ~]# ls /srv/share/upload/
check_file  client_file  finel_check
[root@nfss ~]# systemctl status nfs
● nfs-server.service - NFS server and services
   Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; enabled; vendor preset: disabled)
  Drop-In: /run/systemd/generator/nfs-server.service.d
           └─order-with-mounts.conf
   Active: active (exited) since Mon 2023-11-27 05:11:38 UTC; 10min ago
 Main PID: 3638 (code=exited, status=0/SUCCESS)
   CGroup: /system.slice/nfs-server.service

Nov 27 05:11:38 nfss systemd[1]: Starting NFS server and services...
Nov 27 05:11:38 nfss systemd[1]: Started NFS server and services.
[root@nfss ~]# systemctl status firewalld
● firewalld.service - firewalld - dynamic firewall daemon
   Loaded: loaded (/usr/lib/systemd/system/firewalld.service; enabled; vendor preset: enabled)
   Active: active (running) since Mon 2023-11-27 05:11:48 UTC; 10min ago
     Docs: man:firewalld(1)
 Main PID: 3871 (firewalld)
   CGroup: /system.slice/firewalld.service
           └─3871 /usr/bin/python2 -Es /usr/sbin/firewalld --nofork --nopid

Nov 27 05:11:47 nfss systemd[1]: Stopped firewalld - dynamic firewall daemon.
Nov 27 05:11:47 nfss systemd[1]: Starting firewalld - dynamic firewall daemon...
Nov 27 05:11:48 nfss systemd[1]: Started firewalld - dynamic firewall daemon.
Nov 27 05:11:48 nfss firewalld[3871]: WARNING: AllowZoneDrifting is enabled...w.
Hint: Some lines were ellipsized, use -l to show in full.
[root@nfss ~]# showmount -a 192.168.50.10
All mount points on 192.168.50.10:
192.168.50.11:/srv/share
```
# Все проверки прошли успешно.
