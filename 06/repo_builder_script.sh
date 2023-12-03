#!/bin/bash

sudo su
#Устанавливаем необходимые пакеты для создания репозитория:
yum install -y \
    redhat-lsb-core \
    wget \
    rpmdevtools \
    rpm-build \
    createrepo \
    yum-utils \
    gcc
    
#Cкачиваем и разархивируем исходники для openssl, который также потребуется для сборки:
wget https://www.openssl.org/source/openssl-1.1.1w.tar.gz -O /root/openssl-1.1.1w.tar.gz
tar -xvf /root/openssl-1.1.1w.tar.gz -C /root/

#Скачиваем SRPM пакет NGINX для дальнейшей работы над ним:
wget https://nginx.org/packages/centos/8/SRPMS/nginx-1.20.2-1.el8.ngx.src.rpm -O /root/nginx-1.20.2-1.el8.ngx.src.rpm

#Добавляем пользователя и группу builder:
useradd builder
groupadd builder

#Устанавливаем SRPM пакет для создания дерева каталогов для сборки:
rpm -i /root/nginx-1.20.2-1.el8.ngx.src.rpm

#Заранее поставим все зависимости чтобы в процессе сборки не было ошибок:
yes | yum-builddep /root/rpmbuild/SPECS/nginx.spec

#Скачиваем уже готовый spec файл и заменяем им текущий, он собирает NGINX с необходимыми нам опциями:
wget https://raw.githubusercontent.com/vkan82/homework/main/06/nginx.spec -O /root/rpmbuild/SPECS/nginx.spec

#Устанавливаем SRPM пакет для создания дерева каталогов для сборки:
rpm -i /root/nginx-1.20.2-1.el8.ngx.src.rpm

#Приступаем к сборке RPM пакета:
rpmbuild -bb /root/rpmbuild/SPECS/nginx.spec

#Установливаем собранный пакет и запускаем nginx:
yum localinstall -y /root/rpmbuild/RPMS/x86_64/nginx-1.20.2-1.el8.ngx.x86_64.rpm
systemctl enable nginx
systemctl start nginx

#Создаем свой репозиторий. Создадим там каталог repo в /usr/share/nginx/html :
mkdir -p /usr/share/nginx/html/repo

#Копируем туда собранный RPM и, например, RPM для установки репозитория Percona-Server:
cp /root/rpmbuild/RPMS/x86_64/nginx-1.20.2-1.el8.ngx.x86_64.rpm /usr/share/nginx/html/repo/
wget https://downloads.percona.com/downloads/percona-release/percona-release-1.0-6/redhat/percona-release-1.0-6.noarch.rpm -O /usr/share/nginx/html/repo/percona-release-0.1-6.noarch.rpm

#Инициализируем репозиторий командой:
createrepo /usr/share/nginx/html/repo/

#В location / в файле /etc/nginx/conf.d/default.conf добавим директиву autoindex on:
sed -i 's@index.htm;@index.htm;\n        autoindex on;@g' /etc/nginx/conf.d/default.conf

nginx -s reload
