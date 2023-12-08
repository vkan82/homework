# Инициализация системы. Systemd.

********************************************************************************
## 1. Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова (Файл и слово должны задаваться в /etc/sysconfig).
********************************************************************************
_# Загружаем ВМ с помощью Vagrantfile (/homework/08/v0/Vagrantfile), использую свой образ "samo82/centos8-kernel6"._
_# Подключаемся._
```shell
vkan@l04-ubuntu:~/Documents/DZ/init$ vagrant destroy -f && vagrant up
vkan@l04-ubuntu:~/Documents/DZ/init$ vagrant ssh
[vagrant@nginx ~]$ sudo -i
```
_# Для начала создаём файл с конфигурацией для сервиса в директории_
_# /etc/sysconfig - из неё сервис будет брать необходимые переменные._
```shell
[root@nginx ~]# nano /etc/sysconfig/watchlog
[root@nginx ~]# cat /etc/sysconfig/watchlog
# Configuration file for my watchlog service
# Place it to /etc/sysconfig
# File and word in that file that we will be monit
WORD="ALERT"
LOG=/var/log/watchlog.log
```
_# Затем создаем /var/log/watchlog.log и пишем туда ключевое слово ‘ALERT’_
```shell
[root@nginx ~]# echo 'ALERT' > /var/log/watchlog.log
```
_# Создаем скрипт watchlog.sh и добавляем права на запуск файла:_
```shell
[root@nginx ~]# nano /opt/watchlog.sh
[root@nginx ~]# cat /opt/watchlog.sh
#!/bin/bash
WORD=$1
LOG=$2
DATE=`date`
if grep $WORD $LOG &> /dev/null
then
logger "$DATE: I found word, Master!"
else
exit 0
fi
[root@nginx ~]# chmod +x /opt/watchlog.sh
```
_# Создаем юнит для сервиса:_
```shell
[root@nginx ~]# nano /etc/systemd/system/watchlog.service
[root@nginx ~]# cat /etc/systemd/system/watchlog.service
[Unit]
Description=My watchlog service
[Service]
Type=oneshot
EnvironmentFile=/etc/sysconfig/watchlog
ExecStart=/opt/watchlog.sh $WORD $LOG
[root@nginx ~]# chmod 664 /etc/systemd/system/watchlog.service
```
_# Создадем юнит для таймера:_
```shell
[root@nginx ~]# nano /etc/systemd/system/watchlog.timer
[root@nginx ~]# cat /etc/systemd/system/watchlog.timer
[Unit]
Description=Run watchlog script every 30 second
[Timer]
# Run every 30 second
OnUnitActiveSec=30
Unit=watchlog.service
[Install]
WantedBy=multi-user.target
[root@nginx ~]# chmod 664 /etc/systemd/system/watchlog.timer
```
_# Затем стартуем service и time и смотрим логи через tail:_
```shell
[root@nginx ~]# systemctl start watchlog.service
[root@nginx ~]# systemctl start watchlog.timer
[root@nginx ~]# tail -f /var/log/messages
Dec  6 05:18:08 nginx systemd[1]: Starting My watchlog service...
Dec  6 05:18:08 nginx root[2328]: Wed Dec  6 05:18:08 EST 2023: I found word, Master!
Dec  6 05:18:08 nginx systemd[1]: watchlog.service: Succeeded.
Dec  6 05:18:08 nginx systemd[1]: Started My watchlog service.
...
Dec  6 05:18:58 nginx systemd[1]: Starting My watchlog service...
Dec  6 05:18:58 nginx root[2354]: Wed Dec  6 05:18:58 EST 2023: I found word, Master!
Dec  6 05:18:58 nginx systemd[1]: watchlog.service: Succeeded.
Dec  6 05:18:58 nginx systemd[1]: Started My watchlog service.
```
## _Как видим каждые 30-50 сек logger фиксирует успешное нахождение ключевого слова_  

