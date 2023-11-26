#  ZFS
********************************************************************************
1. _Определить алгоритм с наилучшим сжатием._
********************************************************************************
Запускаем ВМ с помощью Vagrantfile (/homework/04/Vagrantfile).
Подключаемся с помощью vagrant ssh.
Ниже процесс определения алгоритма с наилучшим сжатием, команды и вывод результатов:

```shell
vkan@l04-ubuntu:~/Documents/DZ/zfs$ vagrant ssh
[vagrant@zfs ~]$ sudo -i
[root@zfs ~]# lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   40G  0 disk
-sda1   8:1    0   40G  0 part /
sdb      8:16   0  512M  0 disk
sdc      8:32   0  512M  0 disk
sdd      8:48   0  512M  0 disk
sde      8:64   0  512M  0 disk
sdf      8:80   0  512M  0 disk
sdg      8:96   0  512M  0 disk
sdh      8:112  0  512M  0 disk
sdi      8:128  0  512M  0 disk
```
_# Создаем 4 пары RAID1_
```shell
[root@zfs ~]# zpool create otus1 mirror /dev/sdb /dev/sdc
[root@zfs ~]# zpool create otus2 mirror /dev/sdd /dev/sde
[root@zfs ~]# zpool create otus3 mirror /dev/sdf /dev/sdg
[root@zfs ~]# zpool create otus4 mirror /dev/sdh /dev/sdi
[root@zfs ~]# zpool list
NAME    SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
otus1   480M  91.5K   480M        -         -     0%     0%  1.00x    ONLINE  -
otus2   480M  91.5K   480M        -         -     0%     0%  1.00x    ONLINE  -
otus3   480M  91.5K   480M        -         -     0%     0%  1.00x    ONLINE  -
otus4   480M  91.5K   480M        -         -     0%     0%  1.00x    ONLINE  -
[root@zfs ~]# zpool status otus1
  pool: otus1
 state: ONLINE
  scan: none requested
config:

	NAME        STATE     READ WRITE CKSUM
	otus1       ONLINE       0     0     0
	  mirror-0  ONLINE       0     0     0
	    sdb     ONLINE       0     0     0
	    sdc     ONLINE       0     0     0

errors: No known data errors
```
_# Добавим разные алгоритмы сжатия (lzjb, lz4, gzip-9, zle) в каждую файловую систему:_
```shell
[root@zfs ~]# zfs set compression=lzjb otus1
[root@zfs ~]# zfs set compression=lz4 otus2
[root@zfs ~]# zfs set compression=gzip-9 otus3
[root@zfs ~]# zfs set compression=zle otus4
[root@zfs ~]# zfs get all | grep compression
otus1  compression           lzjb                   local
otus2  compression           lz4                    local
otus3  compression           gzip-9                 local
otus4  compression           zle                    local
```
_# Скачаем на каждый пул один файл (книга "Война и мир"):_
```shell
[root@zfs ~]# for i in {1..4}; do wget -P /otus$i http://www.gutenberg.org/ebooks/2600.txt.utf-8; done
--2023-11-26 09:19:56--  http://www.gutenberg.org/ebooks/2600.txt.utf-8
Resolving www.gutenberg.org (www.gutenberg.org)... 152.19.134.47, 2610:28:3090:3000:0:bad:cafe:47
Connecting to www.gutenberg.org (www.gutenberg.org)|152.19.134.47|:80... connected.
HTTP request sent, awaiting response... 302 Found
Location: https://www.gutenberg.org/ebooks/2600.txt.utf-8 [following]
--2023-11-26 09:19:57--  https://www.gutenberg.org/ebooks/2600.txt.utf-8
Connecting to www.gutenberg.org (www.gutenberg.org)|152.19.134.47|:443... connected.
HTTP request sent, awaiting response... 302 Found
Location: http://www.gutenberg.org/cache/epub/2600/pg2600.txt [following]
--2023-11-26 09:19:59--  http://www.gutenberg.org/cache/epub/2600/pg2600.txt
Connecting to www.gutenberg.org (www.gutenberg.org)|152.19.134.47|:80... connected.
HTTP request sent, awaiting response... 302 Found
Location: https://www.gutenberg.org/cache/epub/2600/pg2600.txt [following]
--2023-11-26 09:20:00--  https://www.gutenberg.org/cache/epub/2600/pg2600.txt
Connecting to www.gutenberg.org (www.gutenberg.org)|152.19.134.47|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 3359630 (3.2M) [text/plain]
Saving to: '/otus1/2600.txt.utf-8'

100%[===========================================================>] 3,359,630    540KB/s   in 7.3s   

2023-11-26 09:20:09 (449 KB/s) - '/otus1/2600.txt.utf-8' saved [3359630/3359630]

--2023-11-26 09:20:09--  http://www.gutenberg.org/ebooks/2600.txt.utf-8
Resolving www.gutenberg.org (www.gutenberg.org)... 152.19.134.47, 2610:28:3090:3000:0:bad:cafe:47
Connecting to www.gutenberg.org (www.gutenberg.org)|152.19.134.47|:80... connected.
HTTP request sent, awaiting response... 302 Found
Location: https://www.gutenberg.org/ebooks/2600.txt.utf-8 [following]
--2023-11-26 09:20:10--  https://www.gutenberg.org/ebooks/2600.txt.utf-8
Connecting to www.gutenberg.org (www.gutenberg.org)|152.19.134.47|:443... connected.
HTTP request sent, awaiting response... 302 Found
Location: http://www.gutenberg.org/cache/epub/2600/pg2600.txt [following]
--2023-11-26 09:20:11--  http://www.gutenberg.org/cache/epub/2600/pg2600.txt
Connecting to www.gutenberg.org (www.gutenberg.org)|152.19.134.47|:80... connected.
HTTP request sent, awaiting response... 302 Found
Location: https://www.gutenberg.org/cache/epub/2600/pg2600.txt [following]
--2023-11-26 09:20:12--  https://www.gutenberg.org/cache/epub/2600/pg2600.txt
Connecting to www.gutenberg.org (www.gutenberg.org)|152.19.134.47|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 3359630 (3.2M) [text/plain]
Saving to: '/otus2/2600.txt.utf-8'

100%[===========================================================>] 3,359,630    367KB/s   in 12s    

2023-11-26 09:20:25 (280 KB/s) - '/otus2/2600.txt.utf-8' saved [3359630/3359630]

--2023-11-26 09:20:25--  http://www.gutenberg.org/ebooks/2600.txt.utf-8
Resolving www.gutenberg.org (www.gutenberg.org)... 152.19.134.47, 2610:28:3090:3000:0:bad:cafe:47
Connecting to www.gutenberg.org (www.gutenberg.org)|152.19.134.47|:80... connected.
HTTP request sent, awaiting response... 302 Found
Location: https://www.gutenberg.org/ebooks/2600.txt.utf-8 [following]
--2023-11-26 09:20:26--  https://www.gutenberg.org/ebooks/2600.txt.utf-8
Connecting to www.gutenberg.org (www.gutenberg.org)|152.19.134.47|:443... connected.
HTTP request sent, awaiting response... 302 Found
Location: http://www.gutenberg.org/cache/epub/2600/pg2600.txt [following]
--2023-11-26 09:20:27--  http://www.gutenberg.org/cache/epub/2600/pg2600.txt
Connecting to www.gutenberg.org (www.gutenberg.org)|152.19.134.47|:80... connected.
HTTP request sent, awaiting response... 302 Found
Location: https://www.gutenberg.org/cache/epub/2600/pg2600.txt [following]
--2023-11-26 09:20:28--  https://www.gutenberg.org/cache/epub/2600/pg2600.txt
Connecting to www.gutenberg.org (www.gutenberg.org)|152.19.134.47|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 3359630 (3.2M) [text/plain]
Saving to: '/otus3/2600.txt.utf-8'

100%[===========================================================>] 3,359,630    356KB/s   in 12s    

2023-11-26 09:20:41 (274 KB/s) - '/otus3/2600.txt.utf-8' saved [3359630/3359630]

--2023-11-26 09:20:41--  http://www.gutenberg.org/ebooks/2600.txt.utf-8
Resolving www.gutenberg.org (www.gutenberg.org)... 152.19.134.47, 2610:28:3090:3000:0:bad:cafe:47
Connecting to www.gutenberg.org (www.gutenberg.org)|152.19.134.47|:80... connected.
HTTP request sent, awaiting response... 302 Found
Location: https://www.gutenberg.org/ebooks/2600.txt.utf-8 [following]
--2023-11-26 09:20:42--  https://www.gutenberg.org/ebooks/2600.txt.utf-8
Connecting to www.gutenberg.org (www.gutenberg.org)|152.19.134.47|:443... connected.
HTTP request sent, awaiting response... 302 Found
Location: http://www.gutenberg.org/cache/epub/2600/pg2600.txt [following]
--2023-11-26 09:20:43--  http://www.gutenberg.org/cache/epub/2600/pg2600.txt
Connecting to www.gutenberg.org (www.gutenberg.org)|152.19.134.47|:80... connected.
HTTP request sent, awaiting response... 302 Found
Location: https://www.gutenberg.org/cache/epub/2600/pg2600.txt [following]
--2023-11-26 09:20:44--  https://www.gutenberg.org/cache/epub/2600/pg2600.txt
Connecting to www.gutenberg.org (www.gutenberg.org)|152.19.134.47|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 3359630 (3.2M) [text/plain]
Saving to: '/otus4/2600.txt.utf-8'

100%[===========================================================>] 3,359,630    513KB/s   in 8.7s   

2023-11-26 09:20:54 (376 KB/s) - '/otus4/2600.txt.utf-8' saved [3359630/3359630]

[root@zfs ~]# ls -l /otus*
/otus1:
total 2443
-rw-r--r--. 1 root root 3359630 Nov  2 08:09 2600.txt.utf-8

/otus2:
total 2041
-rw-r--r--. 1 root root 3359630 Nov  2 08:09 2600.txt.utf-8

/otus3:
total 1239
-rw-r--r--. 1 root root 3359630 Nov  2 08:09 2600.txt.utf-8

/otus4:
total 3287
-rw-r--r--. 1 root root 3359630 Nov  2 08:09 2600.txt.utf-8
```
_# Проверим, сколько места занимает один и тот же файл в разных пулах и проверим степень сжатия файлов:_
```shell
[root@zfs ~]# zfs list
NAME    USED  AVAIL     REFER  MOUNTPOINT
otus1  2.48M   350M     2.41M  /otus1
otus2  2.09M   350M     2.02M  /otus2
otus3  1.30M   351M     1.23M  /otus3
otus4  3.30M   349M     3.23M  /otus4
[root@zfs ~]# zfs get all | grep compressratio | grep -v ref
otus1  compressratio         1.35x                  -
otus2  compressratio         1.62x                  -
otus3  compressratio         2.64x                  -
otus4  compressratio         1.01x                  -
```
_# Таким образом видно, что максимальную степень сжатия имеет алгоритм gzip-9._

