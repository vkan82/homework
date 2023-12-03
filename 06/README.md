# Управление пакетами. Дистрибьюция софта
********************************************************************************
1. _Создать свой RPM пакет_
********************************************************************************
Запускаем ВМ с помощью Vagrantfile (/homework/06/v0/Vagrantfile).
Использую свой образ из первой ДЗ "samo82/centos8-kernel6".
Подключаемся с помощью vagrant ssh, команды и вывод результатов:

```shell
vkan@l04-ubuntu:~/Documents/DZ/packet_manage$ vagrant destroy -f
vkan@l04-ubuntu:~/Documents/DZ/packet_manage$ vagrant up
vkan@l04-ubuntu:~/Documents/DZ/packet_manage$ vagrant ssh
```
_# Устанавливаем необходимые пакеты для создания репозитория:_
```shell
[root@packages ~]# yum install -y \
> redhat-lsb-core \
> wget \
> rpmdevtools \
> rpm-build \
> createrepo \
> yum-utils \
> gcc
CentOS Stream 8 - AppStream                     275 kB/s |  34 MB     02:07    
CentOS Stream 8 - BaseOS                        548 kB/s |  55 MB     01:42    
CentOS Stream 8 - Extras                        7.8 kB/s |  18 kB     00:02    
CentOS Stream 8 - Extras common packages        4.1 kB/s | 6.9 kB     00:01    
...                        
  yum-utils-4.0.21-24.el8.noarch                                                
  zstd-1.4.4-1.el8.x86_64                                                       

Complete!

```
_# Cкачиваем и разархивируем исходники для openssl, который также потребуется для сборки:_
```shell    
[root@packages ~]# wget https://www.openssl.org/source/openssl-1.1.1w.tar.gz -O /root/openssl-1.1.1w.tar.gz
[root@packages ~]# tar -xvf /root/openssl-1.1.1w.tar.gz -C /root/

```
_# Скачиваем SRPM пакет NGINX для дальнейшей работы над ним:_
```shell
[root@packages ~]# wget https://nginx.org/packages/centos/8/SRPMS/nginx-1.20.2-1.el8.ngx.src.rpm -O /root/nginx-1.20.2-1.el8.ngx.src.rpm
[root@packages ~]# rpm -i /root/nginx-1.20.2-1.el8.ngx.src.rpm
```
_# Заранее поставим все зависимости чтобы в процессе сборки не было ошибок:_
```shell
[root@packages ~]# yum-builddep rpmbuild/SPECS/nginx.spec
```
_# Заменяем сам spec файл, чтобы NGINX собирался с необходимыми нам опциями (/homework/06/nginx.spec):_
```shell
[root@packages ~]# wget https://raw.githubusercontent.com/vkan82/homework/main/06/nginx.spec -O /root/rpmbuild/SPECS/nginx.spec
```
_# Теперь можно приступить к сборке RPM пакета:_
```shell
[root@packages ~]# rpmbuild -bb /root/rpmbuild/SPECS/nginx.spec
Executing(%prep): /bin/sh -e /var/tmp/rpm-tmp.QKLTps
+ umask 022
+ cd /root/rpmbuild/BUILD
+ cd /root/rpmbuild/BUILD
+ rm -rf nginx-1.20.2
+ /usr/bin/gzip -dc /root/rpmbuild/SOURCES/nginx-1.20.2.tar.gz
+ /usr/bin/tar -xof -
+ STATUS=0
...
Requires(rpmlib): rpmlib(CompressedFileNames) <= 3.0.4-1 rpmlib(FileDigests) <= 4.6.0-1 rpmlib(PayloadFilesHavePrefix) <= 4.0-1
Checking for unpackaged file(s): /usr/lib/rpm/check-files /root/rpmbuild/BUILDROOT/nginx-1.20.2-1.el8.ngx.x86_64
Wrote: /root/rpmbuild/RPMS/x86_64/nginx-1.20.2-1.el8.ngx.x86_64.rpm
Wrote: /root/rpmbuild/RPMS/x86_64/nginx-debuginfo-1.20.2-1.el8.ngx.x86_64.rpm
Executing(%clean): /bin/sh -e /var/tmp/rpm-tmp.A2oYdQ
+ umask 022
+ cd /root/rpmbuild/BUILD
+ cd nginx-1.20.2
+ /usr/bin/rm -rf /root/rpmbuild/BUILDROOT/nginx-1.20.2-1.el8.ngx.x86_64
+ exit 0
```
_# Убедимся, что пакеты создались:_
```shell
[root@packages ~]# ll /root/rpmbuild/RPMS/x86_64/
total 3148
-rw-r--r--. 1 root root  838340 ноя 27 03:34 nginx-1.20.2-1.el8.ngx.x86_64.rpm
-rw-r--r--. 1 root root 2380072 ноя 27 03:34 nginx-debuginfo-1.20.2-1.el8.ngx.x86_64.rpm
```
_# Теперь можно установить наш пакет и убедиться, что nginx работает:_
```shell
[root@packages ~]# yum localinstall -y /root/rpmbuild/RPMS/x86_64/nginx-1.20.2-1.el8.ngx.x86_64.rpm
...
[root@packages ~]# systemctl start nginx
[root@packages ~]# systemctl status nginx
● nginx.service - nginx - high performance web server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Mon 2023-11-27 04:00:25 EST; 7s ago
     Docs: http://nginx.org/en/docs/
  Process: 53346 ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx.conf (code=exited, status=0/SUCCESS)
 Main PID: 53348 (nginx)
    Tasks: 3 (limit: 12221)
   Memory: 3.0M
   CGroup: /system.slice/nginx.service
           ├─53348 nginx: master process /usr/sbin/nginx -c /etc/nginx/nginx.conf
           ├─53349 nginx: worker process
           └─53350 nginx: worker process

ноя 27 04:00:25 packages systemd[1]: Starting nginx - high performance web server...
ноя 27 04:00:25 packages systemd[1]: Started nginx - high performance web server.
```
_# Теперь приступим к созданию своего репозитория. Директория для статики у NGINX по
умолчанию /usr/share/nginx/html. Создадим там каталог repo:
```shell
[root@packages ~]# mkdir /usr/share/nginx/html/repo
[root@packages ~]# ls /usr/share/nginx/html
50x.html  index.html  repo
[root@packages ~]# cp rpmbuild/RPMS/x86_64/nginx-1.20.2-1.el8.ngx.x86_64.rpm /usr/share/nginx/html/repo/
[root@packages ~]# ls /usr/share/nginx/html/repo/
nginx-1.20.2-1.el8.ngx.x86_64.rpm
[root@packages ~]# chmod a+x /usr/share/nginx/html/repo/nginx-1.20.2-1.el8.ngx.x86_64.rpm
[root@packages ~]# ls /usr/share/nginx/html/repo/
nginx-1.20.2-1.el8.ngx.x86_64.rpm
[root@packages ~]# wget https://downloads.percona.com/downloads/percona-distribution-mysql-ps/percona-distribution-mysql-ps-8.0.28/binary/redhat/8/x86_64/percona-orchestrator-3.2.6-2.el8.x86_64.rpm -O /usr/share/nginx/html/repo/percona-orchestrator-3.2.6-2.el8.x86_64.rpm
--2023-11-27 04:09:43--  https://downloads.percona.com/downloads/percona-distribution-mysql-ps/percona-distribution-mysql-ps-8.0.28/binary/redhat/8/x86_64/percona-orchestrator-3.2.6-2.el8.x86_64.rpm
Resolving downloads.percona.com (downloads.percona.com)... 49.12.125.205, 2a01:4f8:242:5792::2
Connecting to downloads.percona.com (downloads.percona.com)|49.12.125.205|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 5222976 (5,0M) [application/x-redhat-package-manager]
Saving to: ‘/usr/share/nginx/html/repo/percona-orchestrator-3.2.6-2.el8.x86_64.rpm’

/usr/share/nginx/html/repo/percona-orchestrator-3.2. 100%[=====================================================================================================================>]   4,98M   612KB/s    in 9,6s    

2023-11-27 04:09:55 (532 KB/s) - ‘/usr/share/nginx/html/repo/percona-orchestrator-3.2.6-2.el8.x86_64.rpm’ saved [5222976/5222976]
```
_# Инициализируем репозиторий:_
```shell
[root@packages ~]# createrepo /usr/share/nginx/html/repo/
Directory walk started
Directory walk done - 2 packages
Temporary output repo path: /usr/share/nginx/html/repo/.repodata/
Preparing sqlite DBs
Pool started (with 5 workers)
Pool finished
[root@packages ~]# nano /etc/nginx/conf.d/default.conf
[root@packages ~]# nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
[root@packages ~]# nginx -s reload
```
_# Выводим страничку репозитория через curl:_
```shell
[root@packages ~]# curl -a http://localhost/repo/
<html>
<head><title>Index of /repo/</title></head>
<body>
<h1>Index of /repo/</h1><hr><pre><a href="../">../</a>
<a href="repodata/">repodata/</a>                                          27-Nov-2023 09:10                   -
<a href="nginx-1.20.2-1.el8.ngx.x86_64.rpm">nginx-1.20.2-1.el8.ngx.x86_64.rpm</a>                  27-Nov-2023 09:02              838340
<a href="percona-orchestrator-3.2.6-2.el8.x86_64.rpm">percona-orchestrator-3.2.6-2.el8.x86_64.rpm</a>        16-Feb-2022 15:57             5222976
</pre><hr></body>
</html>
```
_# Все готово для того, чтобы протестировать репозиторий._
_# Добавим его в /etc/yum.repos.d:_
```shell
[root@packages ~]# cat >> /etc/yum.repos.d/otus.repo << EOF
> [otus]
> name=otus-linux
> baseurl=http://localhost/repo
> gpgcheck=0
> enabled=1
> EOF
[root@packages ~]# cat /etc/yum.repos.d
cat: /etc/yum.repos.d: Is a directory
[root@packages ~]# ll /etc/yum.repos.d/
total 56
-rw-r--r--. 1 root root  713 мар 28  2022 CentOS-Stream-AppStream.repo
-rw-r--r--. 1 root root  698 мар 28  2022 CentOS-Stream-BaseOS.repo
-rw-r--r--. 1 root root  316 мар 28  2022 CentOS-Stream-Debuginfo.repo
-rw-r--r--. 1 root root  744 мар 28  2022 CentOS-Stream-Extras-common.repo
-rw-r--r--. 1 root root  700 мар 28  2022 CentOS-Stream-Extras.repo
-rw-r--r--. 1 root root  734 мар 28  2022 CentOS-Stream-HighAvailability.repo
-rw-r--r--. 1 root root  696 мар 28  2022 CentOS-Stream-Media.repo
-rw-r--r--. 1 root root  683 мар 28  2022 CentOS-Stream-NFV.repo
-rw-r--r--. 1 root root  718 мар 28  2022 CentOS-Stream-PowerTools.repo
-rw-r--r--. 1 root root  690 мар 28  2022 CentOS-Stream-RealTime.repo
-rw-r--r--. 1 root root  748 мар 28  2022 CentOS-Stream-ResilientStorage.repo
-rw-r--r--. 1 root root 1771 мар 28  2022 CentOS-Stream-Sources.repo
-rw-r--r--. 1 root root 1946 июл 10  2022 elrepo.repo
-rw-r--r--. 1 root root   74 ноя 27 04:21 otus.repo
[root@packages ~]# ll /etc/yum.repos.d/otus.repo
-rw-r--r--. 1 root root 74 ноя 27 04:21 /etc/yum.repos.d/otus.repo
[root@packages ~]# cat /etc/yum.repos.d/otus.repo
[otus]
name=otus-linux
baseurl=http://localhost/repo
gpgcheck=0
enabled=1
```
_# Убеждаемся, что репозиторий подключился и посмотрим что в нем есть:_
```shell
[root@packages ~]# yum repolist enabled | grep otus
otus                otus-linux
[root@packages ~]# yum list | grep otus
otus-linux                                      491 kB/s | 2.8 kB     00:00    
percona-orchestrator.x86_64                            2:3.2.6-2.el8                                         otus          
```
_# Устанавливаем percona с нашего репозитория:_
```shell
[root@packages ~]# yum install percona-orchestrator.x86_64 -y
Last metadata expiration check: 0:01:07 ago on Пн 27 ноя 2023 04:23:16.
Dependencies resolved.
================================================================================
 Package                    Architecture Version               Repository  Size
================================================================================
Installing:
 percona-orchestrator       x86_64       2:3.2.6-2.el8         otus       5.0 M

Transaction Summary
================================================================================
Install  1 Package

Total download size: 5.0 M
Installed size: 16 M
Downloading Packages:
percona-orchestrator-3.2.6-2.el8.x86_64.rpm     118 MB/s | 5.0 MB     00:00    
--------------------------------------------------------------------------------
Total                                           115 MB/s | 5.0 MB     00:00     
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                        1/1
  Installing       : percona-orchestrator-2:3.2.6-2.el8.x86_64              1/1
  Running scriptlet: percona-orchestrator-2:3.2.6-2.el8.x86_64              1/1
/sbin/ldconfig: /usr/lib64/llvm15/lib/libclang.so.15 is not a symbolic link


  Verifying        : percona-orchestrator-2:3.2.6-2.el8.x86_64              1/1

Installed:
  percona-orchestrator-2:3.2.6-2.el8.x86_64                                     

Complete!
```
********************************************************************************
2. _Собираем Vagrantfile (/homework/06/Vagrantfile) со скриптом (/homework/06/repo_builder_script.sh)_
_, который создает RPM пакет NGINX, создает репозиторий и размещает RPM пакет в репозитории ():_
********************************************************************************
_# Запускаем образ:_
```shell
vkan@l04-ubuntu:~/Documents/DZ/packet_manage$ vagrant destroy -f
vkan@l04-ubuntu:~/Documents/DZ/packet_manage$ vagrant up
...
==> packages: Setting hostname...
==> packages: Configuring and enabling network interfaces...
==> packages: Running provisioner: shell...
    packages: Running: /tmp/vagrant-shell20231203-17899-n012fv.sh
...
   packages: Directory walk started
   packages: Directory walk done - 2 packages
   packages: Temporary output repo path: /usr/share/nginx/html/repo/.repodata/
   packages: Preparing sqlite DBs
   packages: Pool started (with 5 workers)
   packages: Pool finisheds
```
_# После того как образ загрузится, заходим на него через SSH и проверяем результат:_
```shell
vkan@l04-ubuntu:~/Documents/DZ/packet_manage$ vagrant ssh
Activate the web console with: systemctl enable --now cockpit.socket

Last login: Thu Jul  6 23:47:16 2023 from 10.0.2.2
[vagrant@packages ~]$ sudo -i
[root@packages ~]# curl -a http://localhost/repo/
<html>
<head><title>Index of /repo/</title></head>
<body>
<h1>Index of /repo/</h1><hr><pre><a href="../">../</a>
<a href="repodata/">repodata/</a>                                          03-Dec-2023 07:42                   -
<a href="nginx-1.20.2-1.el8.ngx.x86_64.rpm">nginx-1.20.2-1.el8.ngx.x86_64.rpm</a>                  03-Dec-2023 07:42              838340
<a href="percona-release-0.1-6.noarch.rpm">percona-release-0.1-6.noarch.rpm</a>                   11-Nov-2020 21:49               17560
</pre><hr></body>
</html>
[root@packages ~]# cat >> /etc/yum.repos.d/otus.repo << EOF
> [otus]
> name=otus-linux
> baseurl=http://localhost/repo
> gpgcheck=0
> enabled=1
> EOF
[root@packages ~]# yum repolist enabled | grep otus
otus                otus-linux
[root@packages ~]# yum list | grep otus
otus-linux                                      348 kB/s | 2.1 kB     00:00    
percona-release.noarch                                 1.0-6                                                 otus          
[root@packages ~]# systemctl status nginx
● nginx.service - nginx - high performance web server
  Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor prese>
  Active: active (running) since Sun 2023-12-03 02:42:40 EST; 51min ago
    Docs: http://nginx.org/en/docs/
 Process: 50219 ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx.conf (code=exite>
Main PID: 50220 (nginx)
   Tasks: 3 (limit: 12221)
  Memory: 3.2M
  CGroup: /system.slice/nginx.service
          ├─50220 nginx: master process /usr/sbin/nginx -c /etc/nginx/nginx.co>
          ├─50244 nginx: worker process
          └─50245 nginx: worker process

дек 03 02:42:40 packages systemd[1]: Starting nginx - high performance web serv>
дек 03 02:42:40 packages systemd[1]: Started nginx - high performance web serve>
[root@packages ~]# yum install percona-release.noarch -y
Last metadata expiration check: 0:05:25 ago on Вс 03 дек 2023 03:33:45.
Dependencies resolved.
================================================================================
Package                  Architecture    Version           Repository     Size
================================================================================
Installing:
percona-release          noarch          1.0-6             otus           17 k

Transaction Summary
================================================================================
Install  1 Package

Total download size: 17 k
Installed size: 18 k
Downloading Packages:
percona-release-0.1-6.noarch.rpm                7.5 MB/s |  17 kB     00:00    
--------------------------------------------------------------------------------
Total                                           1.7 MB/s |  17 kB     00:00     
...
 Verifying        : percona-release-1.0-6.noarch                           1/1

Installed:
 percona-release-1.0-6.noarch                                                  

Complete!