********************************************************************************
## 2. Из epel установить spawn-fcgi и переписать init-скрипт на unit-файл.
********************************************************************************

_# Устанавливаем spawn-fcgi и необходимые для него пакеты:_
```shell
[root@nginx ~]# yum install epel-release -y && yum install spawn-fcgi php php-cli
```
<details><summary>см. результат установки пакетов</summary>
```shell
CentOS Stream 8 - BaseOS                        2.2 MB/s |  55 MB     00:25    
CentOS Stream 8 - Extras                        7.6 kB/s |  18 kB     00:02    
CentOS Stream 8 - Extras common packages        3.3 kB/s | 6.9 kB     00:02    
ELRepo.org Community Enterprise Linux Repositor  73 kB/s | 291 kB     00:04    
Dependencies resolved.
================================================================================
 Package               Architecture    Version            Repository       Size
================================================================================
Installing:
 epel-release          noarch          8-11.el8           extras           24 k

Transaction Summary
================================================================================
Install  1 Package

Total download size: 24 k
Installed size: 35 k
Downloading Packages:
epel-release-8-11.el8.noarch.rpm                 39 kB/s |  24 kB     00:00    
--------------------------------------------------------------------------------
Total                                            20 kB/s |  24 kB     00:01     
CentOS Stream 8 - Extras                        1.6 MB/s | 1.6 kB     00:00    
Importing GPG key 0x8483C65D:
 Userid     : "CentOS (CentOS Official Signing Key) <security@centos.org>"
 Fingerprint: 99DB 70FA E1D7 CE22 7FB6 4882 05B5 55B3 8483 C65D
 From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
Key imported successfully
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                        1/1
  Installing       : epel-release-8-11.el8.noarch                           1/1
  Running scriptlet: epel-release-8-11.el8.noarch                           1/1
/sbin/ldconfig: /usr/lib64/llvm15/lib/libclang.so.15 is not a symbolic link


  Verifying        : epel-release-8-11.el8.noarch                           1/1

Installed:
  epel-release-8-11.el8.noarch                                                  

Complete!
Extra Packages for Enterprise Linux 8 - x86_64  1.2 MB/s |  16 MB     00:13    
Extra Packages for Enterprise Linux Modular 8 - 109 kB/s | 733 kB     00:06    
Last metadata expiration check: 0:00:03 ago on Ср 06 дек 2023 06:03:20.
Dependencies resolved.
================================================================================
 Package            Arch   Version                              Repo       Size
================================================================================
Installing:
 php                x86_64 7.2.24-1.module_el8.2.0+313+b04d0a66 appstream 1.5 M
 php-cli            x86_64 7.2.24-1.module_el8.2.0+313+b04d0a66 appstream 3.1 M
 spawn-fcgi         x86_64 1.6.3-17.el8                         epel       24 k
Installing dependencies:
 apr                x86_64 1.6.3-12.el8                         appstream 129 k
 apr-util           x86_64 1.6.1-9.el8                          appstream 106 k
 centos-logos-httpd noarch 85.8-2.el8                           appstream  75 k
 httpd              x86_64 2.4.37-62.module_el8+657+88b2113f    appstream 1.4 M
 httpd-filesystem   noarch 2.4.37-62.module_el8+657+88b2113f    appstream  44 k
 httpd-tools        x86_64 2.4.37-62.module_el8+657+88b2113f    appstream 111 k
 mod_http2          x86_64 1.15.7-8.module_el8+452+6213a5e6.3   appstream 155 k
 nginx-filesystem   noarch 1:1.14.1-9.module_el8.0.0+1060+3ab382d3
                                                                appstream  24 k
 php-common         x86_64 7.2.24-1.module_el8.2.0+313+b04d0a66 appstream 661 k
Installing weak dependencies:
 apr-util-bdb       x86_64 1.6.1-9.el8                          appstream  25 k
 apr-util-openssl   x86_64 1.6.1-9.el8                          appstream  27 k
 php-fpm            x86_64 7.2.24-1.module_el8.2.0+313+b04d0a66 appstream 1.6 M
Enabling module streams:
 httpd                     2.4                                                 
 nginx                     1.14                                                
 php                       7.2                                                 

Transaction Summary
================================================================================
Install  15 Packages

Total download size: 9.0 M
Installed size: 31 M
Is this ok [y/N]: y
Is this ok [y/N]: y
Downloading Packages:
(1/15): apr-util-bdb-1.6.1-9.el8.x86_64.rpm      30 kB/s |  25 kB     00:00    
(2/15): apr-util-openssl-1.6.1-9.el8.x86_64.rpm 126 kB/s |  27 kB     00:00    
(3/15): apr-1.6.3-12.el8.x86_64.rpm              90 kB/s | 129 kB     00:01    
(4/15): apr-util-1.6.1-9.el8.x86_64.rpm          73 kB/s | 106 kB     00:01    
(5/15): centos-logos-httpd-85.8-2.el8.noarch.rp 150 kB/s |  75 kB     00:00    
(6/15): httpd-filesystem-2.4.37-62.module_el8+6 145 kB/s |  44 kB     00:00    
(7/15): mod_http2-1.15.7-8.module_el8+452+6213a 224 kB/s | 155 kB     00:00    
(8/15): nginx-filesystem-1.14.1-9.module_el8.0.  99 kB/s |  24 kB     00:00    
(9/15): httpd-tools-2.4.37-62.module_el8+657+88  53 kB/s | 111 kB     00:02    
(10/15): php-7.2.24-1.module_el8.2.0+313+b04d0a 399 kB/s | 1.5 MB     00:03    
(11/15): httpd-2.4.37-62.module_el8+657+88b2113 271 kB/s | 1.4 MB     00:05    
(12/15): php-common-7.2.24-1.module_el8.2.0+313 415 kB/s | 661 kB     00:01    
(13/15): spawn-fcgi-1.6.3-17.el8.x86_64.rpm      32 kB/s |  24 kB     00:00    
(14/15): php-cli-7.2.24-1.module_el8.2.0+313+b0 539 kB/s | 3.1 MB     00:05    
(15/15): php-fpm-7.2.24-1.module_el8.2.0+313+b0 421 kB/s | 1.6 MB     00:03    
--------------------------------------------------------------------------------
Total                                           699 kB/s | 9.0 MB     00:13     
Extra Packages for Enterprise Linux 8 - x86_64  1.6 MB/s | 1.6 kB     00:00    
Importing GPG key 0x2F86D6A1:
 Userid     : "Fedora EPEL (8) <epel@fedoraproject.org>"
 Fingerprint: 94E2 79EB 8D8F 25B2 1810 ADF1 21EA 45AB 2F86 D6A1
 From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-8
Is this ok [y/N]: y
Key imported successfully
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                        1/1
  Installing       : php-common-7.2.24-1.module_el8.2.0+313+b04d0a66.x8    1/15
  Running scriptlet: httpd-filesystem-2.4.37-62.module_el8+657+88b2113f    2/15
  Installing       : httpd-filesystem-2.4.37-62.module_el8+657+88b2113f    2/15
  Installing       : apr-1.6.3-12.el8.x86_64                               3/15
  Running scriptlet: apr-1.6.3-12.el8.x86_64                               3/15
/sbin/ldconfig: /usr/lib64/llvm15/lib/libclang.so.15 is not a symbolic link


  Installing       : apr-util-bdb-1.6.1-9.el8.x86_64                       4/15
  Installing       : apr-util-openssl-1.6.1-9.el8.x86_64                   5/15
  Installing       : apr-util-1.6.1-9.el8.x86_64                           6/15
  Running scriptlet: apr-util-1.6.1-9.el8.x86_64                           6/15
/sbin/ldconfig: /usr/lib64/llvm15/lib/libclang.so.15 is not a symbolic link


  Installing       : httpd-tools-2.4.37-62.module_el8+657+88b2113f.x86_    7/15
  Installing       : php-cli-7.2.24-1.module_el8.2.0+313+b04d0a66.x86_6    8/15
  Running scriptlet: nginx-filesystem-1:1.14.1-9.module_el8.0.0+1060+3a    9/15
  Installing       : nginx-filesystem-1:1.14.1-9.module_el8.0.0+1060+3a    9/15
  Installing       : php-fpm-7.2.24-1.module_el8.2.0+313+b04d0a66.x86_6   10/15
  Running scriptlet: php-fpm-7.2.24-1.module_el8.2.0+313+b04d0a66.x86_6   10/15
  Installing       : centos-logos-httpd-85.8-2.el8.noarch                 11/15
  Installing       : mod_http2-1.15.7-8.module_el8+452+6213a5e6.3.x86_6   12/15
  Installing       : httpd-2.4.37-62.module_el8+657+88b2113f.x86_64       13/15
  Running scriptlet: httpd-2.4.37-62.module_el8+657+88b2113f.x86_64       13/15
  Installing       : php-7.2.24-1.module_el8.2.0+313+b04d0a66.x86_64      14/15
  Installing       : spawn-fcgi-1.6.3-17.el8.x86_64                       15/15
  Running scriptlet: spawn-fcgi-1.6.3-17.el8.x86_64                       15/15
  Running scriptlet: httpd-2.4.37-62.module_el8+657+88b2113f.x86_64       15/15
  Running scriptlet: spawn-fcgi-1.6.3-17.el8.x86_64                       15/15
/sbin/ldconfig: /usr/lib64/llvm15/lib/libclang.so.15 is not a symbolic link


  Running scriptlet: php-fpm-7.2.24-1.module_el8.2.0+313+b04d0a66.x86_6   15/15
  Verifying        : apr-1.6.3-12.el8.x86_64                               1/15
  Verifying        : apr-util-1.6.1-9.el8.x86_64                           2/15
  Verifying        : apr-util-bdb-1.6.1-9.el8.x86_64                       3/15
  Verifying        : apr-util-openssl-1.6.1-9.el8.x86_64                   4/15
  Verifying        : centos-logos-httpd-85.8-2.el8.noarch                  5/15
  Verifying        : httpd-2.4.37-62.module_el8+657+88b2113f.x86_64        6/15
  Verifying        : httpd-filesystem-2.4.37-62.module_el8+657+88b2113f    7/15
  Verifying        : httpd-tools-2.4.37-62.module_el8+657+88b2113f.x86_    8/15
  Verifying        : mod_http2-1.15.7-8.module_el8+452+6213a5e6.3.x86_6    9/15
  Verifying        : nginx-filesystem-1:1.14.1-9.module_el8.0.0+1060+3a   10/15
  Verifying        : php-7.2.24-1.module_el8.2.0+313+b04d0a66.x86_64      11/15
  Verifying        : php-cli-7.2.24-1.module_el8.2.0+313+b04d0a66.x86_6   12/15
  Verifying        : php-common-7.2.24-1.module_el8.2.0+313+b04d0a66.x8   13/15
  Verifying        : php-fpm-7.2.24-1.module_el8.2.0+313+b04d0a66.x86_6   14/15
  Verifying        : spawn-fcgi-1.6.3-17.el8.x86_64                       15/15

Installed:
  apr-1.6.3-12.el8.x86_64                                                       
  apr-util-1.6.1-9.el8.x86_64                                                   
  apr-util-bdb-1.6.1-9.el8.x86_64                                               
  apr-util-openssl-1.6.1-9.el8.x86_64                                           
  centos-logos-httpd-85.8-2.el8.noarch                                          
  httpd-2.4.37-62.module_el8+657+88b2113f.x86_64                                
  httpd-filesystem-2.4.37-62.module_el8+657+88b2113f.noarch                     
  httpd-tools-2.4.37-62.module_el8+657+88b2113f.x86_64                          
  mod_http2-1.15.7-8.module_el8+452+6213a5e6.3.x86_64                           
  nginx-filesystem-1:1.14.1-9.module_el8.0.0+1060+3ab382d3.noarch               
  php-7.2.24-1.module_el8.2.0+313+b04d0a66.x86_64                               
  php-cli-7.2.24-1.module_el8.2.0+313+b04d0a66.x86_64                           
  php-common-7.2.24-1.module_el8.2.0+313+b04d0a66.x86_64                        
  php-fpm-7.2.24-1.module_el8.2.0+313+b04d0a66.x86_64                           
  spawn-fcgi-1.6.3-17.el8.x86_64                                                

Complete!
```
</details>