********************************************************************************
2. _Определить настройки pool’a._
********************************************************************************
_# Скачиваем архив в домашний каталог:_
```shell
[root@zfs ~]# wget -O archive.tar.gz --no-check-certificate 'https://drive.google.com/u/0/uc?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg&export=download'
--2023-11-26 09:49:27--  https://drive.google.com/u/0/uc?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg&export=download
Resolving drive.google.com (drive.google.com)... 216.58.215.110, 2a00:1450:401b:807::200e
Connecting to drive.google.com (drive.google.com)|216.58.215.110|:443... connected.
HTTP request sent, awaiting response... 302 Found
Location: https://drive.google.com/uc?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg&export=download [following]
--2023-11-26 09:49:28--  https://drive.google.com/uc?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg&export=download
Reusing existing connection to drive.google.com:443.
HTTP request sent, awaiting response... 303 See Other
Location: https://doc-0c-bo-docs.googleusercontent.com/docs/securesc/ha0ro937gcuc7l7deffksulhg5h7mbp1/49evt28d3mkbf44p0kbmv3h5avn0o7te/1700992125000/16189157874053420687/*/1KRBNW33QWqbvbVHa3hLJivOAt60yukkg?e=download&uuid=668a9e40-c57d-408d-9b43-ba0551e06191 [following]
Warning: wildcards not supported in HTTP.
--2023-11-26 09:49:35--  https://doc-0c-bo-docs.googleusercontent.com/docs/securesc/ha0ro937gcuc7l7deffksulhg5h7mbp1/49evt28d3mkbf44p0kbmv3h5avn0o7te/1700992125000/16189157874053420687/*/1KRBNW33QWqbvbVHa3hLJivOAt60yukkg?e=download&uuid=668a9e40-c57d-408d-9b43-ba0551e06191
Resolving doc-0c-bo-docs.googleusercontent.com (doc-0c-bo-docs.googleusercontent.com)... 142.250.203.193, 2a00:1450:401b:810::2001
Connecting to doc-0c-bo-docs.googleusercontent.com (doc-0c-bo-docs.googleusercontent.com)|142.250.203.193|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 7275140 (6.9M) [application/x-gzip]
Saving to: 'archive.tar.gz'

100%[===========================================================>] 7,275,140   3.61MB/s   in 1.9s   

2023-11-26 09:49:38 (3.61 MB/s) - 'archive.tar.gz' saved [7275140/7275140]
```
_# Разархивируем его:_
```shell
[root@zfs ~]# tar -xzvf archive.tar.gz
zpoolexport/
zpoolexport/filea
zpoolexport/fileb
[root@zfs ~]# zpool import -d zpoolexport/
   pool: otus
     id: 6554193320433390805
  state: ONLINE
 action: The pool can be imported using its name or numeric identifier.
 config:

	otus                         ONLINE
	  mirror-0                   ONLINE
	    /root/zpoolexport/filea  ONLINE
	    /root/zpoolexport/fileb  ONLINE
```
_# Проверим, возможно ли импортировать данный каталог в пул и имортируем в ОС:_

