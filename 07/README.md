# Загрузка системы

********************************************************************************
* Попасть в систему без пароля несколькими способами
********************************************************************************
Загружаем ВМ с помощью Vagrantfile (/homework/07/Vagrantfile), используем образ "generic/centos7".
````shell
vagrant destroy -f && vagrant up
````
1. Первый способ init=/bin/sh:

* при загрузке GRUB меню жмем `e` для перехода к редактированию параметров загрузки
* в конце строки, начинающейся с `linux16`
* добавляем `init=/bin/sh`
* жмем `Ctrl+x`, чтобы загрузка продолжилась с установленными опциями.
* попадаем в однопользовательский режим. Наша корневая файловая система смонтирована
* в режиме Read-Only, чтобы попасть в режим записи:
* перемонтируем файловую систему с правами записи  `mount -o remount,rw /`
* проверяем права на запись `mount | grep root`
* перезагружаем ВМ `reboot -f`.

![img](https://github.com/vkan82/homework/blob/main/07/img/001.png)

![img](https://github.com/vkan82/homework/blob/main/07/img/002.png)

![img](https://github.com/vkan82/homework/blob/main/07/img/003.png)

2. Второй способ rd.break:
* при загрузке GRUB меню жмем `e` для перехода к редактированию параметров загрузки
* в конце строки, начинающейся с `linux16`
* добавляем `rd.break`
* жмем `Ctrl+x`, чтобы загрузка продолжилась с установленными опциями.
* попадаем в emergency mode. Наша корневая файловая система смонтирована
* в режиме Read-Only, но мы не в ней. Чтобы попасть в нее и поменять
* пароль администратора:
* перемонтируем файловую систему в sysroot `mount -o remount,rw /sysroot`
* выполняем `chroot /sysroot`
* меняем пароль `passwd root`
* обновляем весь контекст SELinux `touch /.autorelabel`
* выполнить `exit`
* выполнить `exit`
* перезагружаем ВМ `reboot -f`.

![img](https://github.com/vkan82/homework/blob/main/07/img/004.png)

![img](https://github.com/vkan82/homework/blob/main/07/img/005.png)

![img](https://github.com/vkan82/homework/blob/main/07/img/006.png)

2. Третий способ rw init=/sysroot/bin/sh:
* также при загрузке GRUB меню жмем `e` для перехода к редактированию параметров загрузки
* в строке начинающейся с `linux16` заменяем `ro` на `rw init=/sysroot/bin/sh`
* жмем `Ctrl+x`, чтобы загрузка продолжилась с установленными опциями.
* Наша корневая файловая система смонтирована сразу в режиме Read-Write.
* В прошлых примерах тоже можно заменить `ro` на `rw`.

![img](https://github.com/vkan82/homework/blob/main/07/img/007.png)

![img](https://github.com/vkan82/homework/blob/main/07/img/008.png)

* в общем все три способа похожи, по сути все три способа не дают загрузиться init процессу,
* при этом загружаются минимальные сервисы и файловая система, 1 и 3 способы
* загружают систему в оболочку `sh`, а `rd.break` прерывает загрузку ситемы и загружает `emergency mode`
* после появляется возможность загрузить корневую систему в режиме записи и изменять настройки.

********************************************************************************
# Установить систему с LVM, после чего переименовать VG
********************************************************************************
* Запускаем ВМ:
```shell
vkan@l04-ubuntu:~/Documents/DZ/loading$ vagrant up
Bringing machine 'default' up with 'virtualbox' provider...
==> default: Importing base box 'generic/centos7'...
==> default: Matching MAC address for NAT networking...
...
vkan@l04-ubuntu:~/Documents/DZ/loading$ vagrant ssh
Last login: Mon Dec  4 05:20:41 2023 from 10.0.2.2
[vagrant@loading ~]$ sudo -i
```
* посмотрим текущее состояние системы:
```shell
[root@loading ~]# vgs
  VG             #PV #LV #SN Attr   VSize    VFree
  centos_centos7   1   2   0 wz--n- <127,00g    0
```
* Переименуем Volume Group:
```shell
[root@centos7 ~]# vgrename centos_centos7 OtusRoot
  Volume group "centos_centos7" successfully renamed to "OtusRoot"
```
* Далее правим /etc/fstab, /etc/default/grub, /boot/grub2/grub.cfg. Везде заменяем старое
* название на новое:
```shell
  [root@centos7 ~]# nano /etc/fstab
  [root@centos7 ~]# nano /boot/grub2/grub.cfg
  [root@centos7 ~]# nano /etc/default/grub
```
* Пересоздаем `initrd image`, чтобы он знал новое название Volume Group:
```shell
  [root@centos7 ~]# mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)
  Executing: /sbin/dracut -f -v /boot/initramfs-3.10.0-1160.102.1.el7.x86_64.img 3.10.0-1160.102.1.el7.x86_64
  dracut module 'modsign' will not be installed, because command 'keyctl' could not be found!
...
  *** Creating initramfs image file '/boot/initramfs-3.10.0-1160.102.1.el7.x86_64.img' done ***
  [root@centos7 ~]# vgs
    VG       #PV #LV #SN Attr   VSize    VFree
    OtusRoot   1   2   0 wz--n- <127,00g    0
```
********************************************************************************
# Добавить модуль в initrd
********************************************************************************
* Скрипты модулей хранятся в каталоге `/usr/lib/dracut/modules.d/`. Для того чтобы
* добавить свой модуль создаем там папку с именем `01test`:
```shell
  [root@centos7 ~]# mkdir /usr/lib/dracut/modules.d/01test
  [root@centos7 01test]# nano module-setup.sh
  [root@centos7 01test]# nano test.sh
  [root@centos7 01test]# dracut -f -v
  Executing: /sbin/dracut -f -v
  dracut module 'modsign' will not be installed, because command 'keyctl' could not be found!
  dracut module 'busybox' will not be installed, because command 'busybox' could not be found!
...
  *** Creating image file done ***
  *** Creating initramfs image file '/boot/initramfs-3.10.0-1160.102.1.el7.x86_64.img' done ***
  [root@centos7 01test]# lsinitrd -m /boot/initramfs-$(uname -r).img | grep test
  test
```

![img](https://github.com/vkan82/homework/blob/main/07/img/009.png)