_# раскомментируем строки с переменными в /etc/sysconfig/spawn-fcgi_

```shell
[root@nginx ~]# nano /etc/sysconfig/spawn-fcgi
[root@nginx ~]# cat /etc/sysconfig/spawn-fcgi
# You must set some working options before the "spawn-fcgi" service will work.
# If SOCKET points to a file, then this file is cleaned up by the init script.
#
# See spawn-fcgi(1) for all possible options.
#
# Example :
SOCKET=/var/run/php-fcgi.sock
OPTIONS="-u apache -g apache -s $SOCKET -S -M 0600 -C 32 -F 1 -- /usr/bin/php-cgi"
```
_# А сам юнит файл будет примерно следующего вида:_
```shell
[root@nginx ~]# nano /etc/systemd/system/spawn-fcgi.service
[root@nginx ~]# cat /etc/systemd/system/spawn-fcgi.service
[Unit]
Description=Spawn-fcgi startup service by Otus
After=network.target
[Service]
Type=simple
PIDFile=/var/run/spawn-fcgi.pid
EnvironmentFile=/etc/sysconfig/spawn-fcgi
ExecStart=/usr/bin/spawn-fcgi -n $OPTIONS
KillMode=process
[Install]
WantedBy=multi-user.target
```
_# Убеждаемся что все успешно работает:_
```shell
[root@nginx ~]# systemctl start spawn-fcgi
[root@nginx ~]# systemctl status spawn-fcgi
● spawn-fcgi.service - Spawn-fcgi startup service by Otus
   Loaded: loaded (/etc/systemd/system/spawn-fcgi.service; disabled; vendor preset: disabled)
   Active: active (running) since Wed 2023-12-06 06:11:42 EST; 8s ago
 Main PID: 36170 (php-cgi)
    Tasks: 33 (limit: 12221)
   Memory: 18.9M
   CGroup: /system.slice/spawn-fcgi.service
           ├─36170 /usr/bin/php-cgi
           ├─36173 /usr/bin/php-cgi
           ├─36174 /usr/bin/php-cgi
           ├─36175 /usr/bin/php-cgi
           ├─36176 /usr/bin/php-cgi
           ├─36177 /usr/bin/php-cgi
           ├─36178 /usr/bin/php-cgi
           ├─36179 /usr/bin/php-cgi
           ├─36180 /usr/bin/php-cgi
           ├─36181 /usr/bin/php-cgi
           ├─36182 /usr/bin/php-cgi
           ├─36183 /usr/bin/php-cgi
           ├─36184 /usr/bin/php-cgi
           ├─36185 /usr/bin/php-cgi
           ├─36186 /usr/bin/php-cgi
           ├─36187 /usr/bin/php-cgi
```
********************************************************************************
## 3. Дополнить юнит-файл apache httpd возможностью запустить несколько
## инстансов сервера с разными конфигами
********************************************************************************
_# Для запуска нескольких экземпляров сервиса будем использовать шаблон в_
_# конфигурации файла окружения (/usr/lib/systemd/system/httpd.service ):_
```shell
[root@nginx ~]# nano /usr/lib/systemd/system/httpd.service
[root@nginx ~]# cat /usr/lib/systemd/system/httpd.service
[Unit]
Description=The Apache HTTP Server
Wants=httpd-init.service
After=network.target remote-fs.target nss-lookup.target httpd-
init.service
Documentation=man:httpd.service(8)
[Service]
Type=notify
Environment=LANG=C
EnvironmentFile=/etc/sysconfig/httpd-%I     #добавим параметр %I сюда
ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND
ExecReload=/usr/sbin/httpd $OPTIONS -k graceful
# Send SIGWINCH for graceful stop
KillSignal=SIGWINCH
KillMode=mixed
PrivateTmp=true
[Install]
WantedBy=multi-user.target
```
_# создаем два файла окружения, в которых задается опция для запуска_
_# веб-сервера с необходимым конфигурационным файлом:_
```shell
[root@nginx ~]# nano /etc/sysconfig/httpd-first
[root@nginx ~]# cat /etc/sysconfig/httpd-first
OPTIONS=-f conf/first.conf
[root@nginx ~]# nano /etc/sysconfig/httpd-second
[root@nginx ~]# cat /etc/sysconfig/httpd-second
OPTIONS=-f conf/second.conf
```
_# Соответственно в директории с конфигами httpd (/etc/httpd/conf)_
_# должны лежать два конфига, в нашем случае это будут first.conf и second.conf_
```shell  
[root@nginx ~]# cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/first.conf
cp: overwrite '/etc/httpd/conf/first.conf'? y
[root@nginx ~]# cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/second.conf
cp: overwrite '/etc/httpd/conf/second.conf'? y
```
_# Для удачного запуска, в конфигурационных файлах меняем уникальные для_
_# каждого экземпляра опции Listen и PidFile._
```shell
[root@nginx ~]# sed -i '/Listen 80/i\PidFile /var/run/httpd-first.pid' /etc/httpd/conf/first.conf
[root@nginx ~]# sed -i '/Listen 80/i\PidFile /var/run/httpd-second.pid' /etc/httpd/conf/second.conf
[root@nginx ~]# sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/second.conf
```
_# запускаем и проверяем:_
```shell
[root@nginx ~]# systemctl start httpd@second
[root@nginx ~]# systemctl start httpd@first
[root@nginx ~]# ss -tnulp | grep httpd
tcp   LISTEN 0      511           0.0.0.0:8080       0.0.0.0:*    users:(("httpd",pid=37625,fd=3),("httpd",pid=37624,fd=3),("httpd",pid=37623,fd=3),("httpd",pid=37619,fd=3))
tcp   LISTEN 0      511           0.0.0.0:80         0.0.0.0:*    users:(("httpd",pid=37875,fd=3),("httpd",pid=37874,fd=3),("httpd",pid=37873,fd=3),("httpd",pid=37866,fd=3))
```
********************************************************************************
## 4. Реализуем все 3 задания выше с использованием Vagrant
## и Vagrant shell provisioner:
********************************************************************************
_# Vagrant shell provisioner [systemd_script.sh](./08/systemd_script.sh)_