```shell
[root@zfs ~]# zpool import -d zpoolexport/ otus
[root@zfs ~]# zpool status
  pool: otus
 state: ONLINE
  scan: none requested
config:

	NAME                         STATE     READ WRITE CKSUM
	otus                         ONLINE       0     0     0
	  mirror-0                   ONLINE       0     0     0
	    /root/zpoolexport/filea  ONLINE       0     0     0
	    /root/zpoolexport/fileb  ONLINE       0     0     0

errors: No known data errors
```
_# Определим настройки, запросим сразу все параметры файловой системы и конкретные параметры:
```shell
[root@zfs ~]# zpool get all otus
NAME  PROPERTY                       VALUE                          SOURCE
otus  size                           480M                           -
otus  capacity                       0%                             -
otus  altroot                        -                              default
otus  health                         ONLINE                         -
otus  guid                           6554193320433390805            -
otus  version                        -                              default
otus  bootfs                         -                              default
otus  delegation                     on                             default
otus  autoreplace                    off                            default
otus  cachefile                      -                              default
otus  failmode                       wait                           default
otus  listsnapshots                  off                            default
otus  autoexpand                     off                            default
otus  dedupditto                     0                              default
otus  dedupratio                     1.00x                          -
otus  free                           478M                           -
otus  allocated                      2.09M                          -
otus  readonly                       off                            -
otus  ashift                         0                              default
otus  comment                        -                              default
otus  expandsize                     -                              -
otus  freeing                        0                              -
otus  fragmentation                  0%                             -
otus  leaked                         0                              -
otus  multihost                      off                            default
otus  checkpoint                     -                              -
otus  load_guid                      16780452652612013518           -
otus  autotrim                       off                            default
otus  feature@async_destroy          enabled                        local
otus  feature@empty_bpobj            active                         local
otus  feature@lz4_compress           active                         local
otus  feature@multi_vdev_crash_dump  enabled                        local
otus  feature@spacemap_histogram     active                         local
otus  feature@enabled_txg            active                         local
otus  feature@hole_birth             active                         local
otus  feature@extensible_dataset     active                         local
otus  feature@embedded_data          active                         local
otus  feature@bookmarks              enabled                        local
otus  feature@filesystem_limits      enabled                        local
otus  feature@large_blocks           enabled                        local
otus  feature@large_dnode            enabled                        local
otus  feature@sha512                 enabled                        local
otus  feature@skein                  enabled                        local
otus  feature@edonr                  enabled                        local
otus  feature@userobj_accounting     active                         local
otus  feature@encryption             enabled                        local
otus  feature@project_quota          active                         local
otus  feature@device_removal         enabled                        local
otus  feature@obsolete_counts        enabled                        local
otus  feature@zpool_checkpoint       enabled                        local
otus  feature@spacemap_v2            active                         local
otus  feature@allocation_classes     enabled                        local
otus  feature@resilver_defer         enabled                        local
otus  feature@bookmark_v2            enabled                        local
[root@zfs ~]# zfs get available otus
NAME  PROPERTY   VALUE  SOURCE
otus  available  350M   -
[root@zfs ~]# zfs get readonly otus
NAME  PROPERTY  VALUE   SOURCE
otus  readonly  off     default
[root@zfs ~]# zfs get recordsize otus
NAME  PROPERTY    VALUE    SOURCE
otus  recordsize  128K     local
[root@zfs ~]# zfs get compression otus
NAME  PROPERTY     VALUE     SOURCE
otus  compression  zle       local
[root@zfs ~]# zfs get checksum otus
NAME  PROPERTY  VALUE      SOURCE
otus  checksum  sha256     local
```
_Командами zfs определил настройки:
    размер хранилища = 480M
    тип pool = mirror-0
    значение recordsize = 128K
    какое сжатие используется = zle
    какая контрольная сумма используется = sha256
    файл с описанием настроек settings = вывод zfs get all otus

