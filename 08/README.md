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
```text
#!/bin/bash
sudo -i

# 1. watchlog
# создаём файл с конфигурацией для сервиса в /etc/sysconfig
cat <<EOF> /etc/sysconfig/watchlog
# Configuration file for my watchlog service
# Place it to /etc/sysconfig
# File and word in that file that we will be monitored
WORD="ALERT"
LOG=/var/log/watchlog.log
EOF
# создаем /var/log/watchlog.log и пишем туда ключевое слово ‘ALERT’
echo "ALERT" > /var/log/watchlog.log

# создаем скрипт
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
chmod +x /opt/watchlog.sh

# Создаем юнит для сервиса
cat <<EOF> /etc/systemd/system/watchlog.service
[Unit]
Description=My watchlog service
[Service]
Type=oneshot
EnvironmentFile=/etc/sysconfig/watchlog
ExecStart=/opt/watchlog.sh \$WORD \$LOG
EOF

# Создаем юнит для таймера
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
systemctl stop NetworkManager

# запускаем сервис и таймер
#systemctl start watchlog.service
#systemctl start watchlog.timer

# проверяем
#tail -f /var/log/messages

# 2. установить spawn-fcgi и переписать init-скрипт на unit-файл
# Устанавливаем spawn-fcgi и необходимые для него пакеты
yum install -y epel-release
yum install -y spawn-fcgi
yum -y install php
yum -y install httpd
yum -y install php
yum install php-cli
yum install -y mod_fcgid

# изменяем cам Init скрипт
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
# изменяем юнит файл
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
# проверяем
#systemctl start spawn-fcgi
#systemctl status spawn-fcgi

# 3. Дополнить юнит-файл apache httpd возможностью запустить несколько
# инстансов сервера с разными конфигами
# Для запуска нескольких экземпляров сервиса будем использовать шаблон в
# конфигурации файла окружения /usr/lib/systemd/system/httpd.service
sed -i '/ExecStart/i\EnvironmentFile=/etc/sysconfig/httpd-%I' /usr/lib/systemd/system/httpd.service

# создаем два файла окружения httpd-first и httpd-second
cat <<EOF> /etc/sysconfig/httpd-first
OPTIONS=-f conf/first.conf
EOF
cat <<EOF> /etc/sysconfig/httpd-second
OPTIONS=-f conf/second.conf
EOF
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
## вводим эти команды:
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
# проверка 2 части
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
# проверка 3 части
## вводим эти команды:
systemctl start httpd@second
systemctl start httpd@first
ss -tnulp | grep httpd
## результат:
```shell
tcp   LISTEN 0      511           0.0.0.0:8080       0.0.0.0:*    users:(("httpd",pid=37625,fd=3),("httpd",pid=37624,fd=3),("httpd",pid=37623,fd=3),("httpd",pid=37619,fd=3))
tcp   LISTEN 0      511           0.0.0.0:80         0.0.0.0:*    users:(("httpd",pid=37875,fd=3),("httpd",pid=37874,fd=3),("httpd",pid=37873,fd=3),("httpd",pid=37866,fd=3))
```