<details><summary>см. systemd_script.sh</summary>
```shell
#!/bin/bash
sudo -i

#***************************************************************
# 1. wathlog
#***************************************************************

# создаём файл с конфигурацией для сервиса в /etc/sysconfig
```
```text
cat <<EOF> /etc/sysconfig/watchlog
# Configuration file for my watchlog service
# Place it to /etc/sysconfig
# File and word in that file that we will be monitored
WORD="ALERT"
LOG=/var/log/watchlog.log
EOF
```
```shell
# создаем /var/log/watchlog.log и пишем туда ключевое слово ‘ALERT’
echo "ALERT" > /var/log/watchlog.log

# создаем скрипт
```
```text
cat <<EOF> /opt/watchlog.sh
#!/bin/bash
WORD=\$1
LOG=\$2
DATE=`date`
if grep \$WORD \$LOG &> /dev/null
then
logger "\$DATE: I found word, Master!"
else
exit 0
fi
EOF
```
```shell
chmod +x /opt/watchlog.sh

# Создаем юнит для сервиса
```
```text
cat <<EOF> /etc/systemd/system/watchlog.service
[Unit]
Description=My watchlog service
[Service]
Type=oneshot
EnvironmentFile=/etc/sysconfig/watchlog
ExecStart=/opt/watchlog.sh \$WORD \$LOG
EOF
```
```shell

# Создаем юнит для таймера
```
```text
cat <<EOF> /etc/systemd/system/watchlog.timer
[Unit]
Description=Run watchlog script every 30 second
[Timer]
# Run every 30 second
AccuracySec=1us  
# эта настройка задает точность в микросекундах, иначе отчет времени будет не точный
OnUnitActiveSec=30
Unit=watchlog.service
[Install]
WantedBy=multi-user.target
EOF
```
```shell
systemctl stop NetworkManager

# запускаем сервис и таймер
#systemctl start watchlog.service
#systemctl start watchlog.timer

# проверяем
#tail -f /var/log/messages

#*******************************************************************************
# 2. установить spawn-fcgi и переписать init-скрипт на unit-файл
#*******************************************************************************

# Устанавливаем spawn-fcgi и необходимые для него пакеты
yum install -y epel-release
yum install -y spawn-fcgi
yum -y install php
yum -y install httpd
yum -y install php
yum install php-cli
yum install -y mod_fcgid

# изменяем cам Init скрипт
```
```text
cat <<EOF> /etc/sysconfig/spawn-fcgi
# You must set some working options before the "spawn-fcgi" service will work.
# If SOCKET points to a file, then this file is cleaned up by the init script.
#
# See spawn-fcgi(1) for all possible options.
#
# Example :
SOCKET=/var/run/php-fcgi.sock
OPTIONS="-u apache -g apache -s \$SOCKET -S -M 0600 -C 32 -F 1 -- /usr/bin/php-cgi"
EOF
```
```shell
# изменяем юнит файл
```
```text
cat <<EOF> /etc/systemd/system/spawn-fcgi.service
[Unit]
Description=Spawn-fcgi startup service by Otus
After=network.target
[Service]
Type=simple
PIDFile=/var/run/spawn-fcgi.pid
EnvironmentFile=/etc/sysconfig/spawn-fcgi
ExecStart=/usr/bin/spawn-fcgi -n \$OPTIONS
KillMode=process
[Install]
WantedBy=multi-user.target
EOF
```
```shell
# проверяем
#systemctl start spawn-fcgi
#systemctl status spawn-fcgi
********************************************************************************
# 3. Дополнить юнит-файл apache httpd возможностью запустить несколько
# инстансов сервера с разными конфигами
********************************************************************************

# Для запуска нескольких экземпляров сервиса будем использовать шаблон в
# конфигурации файла окружения /usr/lib/systemd/system/httpd.service
sed -i '/ExecStart/i\EnvironmentFile=/etc/sysconfig/httpd-%I' /usr/lib/systemd/system/httpd.service

# создаем два файла окружения httpd-first и httpd-second
```
```text
cat <<EOF> /etc/sysconfig/httpd-first
OPTIONS=-f conf/first.conf
EOF
cat <<EOF> /etc/sysconfig/httpd-second
OPTIONS=-f conf/second.conf
EOF
```
```shell
# Соответственно в директории с конфигами httpd (/etc/httpd/conf)
# создаем два конфига first.conf и second.conf
yes | cp -f --preserv /etc/httpd/conf/httpd.conf /etc/httpd/conf/first.conf
sed -i '/Listen 80/i\PidFile /var/run/httpd-first.pid' /etc/httpd/conf/first.conf

yes | cp -f --preserv /etc/httpd/conf/httpd.conf /etc/httpd/conf/second.conf
sed -i '/Listen 80/i\PidFile /var/run/httpd-second.pid' /etc/httpd/conf/second.conf
sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/second.conf
systemctl daemon-reload
# запустим и проверим
#systemctl start httpd@first
#systemctl start httpd@second
#ss -tnulp | grep httpd
```
</details>