********************************************************************************
3. _Найти сообщение от преподавателей. Работа со снапшотом._
********************************************************************************
_# Скачаем файл, указанный в задании:_
```shell
[root@zfs ~]# wget -O otus_task2.file --no-check-certificate "https://drive.google.com/u/0/uc?id=1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG&export=download"
--2023-11-26 10:07:01--  https://drive.google.com/u/0/uc?id=1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG&export=download
Resolving drive.google.com (drive.google.com)... 142.250.186.206, 2a00:1450:401b:806::200e
Connecting to drive.google.com (drive.google.com)|142.250.186.206|:443... connected.
HTTP request sent, awaiting response... 302 Found
Location: https://drive.google.com/uc?id=1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG&export=download [following]
--2023-11-26 10:07:02--  https://drive.google.com/uc?id=1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG&export=download
Reusing existing connection to drive.google.com:443.
HTTP request sent, awaiting response... 303 See Other
Location: https://doc-00-bo-docs.googleusercontent.com/docs/securesc/ha0ro937gcuc7l7deffksulhg5h7mbp1/vc6ob0rb3v2g0n50r2lr9o5g66eiro3c/1700993175000/16189157874053420687/*/1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG?e=download&uuid=64a22a2e-f53a-4f62-8e70-1f24e9e517e9 [following]
Warning: wildcards not supported in HTTP.
--2023-11-26 10:07:06--  https://doc-00-bo-docs.googleusercontent.com/docs/securesc/ha0ro937gcuc7l7deffksulhg5h7mbp1/vc6ob0rb3v2g0n50r2lr9o5g66eiro3c/1700993175000/16189157874053420687/*/1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG?e=download&uuid=64a22a2e-f53a-4f62-8e70-1f24e9e517e9
Resolving doc-00-bo-docs.googleusercontent.com (doc-00-bo-docs.googleusercontent.com)... 142.250.203.193, 2a00:1450:401b:806::2001
Connecting to doc-00-bo-docs.googleusercontent.com (doc-00-bo-docs.googleusercontent.com)|142.250.203.193|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 5432736 (5.2M) [application/octet-stream]
Saving to: 'otus_task2.file'

100%[===========================================================>] 5,432,736   2.89MB/s   in 1.8s   

2023-11-26 10:07:10 (2.89 MB/s) - 'otus_task2.file' saved [5432736/5432736]
```
_# Восстановим файловую систему из снапшота:_
```shell
[root@zfs ~]# zfs receive otus/test@today < otus_task2.file
```
_# Далее, ищем файл с секретным сообщением в каталоге и просматриваем его содержимое:_
```shell
[root@zfs ~]# find /otus/test -name "secret_message"
/otus/test/task1/file_mess/secret_message
[root@zfs ~]# cat /otus/test/task1/file_mess/secret_message
https://github.com/sindresorhus/awesome

```
