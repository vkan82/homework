#!/bin/bash
sudo -i

#***************************************************************
# 1. wathlog
#***************************************************************

# создаём файл с конфигурацией для сервиса в /etc/sysconfig
cat <<EOF> /etc/sysconfig/watchlog
# Configuration file for my watchlog service
# Place it to /etc/sysconfig
# File and word in that file that we will be monit
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

#sleep 2m
# после 2 минуты выводим 30 последних строк лога 
#tail -30 /var/log/messages

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

#*******************************************************************************
# 3. Дополнить юнит-файл apache httpd возможностью запустить несколько
# инстансов сервера с разными конфигами
#*******************************************************************************

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