_# запускаем Vagrantfile (/homework/08/Vagrantfile) - 'vagrant destroy -f && vagrant up'_
_# после того как ВМ полностью загрузится (5-10мин) подключаемся - 'vagrant ssh'_
_# проводим проверку результатов:_

# проверка 1 части
# вводим эти команды:
sudo -i
systemctl start watchlog.service
systemctl start watchlog.timer
tail -f /var/log/messages
## результат:
```shell
Dec  6 05:18:08 nginx systemd[1]: Starting My watchlog service...
Dec  6 05:18:08 nginx root[2328]: Wed Dec  6 05:18:08 EST 2023: I found word, Master!
Dec  6 05:18:08 nginx systemd[1]: watchlog.service: Succeeded.
Dec  6 05:18:08 nginx systemd[1]: Started My watchlog service.
...
Dec  6 05:18:58 nginx systemd[1]: Starting My watchlog service...
Dec  6 05:18:58 nginx root[2354]: Wed Dec  6 05:18:58 EST 2023: I found word, Master!
Dec  6 05:18:58 nginx systemd[1]: watchlog.service: Succeeded.
Dec  6 05:18:58 nginx systemd[1]: Started My watchlog service.
```
## проверка 2 части
## вводим эти команды:
systemctl start spawn-fcgi
systemctl status spawn-fcgi
## результат:
```shell
● spawn-fcgi.service - Spawn-fcgi startup service by Otus
   Loaded: loaded (/etc/systemd/system/spawn-fcgi.service; disabled; vendor preset: disabled)
   Active: active (running) since Wed 2023-12-06 06:11:42 EST; 8s ago
 Main PID: 36170 (php-cgi)
    Tasks: 33 (limit: 12221)
   Memory: 18.9M
   CGroup: /system.slice/spawn-fcgi.service
           ├─36170 /usr/bin/php-cgi
           ├─36173 /usr/bin/php-cgi
           ├─36174 /usr/bin/php-cgi
           ├─36175 /usr/bin/php-cgi
           ├─36176 /usr/bin/php-cgi
           ├─36177 /usr/bin/php-cgi
           ├─36178 /usr/bin/php-cgi
           ├─36179 /usr/bin/php-cgi
           ├─36180 /usr/bin/php-cgi
           ├─36181 /usr/bin/php-cgi
           ├─36182 /usr/bin/php-cgi
           ├─36183 /usr/bin/php-cgi
           ├─36184 /usr/bin/php-cgi
           ├─36185 /usr/bin/php-cgi
           ├─36186 /usr/bin/php-cgi
           ├─36187 /usr/bin/php-cgi
```
## проверка 3 части
## вводим эти команды:
systemctl start httpd@second
systemctl start httpd@first
ss -tnulp | grep httpd
## результат:
```shell
tcp   LISTEN 0      511           0.0.0.0:8080       0.0.0.0:*    users:(("httpd",pid=37625,fd=3),("httpd",pid=37624,fd=3),("httpd",pid=37623,fd=3),("httpd",pid=37619,fd=3))
tcp   LISTEN 0      511           0.0.0.0:80         0.0.0.0:*    users:(("httpd",pid=37875,fd=3),("httpd",pid=37874,fd=3),("httpd",pid=37873,fd=3),("httpd",pid=37866,fd=3))
```
