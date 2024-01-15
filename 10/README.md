#  Управление процессами

## Написать свою реализацию `ps ax` используя анализ `/proc`

### Исходные данные

Вывод команды `ps ax` (для примера PID: 1)

```shell
vkan@l04-ubuntu:~/Documents/DZ/proc$ ps ax -q 1
    PID TTY      STAT   TIME COMMAND
      1 ?        Ss     0:02 /sbin/init splash

```

### Какие параметры `ps ax` где можно взять в `/proc`

#### PID

Столбец `PID` это сама поддиректория с номером процесса:

```shell
/proc/<PID>/
```

#### STAT
`STAT` показывает состояние процессов, состояния могут быть:

    D — беспробудный сон, ожидая ввод/вывод какого-нибудь устройства;
    I — бездействующий поток ядра;
    R — готов выполнятся или уже выполняется процессором;
    S — сон, ожидает каких-нибудь ресурсов;
    T — остановлен сигналом;
    t — остановлен дебагом;
    X — мертвый, никогда не должно быть видно;
    Z — зомби, мертвый но не погребенный, то есть не успел освободить pid;
    < — высокий приоритет;
    N — низкий приоритет;
    L — страницы процесса заблокированы в памяти;
    s — лидер сессии;
    l — многопоточный;
    + — выполняется на переднем плане, то есть это не фоновый процесс.
В столбце `STAT` основной показатель 3 в `/proc/1/stat`, но тажк есть дополнительные, возьмем наиболее распространенные `s,N,L,l,<,+`.

```shell
vkan@l04-ubuntu:~/Documents/DZ/proc$ awk '{ printf $3; \
      if ($19<0) {printf "<" } else if ($19>0) {printf "N"}; \
      if ($6 == $1) {printf "s"}; \
      if ($20>1) {printf "l"}}' /proc/1/stat;       [[ -n $Locked ]] && printf "L";       awk '{ if ($8!=-1) { printf "+" }}' /proc/1/stat
Ss
```


#### TIME

Столбец `TIME` это суммарное время 14, 15 показателей `/proc/1/stat`
```shell
vkan@l04-ubuntu:~/Documents/DZ/proc$ awk -v ticks="$(getconf CLK_TCK)" '{print strftime ("%M:%S", ($14+$15)/ticks)}' /proc/1/stat
00:02

```

#### COMMAND

Столбец `COMMAND` это содержание `/proc/1/cmdline`, либо `/proc/1/stat`

```shell
vkan@l04-ubuntu:~/Documents/DZ/proc$ awk '{ print $1 }' /proc/1/cmdline | sed 's/\x0/ /g'
/sbin/init splash
vkan@l04-ubuntu:~/Documents/DZ/proc$ strings -s' ' /proc/1/stat | awk '{ printf $2 }' | sed 's/(/[/; s/)/]/'
[systemd]
```

#### TTY

`TTY` парсится из `/proc/1/fd` и это 7 показатель `/proc/1/stat`

```shell
vkan@l04-ubuntu:~/Documents/DZ/proc$ awk '{ if ($7 == 0) {printf "?"} else { printf "'"$qq"'" }}' /proc/1/stat
?
vkan@l04-ubuntu:~/Documents/DZ/proc$ ps ax -q 1 -o tty
TT
?
?
```

### Результат

Сделать анализ директории `proc` и напечатать все выше перечисленное:

[Реализация разработанного скрипта](/homework/10/psax.sh)

```shell
#!/bin/bash

function list_process {
  for pid in $*
   do
     procpid=/proc/$pid
     if [[ -e $procpid/environ && -e $procpid/stat ]]; then

      # TIME in ps is (utime+stime)/CLK_TCK - (14) utime, (15) stime from /proc/$pid/stat
      Time=`awk -v ticks="$(getconf CLK_TCK)" '{print strftime ("%M:%S", ($14+$15)/ticks)}' $procpid/stat`      

      # Memory Locks
      Locked=`grep VmFlags $procpid/smaps | grep lo`

      #STAT данные из /proc/$pid/stat

      Stats=`awk '{ printf $3; \
      if ($19<0) {printf "<" } else if ($19>0) {printf "N"}; \
      if ($6 == $1) {printf "s"}; \
      if ($20>1) {printf "l"}}' $procpid/stat; \
      [[ -n $Locked ]] && printf "L"; \
      awk '{ if ($8!=-1) { printf "+" }}' $procpid/stat`

      # содержание из /proc/$pid/cmdline или /proc/$pid/stat

      Cmdline=`awk '{ print $1 }' $procpid/cmdline | sed 's/\x0/ /g'`
      [[ -z $Cmdline ]] && Cmdline=`strings -s' ' $procpid/stat | awk '{ printf $2 }' | sed 's/(/[/; s/)/]/'`

      # TTY парсится из /proc/$pid/fd
      qq=`ls -l $procpid/fd/ | grep -E '\/dev\/tty|pts' | cut -d\/ -f3,4 | uniq`
      Tty=`awk '{ if ($7 == 0) {printf "?"} else { printf "'"$qq"'" }}' $procpid/stat`

    fi
    # вывод
    printf  '%7d %-7s %-12s %s %-10s\n' "$pid" "$Tty" "$Stats" "$Time" "$Cmdline"
  done
}
ALLPIDS=`ls /proc | grep -P ^[0-9] | sort -n | xargs`
printf  '%7s %-7s %-12s %s %-10s\n' "PID" "TTY" "STAT" "TIME" "COMMAND"
list_process $ALLPIDS
```


[Результат вывода в консоль](/homework/10/psax.sh.log)

<details><summary>см. Результат вывода</summary>

```properties
PID TTY     STAT         TIME COMMAND   
  1 ?       Ss           00:02 /sbin/init splash
  2 ?       S            00:00 [kthreadd]
  3 ?       I<           00:00 [rcu_gp]  
  4 ?       I<           00:00 [rcu_par_gp]
  5 ?       I<           00:00 [slub_flushwq]
  6 ?       I<           00:00 [netns]   
  8 ?       I<           00:00 [kworker/0:0H-events_highpri]
 10 ?       I<           00:00 [mm_percpu_wq]
 11 ?       I            00:00 [rcu_tasks_kthread]
 12 ?       I            00:00 [rcu_tasks_rude_kthread]
 13 ?       I            00:00 [rcu_tasks_trace_kthread]
 14 ?       S            00:00 [ksoftirqd/0]
 15 ?       I            00:09 [rcu_preempt]
 16 ?       S            00:00 [migration/0]
 17 ?       S            00:00 [idle_inject/0]
 19 ?       S            00:00 [cpuhp/0]
 20 ?       S            00:00 [cpuhp/1]
 21 ?       S            00:00 [idle_inject/1]
 22 ?       S            00:00 [migration/1]
 23 ?       S            00:00 [ksoftirqd/1]
 25 ?       I<           00:00 [kworker/1:0H-events_highpri]
 26 ?       S            00:00 [cpuhp/2]
 27 ?       S            00:00 [idle_inject/2]
 28 ?       S            00:00 [migration/2]
 29 ?       S            00:00 [ksoftirqd/2]
 31 ?       I<           00:00 [kworker/2:0H-events_highpri]
 32 ?       S            00:00 [cpuhp/3]
 33 ?       S            00:00 [idle_inject/3]
 34 ?       S            00:00 [migration/3]
 35 ?       S            00:00 [ksoftirqd/3]
 37 ?       I<           00:00 [kworker/3:0H-events_highpri]
 38 ?       S            00:00 [cpuhp/4]
 39 ?       S            00:00 [idle_inject/4]
 40 ?       S            00:00 [migration/4]
 41 ?       S            00:00 [ksoftirqd/4]
 43 ?       I<           00:00 [kworker/4:0H-events_highpri]
 44 ?       S            00:00 [cpuhp/5]
 45 ?       S            00:00 [idle_inject/5]
 46 ?       S            00:00 [migration/5]
 47 ?       S            00:00 [ksoftirqd/5]
 49 ?       I<           00:00 [kworker/5:0H-events_highpri]
 50 ?       S            00:00 [kdevtmpfs]
 51 ?       I<           00:00 [inet_frag_wq]
 52 ?       S            00:00 [kauditd]
 53 ?       S            00:00 [khungtaskd]
 56 ?       S            00:00 [oom_reaper]
 57 ?       I<           00:00 [writeback]
 58 ?       S            00:00 [kcompactd0]
 59 ?       SN           00:00 [ksmd]    
 61 ?       SN           00:00 [khugepaged]
 62 ?       I<           00:00 [kintegrityd]
 63 ?       I<           00:00 [kblockd]
 64 ?       I<           00:00 [blkcg_punt_bio]
 65 ?       I<           00:00 [tpm_dev_wq]
 66 ?       I<           00:00 [ata_sff]
 67 ?       I<           00:00 [md]      
 68 ?       I<           00:00 [edac-poller]
 69 ?       I<           00:00 [devfreq_wq]
 70 ?       S            00:00 [watchdogd]
 71 ?       I<           00:00 [kworker/3:1H-kblockd]
 72 ?       S            00:00 [irq/25-AMD-Vi]
 73 ?       S            00:00 [kswapd0]
 74 ?       S            00:00 [ecryptfs-kthread]
 75 ?       I<           00:00 [kthrotld]
 76 ?       S            00:00 [irq/27-pciehp]
 77 ?       S            00:00 [irq/28-pciehp]
 78 ?       I            00:00 [kworker/1:1-events]
 79 ?       I            00:00 [kworker/2:1-events]
 82 ?       I<           00:00 [acpi_thermal_pm]
 83 ?       S            00:00 [hwrng]   
 84 ?       I<           00:00 [mld]     
 85 ?       I<           00:00 [ipv6_addrconf]
 94 ?       I<           00:00 [kstrp]   
 96 ?       I<           00:00 [zswap-shrink]
101 ?       I<           00:00 [charger_manager]
124 ?       I<           00:00 [kworker/2:1H-kblockd]
136 ?       I<           00:00 [kworker/4:1H-kblockd]
139 ?       I<           00:00 [kworker/5:1H-kblockd]
140 ?       I<           00:00 [kworker/1:1H-kblockd]
141 ?       I<           00:00 [kworker/0:1H-kblockd]
156 ?       S            00:20 [irq/32-SYNA30AD:00]
181 ?       S            00:00 [scsi_eh_0]
182 ?       I<           00:00 [scsi_tmf_0]
183 ?       S            00:00 [scsi_eh_1]
184 ?       I<           00:00 [scsi_tmf_1]
186 ?       S            00:00 [scsi_eh_2]
187 ?       I<           00:00 [scsi_tmf_2]
189 ?       S            00:00 [scsi_eh_3]
190 ?       I<           00:00 [scsi_tmf_3]
195 ?       I<           00:00 [nvme-wq]
196 ?       I<           00:00 [nvme-reset-wq]
197 ?       I<           00:00 [nvme-delete-wq]
198 ?       I<           00:00 [nvme-auth-wq]
218 ?       I<           00:00 [raid5wq]
250 ?       S            00:00 [jbd2/sda5-8]
251 ?       I<           00:00 [ext4-rsv-conver]
305 ?       S<s          00:00 /lib/systemd/systemd-journald
363 ?       Ss           00:00 /lib/systemd/systemd-udevd
485 ?       I<           00:00 [cfg80211]
543 ?       I<           00:00 [cryptd]  
552 ?       I<           00:00 [amd_iommu_v2]
575 ?       S            00:28 [irq/77-rtw88_pci]
588 ?       Ss           00:00 /sbin/rpcbind -f -w
591 ?       Ss           00:09 /lib/systemd/systemd-oomd
592 ?       Ss           00:00 /lib/systemd/systemd-resolved
593 ?       Ssl          00:00 /lib/systemd/systemd-timesyncd
623 ?       I<           00:00 [rpciod]  
624 ?       I<           00:00 [xprtiod]
630 ?       I<           00:00 [amdgpu-reset-de]
679 ?       Ssl          00:00 /usr/libexec/accounts-daemon
680 ?       Ss           00:00 /usr/sbin/acpid
682 ?       Ss           00:00 avahi-daemon:
683 ?       Ss           00:00 /usr/lib/bluetooth/bluetoothd
685 ?       Ss           00:00 /usr/sbin/cron -f -P
686 ?       Ss           00:01 @dbus-daemon --system --address=systemd: --nofork --nopidfile --systemd-activation --syslog-only
689 ?       Ssl          00:02 /usr/sbin/NetworkManager --no-daemon
697 ?       Ssl          00:00 /usr/sbin/irqbalance --foreground
703 ?       Ss           00:00 /usr/bin/python3 /usr/bin/networkd-dispatcher --run-startup-triggers
711 ?       Ssl          00:01 /usr/libexec/polkitd --no-debug
713 ?       Ssl          00:00 /usr/libexec/power-profiles-daemon
715 ?       Ssl          00:00 /usr/sbin/rsyslogd -n -iNONE
718 ?       Ssl          00:08 /usr/lib/snapd/snapd
719 ?       Ssl          00:00 /usr/libexec/switcheroo-control
720 ?       Ss           00:00 /lib/systemd/systemd-logind
722 ?       Ssl          00:00 /usr/libexec/udisks2/udisksd
725 ?       Ss           00:00 /sbin/wpa_supplicant -u -s -O /run/wpa_supplicant
737 ?       S            00:00 avahi-daemon:
748 ?       I<           00:00 [amdgpu_dm_hpd_r]
749 ?       I<           00:00 [amdgpu_dm_hpd_r]
750 ?       I<           00:00 [amdgpu_dm_hpd_r]
752 ?       I<           00:00 [amdgpu_dm_hpd_r]
753 ?       I<           00:00 [dm_vblank_contr]
813 ?       Ssl          00:00 /usr/sbin/ModemManager
816 ?       Ss           00:00 /usr/sbin/cupsd -l
820 ?       Ssl          00:00 /usr/bin/python3 /usr/share/unattended-upgrades/unattended-upgrade-shutdown --wait-for-signal
856 ?       S            00:00 [card0-crtc0]
857 ?       S            00:00 [card0-crtc1]
858 ?       S            00:00 [card0-crtc2]
859 ?       S            00:00 [card0-crtc3]
860 ?       S            00:54 [gfx_low]
861 ?       S            00:04 [gfx_high]
862 ?       S            00:00 [comp_1.0.0]
863 ?       S            00:00 [comp_1.1.0]
864 ?       S            00:00 [comp_1.2.0]
865 ?       S            00:00 [comp_1.3.0]
866 ?       S            00:00 [comp_1.0.1]
867 ?       S            00:00 [comp_1.1.1]
868 ?       S            00:00 [comp_1.2.1]
870 ?       S            00:00 [comp_1.3.1]
871 ?       S            00:00 [sdma0]   
872 ?       S            00:00 [vcn_dec]
873 ?       S            00:00 [vcn_enc0]
874 ?       S            00:00 [vcn_enc1]
875 ?       S            00:00 [jpeg_dec]
877 ?       Ssl          00:00 /usr/sbin/gdm3
1252 ?       SNsl         00:00 /usr/libexec/rtkit-daemon
1834 ?       Ssl          00:00 /usr/libexec/upowerd
1852 ?       Ssl          00:10 /usr/libexec/packagekitd
2223 ?       Ssl          00:00 /usr/libexec/colord
2662 ?       Sl           00:00 gdm-session-worker
2876 ?       Ssl          00:00 /usr/sbin/cups-browsed
2922 ?       Ss           00:00 /usr/sbin/kerneloops --test
2928 ?       Ss           00:00 /usr/sbin/kerneloops
4015 ?       Ss           00:00 /usr/lib/postfix/sbin/master -w
4018 ?       S            00:00 pickup -l -t unix -u -c
4019 ?       S            00:00 qmgr -l -t unix -u
4023 ?       S            00:00 cleanup -z -t unix -u -c
4036 ?       S            00:00 trivial-rewrite -n rewrite -t unix -u -c
4041 ?       S            00:00 smtp -t unix -u -c
4044 ?       S            00:00 tlsmgr -l -t unix -u -c
4664 ?       Ss           00:00 /lib/systemd/systemd --user
4665 ?       S            00:00 (sd-pam)  
4753 ?       S<sl         00:00 /usr/bin/pipewire
4754 ?       Ssl          00:00 /usr/bin/pipewire-media-session
4755 ?       S<sl         01:37 /usr/bin/pulseaudio --daemonize=no --log-target=journal
4771 ?       Ss           00:01 /usr/bin/dbus-daemon --session --address=systemd: --nofork --nopidfile --systemd-activation --syslog-only
4784 ?       Ssl          00:00 /usr/libexec/gvfsd
4789 ?       Sl           00:00 /usr/bin/gnome-keyring-daemon --daemonize --login
4795 ?       Sl           00:00 /usr/libexec/gvfsd-fuse /run/user/1000/gvfs -f
4802 ?       Ssl          00:00 /usr/libexec/xdg-document-portal
4828 ?       SNsl         00:02 /usr/libexec/tracker-miner-fs-3
4829 ?       Ssl          00:00 /usr/libexec/xdg-permission-store
4837 ?       Ss           00:00 fusermount3 -o rw,nosuid,nodev,fsname=portal,auto_unmount,subtype=portal -- /run/user/1000/doc
4861 ?       S            00:00 bounce -z -t unix -u -c
4889 ?       S<           00:00 [krfcommd]
4907 tty2    Ssl+         00:00 /usr/libexec/gdm-wayland-session env
4910         Sl+          00:00 /usr/libexec/gnome-session-binary --session=ubuntu
4918 ?       S            00:00 local -t unix
4991 ?       Ssl          00:00 /usr/libexec/gnome-session-ctl --monitor
5007 ?       Ssl          00:00 /usr/libexec/gnome-session-binary --systemd-service --session=ubuntu
5050 ?       Ssl          00:00 /usr/libexec/gvfs-udisks2-volume-monitor
5084 ?       Sl           00:00 /usr/libexec/at-spi-bus-launcher --launch-immediately
5087 ?       Ssl          04:28 /usr/bin/gnome-shell
5100 ?       S            00:00 /usr/bin/dbus-daemon --config-file=/usr/share/defaults/at-spi2/accessibility.conf --nofork --print-address 11 --address=unix:path=/run/user/1000/at-spi/bus
5102 ?       Ssl          00:00 /usr/libexec/gvfs-afc-volume-monitor
5108 ?       Ssl          00:00 /usr/libexec/gvfs-goa-volume-monitor
5112 ?       Sl           00:00 /usr/libexec/goa-daemon
5128 ?       Sl           00:00 /usr/libexec/goa-identity-service
5132 ?       Ssl          00:00 /usr/libexec/gvfs-gphoto2-volume-monitor
5174 ?       Ssl          00:00 /usr/libexec/gvfs-mtp-volume-monitor
5270 ?       Sl           00:00 /usr/libexec/gnome-shell-calendar-server
5277 ?       Ssl          00:00 /usr/libexec/evolution-source-registry
5281 ?       Ssl          00:00 /usr/libexec/dconf-service
5292 ?       Ssl          00:00 /usr/libexec/evolution-calendar-factory
5344 ?       Ssl          00:00 /usr/libexec/evolution-addressbook-factory
5371 ?       Sl           00:16 /usr/bin/nautilus --gapplication-service
5378 ?       Sl           00:00 /usr/libexec/gvfsd-trash --spawner :1.2 /org/gtk/gvfs/exec_spaw/0
5425 ?       Sl           00:00 /usr/bin/gjs /usr/share/gnome-shell/org.gnome.Shell.Notifications
5427 ?       Sl           00:00 /usr/libexec/at-spi2-registryd --use-gnome-session
5475 ?       Ss           00:00 sh -c /usr/bin/ibus-daemon
5477 ?       Ssl          00:00 /usr/libexec/gsd-a11y-settings
5478 ?       Ssl          00:00 /usr/libexec/gsd-color
5480 ?       Sl           00:09 /usr/bin/ibus-daemon --panel disable
5482 ?       Ssl          00:00 /usr/libexec/gsd-datetime
5484 ?       Ssl          00:00 /usr/libexec/gsd-housekeeping
5485 ?       Ssl          00:00 /usr/libexec/gsd-keyboard
5486 ?       Ssl          00:00 /usr/libexec/gsd-media-keys
5503 ?       Ssl          00:00 /usr/libexec/gsd-power
5504 ?       Ssl          00:00 /usr/libexec/gsd-print-notifications
5507 ?       Ssl          00:00 /usr/libexec/gsd-rfkill
5509 ?       Ssl          00:00 /usr/libexec/gsd-screensaver-proxy
5510 ?       Ssl          00:00 /usr/libexec/gsd-sharing
5512 ?       Ssl          00:00 /usr/libexec/gsd-smartcard
5517 ?       Ssl          00:00 /usr/libexec/gsd-sound
5518 ?       Ssl          00:00 /usr/libexec/gsd-wacom
5559 ?       Sl           00:00 /usr/libexec/gsd-disk-utility-notify
5575 ?       Sl           00:00 /usr/libexec/evolution-data-server/evolution-alarm-notify
5594 ?       Sl           00:00 /usr/libexec/ibus-dconf
5598 ?       Sl           00:02 /usr/libexec/ibus-extension-gtk3
5627 ?       Sl           00:00 /usr/libexec/ibus-portal
5664 ?       Sl           00:00 /usr/libexec/gsd-printer
5676 ?       Sl           00:03 /snap/snap-store/959/usr/bin/snap-store --gapplication-service
5869 ?       Sl           00:03 /usr/libexec/ibus-engine-simple
5991 ?       Ssl          00:00 /usr/libexec/xdg-desktop-portal
6002 ?       Ssl          00:00 /usr/libexec/xdg-desktop-portal-gnome
6014 ?       Sl           00:00 /usr/bin/gjs /usr/share/gnome-shell/org.gnome.ScreenSaver
6054 ?       Ssl          00:00 /usr/libexec/xdg-desktop-portal-gtk
6074 ?       Sl           00:02 gjs /usr/share/gnome-shell/extensions/ding@rastersoft.com/ding.js -E -P /usr/share/gnome-shell/extensions/ding@rastersoft.com -M 0 -D 0:0:1920:1080:1:27:0:70:0:0
6175 ?       Ssl          00:02 /usr/libexec/fwupd/fwupd
6176 ?       Ssl          00:00 /usr/libexec/gvfsd-metadata
6177 ?       Ss           00:00 /snap/snapd-desktop-integration/83/usr/bin/snapd-desktop-integration
6295 ?       Sl           00:00 /snap/snapd-desktop-integration/83/usr/bin/snapd-desktop-integration
6718 ?       Sl           27:13 /snap/firefox/3416/usr/lib/firefox/firefox
6813 ?       Sl           02:38 /usr/bin/Xwayland :0 -rootless -noreset -accessx -core -auth /run/user/1000/.mutter-Xwaylandauth.6H3DH2 -listen 4 -listen 5 -displayfd 6 -initfd 7
6827 ?       Ssl          00:00 /usr/libexec/gsd-xsettings
6869 ?       Sl           00:00 /usr/libexec/ibus-x11
7138         Process)N+   00:00 /snap/firefox/3416/usr/lib/firefox/firefox -contentproc -parentBuildID 20231116210351 -prefsLen 30830 -prefMapSize 234812 -appDir /snap/firefox/3416/usr/lib/firefox/browser {466c0d56-6898-4f65-b5a5-c9a64d37b32a} 6718 true socket
7209         Cont)N+      00:01 /snap/firefox/3416/usr/lib/firefox/firefox -contentproc -childID 1 -isForBrowser -prefsLen 30971 -prefMapSize 234812 -jsInitLen 228948 -parentBuildID 20231116210351 -greomni /snap/firefox/3416/usr/lib/firefox/omni.ja -appomni /snap/firefox/3416/usr/lib/firefox/browser/omni.ja -appDir /snap/firefox/3416/usr/lib/firefox/browser {d01fab92-d007-4f19-bd78-eec1b93e318d} 6718 true tab
7449 ?       Sl           00:00 /usr/bin/snap userd
7544 ?       Sl           00:08 /snap/firefox/3416/usr/lib/firefox/firefox -contentproc -childID 2 -isForBrowser -prefsLen 36318 -prefMapSize 234812 -jsInitLen 228948 -parentBuildID 20231116210351 -greomni /snap/firefox/3416/usr/lib/firefox/omni.ja -appomni /snap/firefox/3416/usr/lib/firefox/browser/omni.ja -appDir /snap/firefox/3416/usr/lib/firefox/browser {167ec15d-26d0-41ec-8682-568a000aad44} 6718 true tab
7726         Process)N+   00:33 /snap/firefox/3416/usr/lib/firefox/firefox -contentproc -parentBuildID 20231116210351 -sandboxingKind 0 -prefsLen 36318 -prefMapSize 234812 -appDir /snap/firefox/3416/usr/lib/firefox/browser {214d02d9-ed28-4743-8fcb-8e9ccdaea482} 6718 true utility
7732         Webl+        00:00 /snap/firefox/3416/usr/lib/firefox/firefox -contentproc -childID 3 -isForBrowser -prefsLen 30033 -prefMapSize 234812 -jsInitLen 228948 -parentBuildID 20231116210351 -greomni /snap/firefox/3416/usr/lib/firefox/omni.ja -appomni /snap/firefox/3416/usr/lib/firefox/browser/omni.ja -appDir /snap/firefox/3416/usr/lib/firefox/browser {65a47e33-ab3a-4eea-b89a-ab6c927823ec} 6718 true tab
7736         Webl+        00:01 /snap/firefox/3416/usr/lib/firefox/firefox -contentproc -childID 4 -isForBrowser -prefsLen 30033 -prefMapSize 234812 -jsInitLen 228948 -parentBuildID 20231116210351 -greomni /snap/firefox/3416/usr/lib/firefox/omni.ja -appomni /snap/firefox/3416/usr/lib/firefox/browser/omni.ja -appDir /snap/firefox/3416/usr/lib/firefox/browser {637f4134-3ba2-4372-a640-d98902ac59de} 6718 true tab
7854 ?       I<           00:00 [iprt-VBoxWQueue]
7855 ?       S            00:00 [iprt-VBoxTscThread]
8545         Webl+        00:00 /snap/firefox/3416/usr/lib/firefox/firefox -contentproc -childID 6 -isForBrowser -prefsLen 30276 -prefMapSize 234812 -jsInitLen 228948 -parentBuildID 20231116210351 -greomni /snap/firefox/3416/usr/lib/firefox/omni.ja -appomni /snap/firefox/3416/usr/lib/firefox/browser/omni.ja -appDir /snap/firefox/3416/usr/lib/firefox/browser {1747d611-189c-48e0-b24a-f0588cdd6e04} 6718 true tab
8704         Webl+        00:00 /snap/firefox/3416/usr/lib/firefox/firefox -contentproc -childID 7 -isForBrowser -prefsLen 30276 -prefMapSize 234812 -jsInitLen 228948 -parentBuildID 20231116210351 -greomni /snap/firefox/3416/usr/lib/firefox/omni.ja -appomni /snap/firefox/3416/usr/lib/firefox/browser/omni.ja -appDir /snap/firefox/3416/usr/lib/firefox/browser {528a6ff5-25e4-4866-8f93-b063e3f779e5} 6718 true tab
8731         Process)N+   01:35 /snap/firefox/3416/usr/lib/firefox/firefox -contentproc -parentBuildID 20231116210351 -prefsLen 36561 -prefMapSize 234812 -appDir /snap/firefox/3416/usr/lib/firefox/browser {fc6f467f-c1d7-400a-ab4f-f18022ef6b61} 6718 true rdd
8815 ?       Sl           00:00 update-notifier
8906         Webl+        00:00 /snap/firefox/3416/usr/lib/firefox/firefox -contentproc -childID 10 -isForBrowser -prefsLen 30378 -prefMapSize 234812 -jsInitLen 228948 -parentBuildID 20231116210351 -greomni /snap/firefox/3416/usr/lib/firefox/omni.ja -appomni /snap/firefox/3416/usr/lib/firefox/browser/omni.ja -appDir /snap/firefox/3416/usr/lib/firefox/browser {33dda69e-f25e-4e09-8632-9f8575a0b273} 6718 true tab
9169 ?       S            00:00 /bin/bash /usr/bin/atom /home/vkan/Documents/DZ/proc/README.md
9171 ?       Sl           01:13 /usr/share/atom/atom
9174 ?       S            00:00 /usr/share/atom/atom
9175 ?       S            00:00 /usr/share/atom/atom
9177 ?       S            00:00 /usr/share/atom/atom
9204 ?       Sl           00:49 /usr/share/atom/atom
9212 ?       Sl           00:00 /usr/share/atom/atom
9237 ?       SlL          03:26 /usr/share/atom/atom
9300 ?       Sl           00:00 /usr/share/atom/atom
9801 ?       Ssl          01:04 /usr/libexec/gnome-terminal-server
9819 pts/0   Ss+          00:00 bash      
27751 ?       I            00:00 [kworker/3:2-events]
43956 ?       I            00:08 [kworker/u32:1-events_unbound]
58458         Webl+        00:00 /snap/firefox/3416/usr/lib/firefox/firefox -contentproc -childID 18 -isForBrowser -prefsLen 30469 -prefMapSize 234812 -jsInitLen 228948 -parentBuildID 20231116210351 -greomni /snap/firefox/3416/usr/lib/firefox/omni.ja -appomni /snap/firefox/3416/usr/lib/firefox/browser/omni.ja -appDir /snap/firefox/3416/usr/lib/firefox/browser {a8b6c16b-bc97-4ad7-917a-cc0c689e3f6b} 6718 true tab
58665         Webl+        00:00 /snap/firefox/3416/usr/lib/firefox/firefox -contentproc -childID 23 -isForBrowser -prefsLen 30466 -prefMapSize 234812 -jsInitLen 228948 -parentBuildID 20231116210351 -greomni /snap/firefox/3416/usr/lib/firefox/omni.ja -appomni /snap/firefox/3416/usr/lib/firefox/browser/omni.ja -appDir /snap/firefox/3416/usr/lib/firefox/browser {efe2d326-6a01-4a07-a422-79c95138aa1d} 6718 true tab
58715 ?       I            00:00 [kworker/3:1-inet_frag_wq]
58755 ?       I            00:00 [kworker/5:0-events]
58758 ?       I            00:00 [kworker/0:1-events]
58759 ?       I            00:00 [kworker/4:0-events]
58909 ?       Ssl          00:00 /usr/bin/speech-dispatcher -s -t 0
58920 ?       Z            00:00 [sd_espeak-ng-mb]
58923 ?       Sl           00:00 /usr/lib/speech-dispatcher-modules/sd_espeak-ng /etc/speech-dispatcher/modules/espeak-ng.conf
58927 ?       Sl           00:00 /usr/lib/speech-dispatcher-modules/sd_dummy /etc/speech-dispatcher/modules/dummy.conf
59012         Webl+        00:00 /snap/firefox/3416/usr/lib/firefox/firefox -contentproc -childID 30 -isForBrowser -prefsLen 30466 -prefMapSize 234812 -jsInitLen 228948 -parentBuildID 20231116210351 -greomni /snap/firefox/3416/usr/lib/firefox/omni.ja -appomni /snap/firefox/3416/usr/lib/firefox/browser/omni.ja -appDir /snap/firefox/3416/usr/lib/firefox/browser {bd6fe7a6-f1bb-4c9d-92ee-ca2adbf013b9} 6718 true tab
59015         Webl+        00:00 /snap/firefox/3416/usr/lib/firefox/firefox -contentproc -childID 31 -isForBrowser -prefsLen 30466 -prefMapSize 234812 -jsInitLen 228948 -parentBuildID 20231116210351 -greomni /snap/firefox/3416/usr/lib/firefox/omni.ja -appomni /snap/firefox/3416/usr/lib/firefox/browser/omni.ja -appDir /snap/firefox/3416/usr/lib/firefox/browser {ba406a2b-1f36-4633-b6dc-1245359ad576} 6718 true tab
59098         Content)N+   00:00 /snap/firefox/3416/usr/lib/firefox/firefox -contentproc -childID 33 -isForBrowser -prefsLen 30466 -prefMapSize 234812 -jsInitLen 228948 -parentBuildID 20231116210351 -greomni /snap/firefox/3416/usr/lib/firefox/omni.ja -appomni /snap/firefox/3416/usr/lib/firefox/browser/omni.ja -appDir /snap/firefox/3416/usr/lib/firefox/browser {86428d42-d50c-46e5-98dc-df0b78f873eb} 6718 true tab
59131         Content)N+   00:00 /snap/firefox/3416/usr/lib/firefox/firefox -contentproc -childID 34 -isForBrowser -prefsLen 30466 -prefMapSize 234812 -jsInitLen 228948 -parentBuildID 20231116210351 -greomni /snap/firefox/3416/usr/lib/firefox/omni.ja -appomni /snap/firefox/3416/usr/lib/firefox/browser/omni.ja -appDir /snap/firefox/3416/usr/lib/firefox/browser {0d58e2e2-ad79-4f18-9f6d-dbf21d45e8b3} 6718 true tab
59162         Content)N+   00:00 /snap/firefox/3416/usr/lib/firefox/firefox -contentproc -childID 35 -isForBrowser -prefsLen 30466 -prefMapSize 234812 -jsInitLen 228948 -parentBuildID 20231116210351 -greomni /snap/firefox/3416/usr/lib/firefox/omni.ja -appomni /snap/firefox/3416/usr/lib/firefox/browser/omni.ja -appDir /snap/firefox/3416/usr/lib/firefox/browser {17c621b4-2364-4c52-9573-88f2b8355946} 6718 true tab
59242 ?       I            00:00 [kworker/0:2-events]
59244 ?       I            00:00 [kworker/4:2-events]
59245 ?       I            00:00 [kworker/2:2-events]
59435 ?       I            00:01 [kworker/u32:3-flush-8:0]
59492 ?       I            00:00 [kworker/1:2]
59493 ?       I            00:00 [kworker/5:1-mm_percpu_wq]
59499 ?       I<           00:00 [kworker/u33:0-rtw_tx_wq]
59521 ?       I            00:00 [kworker/u32:4-events_power_efficient]
59664 ?       Sl           00:03 /usr/bin/gedit --gapplication-service
59704 ?       I<           00:00 [kworker/u33:2-rtw_tx_wq]
59706 ?       I            00:00 [kworker/u32:2-events_unbound]
59746 ?       I            00:00 [kworker/2:0]
59747 ?       I            00:00 [kworker/3:0-events]
70765 pts/0   S+           00:00 /bin/bash ./psax.sh
70766 pts/0   S+           00:00 /bin/bash ./psax.sh
70767 pts/0   S+           00:00 /bin/bash ./psax.sh
70768 pts/0   S+           00:00 /bin/bash ./psax.sh
70769 pts/0   S+           00:00 /bin/bash ./psax.sh
70770 pts/0   S+           00:00 /bin/bash ./psax.sh

```

</details>


[Для сверки со штатным ps ax](/homework/10/psax.log)
<details><summary>см. Вывод ps ax</summary>

```properties
PID TTY      STAT   TIME COMMAND
  1 ?        Ss     0:02 /sbin/init splash
  2 ?        S      0:00 [kthreadd]
  3 ?        I<     0:00 [rcu_gp]
  4 ?        I<     0:00 [rcu_par_gp]
  5 ?        I<     0:00 [slub_flushwq]
  6 ?        I<     0:00 [netns]
  8 ?        I<     0:00 [kworker/0:0H-events_highpri]
 10 ?        I<     0:00 [mm_percpu_wq]
 11 ?        I      0:00 [rcu_tasks_kthread]
 12 ?        I      0:00 [rcu_tasks_rude_kthread]
 13 ?        I      0:00 [rcu_tasks_trace_kthread]
 14 ?        S      0:00 [ksoftirqd/0]
 15 ?        I      0:08 [rcu_preempt]
 16 ?        S      0:00 [migration/0]
 17 ?        S      0:00 [idle_inject/0]
 19 ?        S      0:00 [cpuhp/0]
 20 ?        S      0:00 [cpuhp/1]
 21 ?        S      0:00 [idle_inject/1]
 22 ?        S      0:00 [migration/1]
 23 ?        S      0:00 [ksoftirqd/1]
 25 ?        I<     0:00 [kworker/1:0H-events_highpri]
 26 ?        S      0:00 [cpuhp/2]
 27 ?        S      0:00 [idle_inject/2]
 28 ?        S      0:00 [migration/2]
 29 ?        S      0:00 [ksoftirqd/2]
 31 ?        I<     0:00 [kworker/2:0H-events_highpri]
 32 ?        S      0:00 [cpuhp/3]
 33 ?        S      0:00 [idle_inject/3]
 34 ?        S      0:00 [migration/3]
 35 ?        S      0:00 [ksoftirqd/3]
 37 ?        I<     0:00 [kworker/3:0H-events_highpri]
 38 ?        S      0:00 [cpuhp/4]
 39 ?        S      0:00 [idle_inject/4]
 40 ?        S      0:00 [migration/4]
 41 ?        S      0:00 [ksoftirqd/4]
 43 ?        I<     0:00 [kworker/4:0H-events_highpri]
 44 ?        S      0:00 [cpuhp/5]
 45 ?        S      0:00 [idle_inject/5]
 46 ?        S      0:00 [migration/5]
 47 ?        S      0:00 [ksoftirqd/5]
 49 ?        I<     0:00 [kworker/5:0H-events_highpri]
 50 ?        S      0:00 [kdevtmpfs]
 51 ?        I<     0:00 [inet_frag_wq]
 52 ?        S      0:00 [kauditd]
 53 ?        S      0:00 [khungtaskd]
 56 ?        S      0:00 [oom_reaper]
 57 ?        I<     0:00 [writeback]
 58 ?        S      0:00 [kcompactd0]
 59 ?        SN     0:00 [ksmd]
 61 ?        SN     0:00 [khugepaged]
 62 ?        I<     0:00 [kintegrityd]
 63 ?        I<     0:00 [kblockd]
 64 ?        I<     0:00 [blkcg_punt_bio]
 65 ?        I<     0:00 [tpm_dev_wq]
 66 ?        I<     0:00 [ata_sff]
 67 ?        I<     0:00 [md]
 68 ?        I<     0:00 [edac-poller]
 69 ?        I<     0:00 [devfreq_wq]
 70 ?        S      0:00 [watchdogd]
 71 ?        I<     0:00 [kworker/3:1H-kblockd]
 72 ?        S      0:00 [irq/25-AMD-Vi]
 73 ?        S      0:00 [kswapd0]
 74 ?        S      0:00 [ecryptfs-kthread]
 75 ?        I<     0:00 [kthrotld]
 76 ?        S      0:00 [irq/27-pciehp]
 77 ?        S      0:00 [irq/28-pciehp]
 78 ?        I      0:00 [kworker/1:1-events]
 79 ?        I      0:00 [kworker/2:1-events]
 82 ?        I<     0:00 [acpi_thermal_pm]
 83 ?        S      0:00 [hwrng]
 84 ?        I<     0:00 [mld]
 85 ?        I<     0:00 [ipv6_addrconf]
 94 ?        I<     0:00 [kstrp]
 96 ?        I<     0:00 [zswap-shrink]
101 ?        I<     0:00 [charger_manager]
124 ?        I<     0:00 [kworker/2:1H-kblockd]
136 ?        I<     0:00 [kworker/4:1H-kblockd]
139 ?        I<     0:00 [kworker/5:1H-kblockd]
140 ?        I<     0:00 [kworker/1:1H-kblockd]
141 ?        I<     0:00 [kworker/0:1H-kblockd]
156 ?        S      0:20 [irq/32-SYNA30AD:00]
181 ?        S      0:00 [scsi_eh_0]
182 ?        I<     0:00 [scsi_tmf_0]
183 ?        S      0:00 [scsi_eh_1]
184 ?        I<     0:00 [scsi_tmf_1]
186 ?        S      0:00 [scsi_eh_2]
187 ?        I<     0:00 [scsi_tmf_2]
189 ?        S      0:00 [scsi_eh_3]
190 ?        I<     0:00 [scsi_tmf_3]
195 ?        I<     0:00 [nvme-wq]
196 ?        I<     0:00 [nvme-reset-wq]
197 ?        I<     0:00 [nvme-delete-wq]
198 ?        I<     0:00 [nvme-auth-wq]
218 ?        I<     0:00 [raid5wq]
250 ?        S      0:00 [jbd2/sda5-8]
251 ?        I<     0:00 [ext4-rsv-conver]
305 ?        S<s    0:00 /lib/systemd/systemd-journald
363 ?        Ss     0:00 /lib/systemd/systemd-udevd
485 ?        I<     0:00 [cfg80211]
543 ?        I<     0:00 [cryptd]
552 ?        I<     0:00 [amd_iommu_v2]
575 ?        S      0:28 [irq/77-rtw88_pci]
588 ?        Ss     0:00 /sbin/rpcbind -f -w
591 ?        Ss     0:09 /lib/systemd/systemd-oomd
592 ?        Ss     0:00 /lib/systemd/systemd-resolved
593 ?        Ssl    0:00 /lib/systemd/systemd-timesyncd
623 ?        I<     0:00 [rpciod]
624 ?        I<     0:00 [xprtiod]
630 ?        I<     0:00 [amdgpu-reset-de]
679 ?        Ssl    0:00 /usr/libexec/accounts-daemon
680 ?        Ss     0:00 /usr/sbin/acpid
682 ?        Ss     0:00 avahi-daemon: running [l04-ubuntu.local]
683 ?        Ss     0:00 /usr/lib/bluetooth/bluetoothd
685 ?        Ss     0:00 /usr/sbin/cron -f -P
686 ?        Ss     0:01 @dbus-daemon --system --address=systemd: --nofork --nopidfile --systemd-activation --syslog-only
689 ?        Ssl    0:01 /usr/sbin/NetworkManager --no-daemon
697 ?        Ssl    0:00 /usr/sbin/irqbalance --foreground
703 ?        Ss     0:00 /usr/bin/python3 /usr/bin/networkd-dispatcher --run-startup-triggers
711 ?        Ssl    0:01 /usr/libexec/polkitd --no-debug
713 ?        Ssl    0:00 /usr/libexec/power-profiles-daemon
715 ?        Ssl    0:00 /usr/sbin/rsyslogd -n -iNONE
718 ?        Ssl    0:08 /usr/lib/snapd/snapd
719 ?        Ssl    0:00 /usr/libexec/switcheroo-control
720 ?        Ss     0:00 /lib/systemd/systemd-logind
722 ?        Ssl    0:00 /usr/libexec/udisks2/udisksd
725 ?        Ss     0:00 /sbin/wpa_supplicant -u -s -O /run/wpa_supplicant
737 ?        S      0:00 avahi-daemon: chroot helper
748 ?        I<     0:00 [amdgpu_dm_hpd_r]
749 ?        I<     0:00 [amdgpu_dm_hpd_r]
750 ?        I<     0:00 [amdgpu_dm_hpd_r]
752 ?        I<     0:00 [amdgpu_dm_hpd_r]
753 ?        I<     0:00 [dm_vblank_contr]
813 ?        Ssl    0:00 /usr/sbin/ModemManager
816 ?        Ss     0:00 /usr/sbin/cupsd -l
820 ?        Ssl    0:00 /usr/bin/python3 /usr/share/unattended-upgrades/unattended-upgrade-shutdown --wait-for-signal
856 ?        S      0:00 [card0-crtc0]
857 ?        S      0:00 [card0-crtc1]
858 ?        S      0:00 [card0-crtc2]
859 ?        S      0:00 [card0-crtc3]
860 ?        S      0:51 [gfx_low]
861 ?        S      0:03 [gfx_high]
862 ?        S      0:00 [comp_1.0.0]
863 ?        S      0:00 [comp_1.1.0]
864 ?        S      0:00 [comp_1.2.0]
865 ?        S      0:00 [comp_1.3.0]
866 ?        S      0:00 [comp_1.0.1]
867 ?        S      0:00 [comp_1.1.1]
868 ?        S      0:00 [comp_1.2.1]
870 ?        S      0:00 [comp_1.3.1]
871 ?        S      0:00 [sdma0]
872 ?        S      0:00 [vcn_dec]
873 ?        S      0:00 [vcn_enc0]
874 ?        S      0:00 [vcn_enc1]
875 ?        S      0:00 [jpeg_dec]
877 ?        Ssl    0:00 /usr/sbin/gdm3
1252 ?        SNsl   0:00 /usr/libexec/rtkit-daemon
1834 ?        Ssl    0:00 /usr/libexec/upowerd
1852 ?        Ssl    0:10 /usr/libexec/packagekitd
2223 ?        Ssl    0:00 /usr/libexec/colord
2662 ?        Sl     0:00 gdm-session-worker [pam/gdm-password]
2876 ?        Ssl    0:00 /usr/sbin/cups-browsed
2922 ?        Ss     0:00 /usr/sbin/kerneloops --test
2928 ?        Ss     0:00 /usr/sbin/kerneloops
4015 ?        Ss     0:00 /usr/lib/postfix/sbin/master -w
4018 ?        S      0:00 pickup -l -t unix -u -c
4019 ?        S      0:00 qmgr -l -t unix -u
4023 ?        S      0:00 cleanup -z -t unix -u -c
4036 ?        S      0:00 trivial-rewrite -n rewrite -t unix -u -c
4041 ?        S      0:00 smtp -t unix -u -c
4044 ?        S      0:00 tlsmgr -l -t unix -u -c
4664 ?        Ss     0:00 /lib/systemd/systemd --user
4665 ?        S      0:00 (sd-pam)
4753 ?        S<sl   0:00 /usr/bin/pipewire
4754 ?        Ssl    0:00 /usr/bin/pipewire-media-session
4755 ?        S<sl   1:31 /usr/bin/pulseaudio --daemonize=no --log-target=journal
4771 ?        Ss     0:01 /usr/bin/dbus-daemon --session --address=systemd: --nofork --nopidfile --systemd-activation --syslog-only
4784 ?        Ssl    0:00 /usr/libexec/gvfsd
4789 ?        Sl     0:00 /usr/bin/gnome-keyring-daemon --daemonize --login
4795 ?        Sl     0:00 /usr/libexec/gvfsd-fuse /run/user/1000/gvfs -f
4802 ?        Ssl    0:00 /usr/libexec/xdg-document-portal
4828 ?        SNsl   0:02 /usr/libexec/tracker-miner-fs-3
4829 ?        Ssl    0:00 /usr/libexec/xdg-permission-store
4837 ?        Ss     0:00 fusermount3 -o rw,nosuid,nodev,fsname=portal,auto_unmount,subtype=portal -- /run/user/1000/doc
4861 ?        S      0:00 bounce -z -t unix -u -c
4889 ?        S<     0:00 [krfcommd]
4907 tty2     Ssl+   0:00 /usr/libexec/gdm-wayland-session env GNOME_SHELL_SESSION_MODE=ubuntu /usr/bin/gnome-session --session=ubuntu
4910 tty2     Sl+    0:00 /usr/libexec/gnome-session-binary --session=ubuntu
4918 ?        S      0:00 local -t unix
4991 ?        Ssl    0:00 /usr/libexec/gnome-session-ctl --monitor
5007 ?        Ssl    0:00 /usr/libexec/gnome-session-binary --systemd-service --session=ubuntu
5050 ?        Ssl    0:00 /usr/libexec/gvfs-udisks2-volume-monitor
5084 ?        Sl     0:00 /usr/libexec/at-spi-bus-launcher --launch-immediately
5087 ?        Ssl    4:18 /usr/bin/gnome-shell
5100 ?        S      0:00 /usr/bin/dbus-daemon --config-file=/usr/share/defaults/at-spi2/accessibility.conf --nofork --print-address 11 --address=unix:path=/run/user/1000/at-spi/bus
5102 ?        Ssl    0:00 /usr/libexec/gvfs-afc-volume-monitor
5108 ?        Ssl    0:00 /usr/libexec/gvfs-goa-volume-monitor
5112 ?        Sl     0:00 /usr/libexec/goa-daemon
5128 ?        Sl     0:00 /usr/libexec/goa-identity-service
5132 ?        Ssl    0:00 /usr/libexec/gvfs-gphoto2-volume-monitor
5174 ?        Ssl    0:00 /usr/libexec/gvfs-mtp-volume-monitor
5270 ?        Sl     0:00 /usr/libexec/gnome-shell-calendar-server
5277 ?        Ssl    0:00 /usr/libexec/evolution-source-registry
5281 ?        Ssl    0:00 /usr/libexec/dconf-service
5292 ?        Ssl    0:00 /usr/libexec/evolution-calendar-factory
5344 ?        Ssl    0:00 /usr/libexec/evolution-addressbook-factory
5371 ?        Sl     0:15 /usr/bin/nautilus --gapplication-service
5378 ?        Sl     0:00 /usr/libexec/gvfsd-trash --spawner :1.2 /org/gtk/gvfs/exec_spaw/0
5425 ?        Sl     0:00 /usr/bin/gjs /usr/share/gnome-shell/org.gnome.Shell.Notifications
5427 ?        Sl     0:00 /usr/libexec/at-spi2-registryd --use-gnome-session
5475 ?        Ss     0:00 sh -c /usr/bin/ibus-daemon --panel disable $([ "$XDG_SESSION_TYPE" = "x11" ] && echo "--xim")
5477 ?        Ssl    0:00 /usr/libexec/gsd-a11y-settings
5478 ?        Ssl    0:00 /usr/libexec/gsd-color
5480 ?        Sl     0:08 /usr/bin/ibus-daemon --panel disable
5482 ?        Ssl    0:00 /usr/libexec/gsd-datetime
5484 ?        Ssl    0:00 /usr/libexec/gsd-housekeeping
5485 ?        Ssl    0:00 /usr/libexec/gsd-keyboard
5486 ?        Ssl    0:00 /usr/libexec/gsd-media-keys
5503 ?        Ssl    0:00 /usr/libexec/gsd-power
5504 ?        Ssl    0:00 /usr/libexec/gsd-print-notifications
5507 ?        Ssl    0:00 /usr/libexec/gsd-rfkill
5509 ?        Ssl    0:00 /usr/libexec/gsd-screensaver-proxy
5510 ?        Ssl    0:00 /usr/libexec/gsd-sharing
5512 ?        Ssl    0:00 /usr/libexec/gsd-smartcard
5517 ?        Ssl    0:00 /usr/libexec/gsd-sound
5518 ?        Ssl    0:00 /usr/libexec/gsd-wacom
5559 ?        Sl     0:00 /usr/libexec/gsd-disk-utility-notify
5575 ?        Sl     0:00 /usr/libexec/evolution-data-server/evolution-alarm-notify
5594 ?        Sl     0:00 /usr/libexec/ibus-dconf
5598 ?        Sl     0:02 /usr/libexec/ibus-extension-gtk3
5627 ?        Sl     0:00 /usr/libexec/ibus-portal
5664 ?        Sl     0:00 /usr/libexec/gsd-printer
5676 ?        Sl     0:03 /snap/snap-store/959/usr/bin/snap-store --gapplication-service
5869 ?        Sl     0:03 /usr/libexec/ibus-engine-simple
5991 ?        Ssl    0:00 /usr/libexec/xdg-desktop-portal
6002 ?        Ssl    0:00 /usr/libexec/xdg-desktop-portal-gnome
6014 ?        Sl     0:00 /usr/bin/gjs /usr/share/gnome-shell/org.gnome.ScreenSaver
6054 ?        Ssl    0:00 /usr/libexec/xdg-desktop-portal-gtk
6074 ?        Sl     0:02 gjs /usr/share/gnome-shell/extensions/ding@rastersoft.com/ding.js -E -P /usr/share/gnome-shell/extensions/ding@rastersoft.com -M 0 -D 0:0:1920:1080:1:27:0:70:0:0
6175 ?        Ssl    0:02 /usr/libexec/fwupd/fwupd
6176 ?        Ssl    0:00 /usr/libexec/gvfsd-metadata
6177 ?        Ss     0:00 /snap/snapd-desktop-integration/83/usr/bin/snapd-desktop-integration
6295 ?        Sl     0:00 /snap/snapd-desktop-integration/83/usr/bin/snapd-desktop-integration
6718 ?        Sl    25:35 /snap/firefox/3416/usr/lib/firefox/firefox
6813 ?        Sl     2:29 /usr/bin/Xwayland :0 -rootless -noreset -accessx -core -auth /run/user/1000/.mutter-Xwaylandauth.6H3DH2 -listen 4 -listen 5 -displayfd 6 -initfd 7
6827 ?        Ssl    0:00 /usr/libexec/gsd-xsettings
6869 ?        Sl     0:00 /usr/libexec/ibus-x11
7138 ?        Sl     0:00 /snap/firefox/3416/usr/lib/firefox/firefox -contentproc -parentBuildID 20231116210351 -prefsLen 30830 -prefMapSize 234812 -appDir /snap/firefox/3416/usr/lib/firefox/browser {466c0d56-6898-4f65-b5a5-c9a64d37b32a} 6718 true socket
7209 ?        Sl     0:02 /snap/firefox/3416/usr/lib/firefox/firefox -contentproc -childID 1 -isForBrowser -prefsLen 30971 -prefMapSize 234812 -jsInitLen 228948 -parentBuildID 20231116210351 -greomni /snap/firefox/3416/usr/lib/firefox/omni.ja -appomni /snap/firefox/3416/usr/lib/firefox/browser/omni.ja -appDir /snap/firefox/3416/usr/lib/firefox/browser {d01fab92-d007-4f19-bd78-eec1b93e318d} 6718 true tab
7449 ?        Sl     0:00 /usr/bin/snap userd
7544 ?        Sl     0:08 /snap/firefox/3416/usr/lib/firefox/firefox -contentproc -childID 2 -isForBrowser -prefsLen 36318 -prefMapSize 234812 -jsInitLen 228948 -parentBuildID 20231116210351 -greomni /snap/firefox/3416/usr/lib/firefox/omni.ja -appomni /snap/firefox/3416/usr/lib/firefox/browser/omni.ja -appDir /snap/firefox/3416/usr/lib/firefox/browser {167ec15d-26d0-41ec-8682-568a000aad44} 6718 true tab
7726 ?        Sl     0:46 /snap/firefox/3416/usr/lib/firefox/firefox -contentproc -parentBuildID 20231116210351 -sandboxingKind 0 -prefsLen 36318 -prefMapSize 234812 -appDir /snap/firefox/3416/usr/lib/firefox/browser {214d02d9-ed28-4743-8fcb-8e9ccdaea482} 6718 true utility
7732 ?        Sl     0:01 /snap/firefox/3416/usr/lib/firefox/firefox -contentproc -childID 3 -isForBrowser -prefsLen 30033 -prefMapSize 234812 -jsInitLen 228948 -parentBuildID 20231116210351 -greomni /snap/firefox/3416/usr/lib/firefox/omni.ja -appomni /snap/firefox/3416/usr/lib/firefox/browser/omni.ja -appDir /snap/firefox/3416/usr/lib/firefox/browser {65a47e33-ab3a-4eea-b89a-ab6c927823ec} 6718 true tab
7736 ?        Sl     0:58 /snap/firefox/3416/usr/lib/firefox/firefox -contentproc -childID 4 -isForBrowser -prefsLen 30033 -prefMapSize 234812 -jsInitLen 228948 -parentBuildID 20231116210351 -greomni /snap/firefox/3416/usr/lib/firefox/omni.ja -appomni /snap/firefox/3416/usr/lib/firefox/browser/omni.ja -appDir /snap/firefox/3416/usr/lib/firefox/browser {637f4134-3ba2-4372-a640-d98902ac59de} 6718 true tab
7854 ?        I<     0:00 [iprt-VBoxWQueue]
7855 ?        S      0:00 [iprt-VBoxTscThread]
8545 ?        Sl     0:02 /snap/firefox/3416/usr/lib/firefox/firefox -contentproc -childID 6 -isForBrowser -prefsLen 30276 -prefMapSize 234812 -jsInitLen 228948 -parentBuildID 20231116210351 -greomni /snap/firefox/3416/usr/lib/firefox/omni.ja -appomni /snap/firefox/3416/usr/lib/firefox/browser/omni.ja -appDir /snap/firefox/3416/usr/lib/firefox/browser {1747d611-189c-48e0-b24a-f0588cdd6e04} 6718 true tab
8704 ?        Sl     0:29 /snap/firefox/3416/usr/lib/firefox/firefox -contentproc -childID 7 -isForBrowser -prefsLen 30276 -prefMapSize 234812 -jsInitLen 228948 -parentBuildID 20231116210351 -greomni /snap/firefox/3416/usr/lib/firefox/omni.ja -appomni /snap/firefox/3416/usr/lib/firefox/browser/omni.ja -appDir /snap/firefox/3416/usr/lib/firefox/browser {528a6ff5-25e4-4866-8f93-b063e3f779e5} 6718 true tab
8731 ?        Sl     1:37 /snap/firefox/3416/usr/lib/firefox/firefox -contentproc -parentBuildID 20231116210351 -prefsLen 36561 -prefMapSize 234812 -appDir /snap/firefox/3416/usr/lib/firefox/browser {fc6f467f-c1d7-400a-ab4f-f18022ef6b61} 6718 true rdd
8815 ?        Sl     0:00 update-notifier
8906 ?        Sl     0:56 /snap/firefox/3416/usr/lib/firefox/firefox -contentproc -childID 10 -isForBrowser -prefsLen 30378 -prefMapSize 234812 -jsInitLen 228948 -parentBuildID 20231116210351 -greomni /snap/firefox/3416/usr/lib/firefox/omni.ja -appomni /snap/firefox/3416/usr/lib/firefox/browser/omni.ja -appDir /snap/firefox/3416/usr/lib/firefox/browser {33dda69e-f25e-4e09-8632-9f8575a0b273} 6718 true tab
9169 ?        S      0:00 /bin/bash /usr/bin/atom /home/vkan/Documents/DZ/proc/README.md
9171 ?        Sl     1:10 /usr/share/atom/atom --executed-from=/home/vkan --pid=9155 /home/vkan/Documents/DZ/proc/README.md
9174 ?        S      0:00 /usr/share/atom/atom --type=zygote --no-zygote-sandbox
9175 ?        S      0:00 /usr/share/atom/atom --type=zygote
9177 ?        S      0:00 /usr/share/atom/atom --type=zygote
9204 ?        Sl     0:43 /usr/share/atom/atom --type=gpu-process --field-trial-handle=12015486431104296834,10123710243189957809,131072 --enable-features=WebComponentsV0Enabled --disable-features=SpareRendererForSitePerProcess --gpu-preferences=MAAAAAAAAAAgAAAAAAAAAAAAAAAAAAAAAABgAAAAAAAQAAAAAAAAAAAAAAAAAAAACAAAAAAAAAA= --shared-files
9212 ?        Sl     0:00 /usr/share/atom/atom --type=utility --field-trial-handle=12015486431104296834,10123710243189957809,131072 --enable-features=WebComponentsV0Enabled --disable-features=SpareRendererForSitePerProcess --lang=en-US --service-sandbox-type=network --enable-experimental-web-platform-features --enable-crash-reporter=bac5617a-55a9-4b45-867e-b22d25b5a83a,no_channel --global-crash-keys=bac5617a-55a9-4b45-867e-b22d25b5a83a,no_channel,_companyName=GitHub,_productName=Atom,_version=1.60.0 --shared-files=v8_snapshot_data:100
9237 ?        SLl    3:05 /usr/share/atom/atom --type=renderer --enable-experimental-web-platform-features --field-trial-handle=12015486431104296834,10123710243189957809,131072 --enable-features=WebComponentsV0Enabled --disable-features=SpareRendererForSitePerProcess --lang=en-US --enable-crash-reporter=bac5617a-55a9-4b45-867e-b22d25b5a83a,no_channel --global-crash-keys=bac5617a-55a9-4b45-867e-b22d25b5a83a,no_channel,_companyName=GitHub,_productName=Atom,_version=1.60.0 --app-path=/usr/share/atom/resources/app.asar --node-integration --node-integration-in-worker --webview-tag --no-sandbox --no-zygote --enable-remote-module --background-color=#fff --disable-blink-features=Auxclick --enable-spellcheck --enable-websql --num-raster-threads=3 --enable-main-frame-before-activation --renderer-client-id=5 --no-v8-untrusted-code-mitigations --shared-files=v8_snapshot_data:100
9300 ?        Sl     0:00 /usr/share/atom/atom --type=renderer --enable-experimental-web-platform-features --field-trial-handle=12015486431104296834,10123710243189957809,131072 --enable-features=WebComponentsV0Enabled --disable-features=SpareRendererForSitePerProcess --lang=en-US --enable-crash-reporter=bac5617a-55a9-4b45-867e-b22d25b5a83a,no_channel --global-crash-keys=bac5617a-55a9-4b45-867e-b22d25b5a83a,no_channel,_companyName=GitHub,_productName=Atom,_version=1.60.0 --app-path=/usr/share/atom/resources/app.asar --node-integration --no-sandbox --no-zygote --enable-remote-module --background-color=#fff --enable-spellcheck --enable-websql --num-raster-threads=3 --enable-main-frame-before-activation --renderer-client-id=7 --no-v8-untrusted-code-mitigations --shared-files=v8_snapshot_data:100
9801 ?        Ssl    1:00 /usr/libexec/gnome-terminal-server
9819 pts/0    Ss     0:00 bash
27751 ?        I      0:00 [kworker/3:2-mm_percpu_wq]
32174 ?        Sl     0:01 /snap/firefox/3416/usr/lib/firefox/firefox -contentproc -childID 15 -isForBrowser -prefsLen 30468 -prefMapSize 234812 -jsInitLen 228948 -parentBuildID 20231116210351 -greomni /snap/firefox/3416/usr/lib/firefox/omni.ja -appomni /snap/firefox/3416/usr/lib/firefox/browser/omni.ja -appDir /snap/firefox/3416/usr/lib/firefox/browser {222febba-def1-4bfa-ae6d-1bf1890a6f78} 6718 true tab
43956 ?        I      0:07 [kworker/u32:1-events_power_efficient]
49377 ?        I      0:07 [kworker/u32:0-flush-8:0]
58458 ?        Sl     0:00 /snap/firefox/3416/usr/lib/firefox/firefox -contentproc -childID 18 -isForBrowser -prefsLen 30469 -prefMapSize 234812 -jsInitLen 228948 -parentBuildID 20231116210351 -greomni /snap/firefox/3416/usr/lib/firefox/omni.ja -appomni /snap/firefox/3416/usr/lib/firefox/browser/omni.ja -appDir /snap/firefox/3416/usr/lib/firefox/browser {a8b6c16b-bc97-4ad7-917a-cc0c689e3f6b} 6718 true tab
58665 ?        Sl     0:09 /snap/firefox/3416/usr/lib/firefox/firefox -contentproc -childID 23 -isForBrowser -prefsLen 30466 -prefMapSize 234812 -jsInitLen 228948 -parentBuildID 20231116210351 -greomni /snap/firefox/3416/usr/lib/firefox/omni.ja -appomni /snap/firefox/3416/usr/lib/firefox/browser/omni.ja -appDir /snap/firefox/3416/usr/lib/firefox/browser {efe2d326-6a01-4a07-a422-79c95138aa1d} 6718 true tab
58715 ?        I      0:00 [kworker/3:1-events]
58755 ?        I      0:00 [kworker/5:0-mm_percpu_wq]
58758 ?        I      0:00 [kworker/0:1-events]
58759 ?        I      0:00 [kworker/4:0-events]
58909 ?        Ssl    0:00 /usr/bin/speech-dispatcher -s -t 0
58920 ?        Z      0:00 [sd_espeak-ng-mb] <defunct>
58923 ?        Sl     0:00 /usr/lib/speech-dispatcher-modules/sd_espeak-ng /etc/speech-dispatcher/modules/espeak-ng.conf
58927 ?        Sl     0:00 /usr/lib/speech-dispatcher-modules/sd_dummy /etc/speech-dispatcher/modules/dummy.conf
59012 ?        Sl    10:19 /snap/firefox/3416/usr/lib/firefox/firefox -contentproc -childID 30 -isForBrowser -prefsLen 30466 -prefMapSize 234812 -jsInitLen 228948 -parentBuildID 20231116210351 -greomni /snap/firefox/3416/usr/lib/firefox/omni.ja -appomni /snap/firefox/3416/usr/lib/firefox/browser/omni.ja -appDir /snap/firefox/3416/usr/lib/firefox/browser {bd6fe7a6-f1bb-4c9d-92ee-ca2adbf013b9} 6718 true tab
59015 ?        Sl     0:01 /snap/firefox/3416/usr/lib/firefox/firefox -contentproc -childID 31 -isForBrowser -prefsLen 30466 -prefMapSize 234812 -jsInitLen 228948 -parentBuildID 20231116210351 -greomni /snap/firefox/3416/usr/lib/firefox/omni.ja -appomni /snap/firefox/3416/usr/lib/firefox/browser/omni.ja -appDir /snap/firefox/3416/usr/lib/firefox/browser {ba406a2b-1f36-4633-b6dc-1245359ad576} 6718 true tab
59098 ?        Sl     0:00 /snap/firefox/3416/usr/lib/firefox/firefox -contentproc -childID 33 -isForBrowser -prefsLen 30466 -prefMapSize 234812 -jsInitLen 228948 -parentBuildID 20231116210351 -greomni /snap/firefox/3416/usr/lib/firefox/omni.ja -appomni /snap/firefox/3416/usr/lib/firefox/browser/omni.ja -appDir /snap/firefox/3416/usr/lib/firefox/browser {86428d42-d50c-46e5-98dc-df0b78f873eb} 6718 true tab
59131 ?        Sl     0:00 /snap/firefox/3416/usr/lib/firefox/firefox -contentproc -childID 34 -isForBrowser -prefsLen 30466 -prefMapSize 234812 -jsInitLen 228948 -parentBuildID 20231116210351 -greomni /snap/firefox/3416/usr/lib/firefox/omni.ja -appomni /snap/firefox/3416/usr/lib/firefox/browser/omni.ja -appDir /snap/firefox/3416/usr/lib/firefox/browser {0d58e2e2-ad79-4f18-9f6d-dbf21d45e8b3} 6718 true tab
59162 ?        Sl     0:00 /snap/firefox/3416/usr/lib/firefox/firefox -contentproc -childID 35 -isForBrowser -prefsLen 30466 -prefMapSize 234812 -jsInitLen 228948 -parentBuildID 20231116210351 -greomni /snap/firefox/3416/usr/lib/firefox/omni.ja -appomni /snap/firefox/3416/usr/lib/firefox/browser/omni.ja -appDir /snap/firefox/3416/usr/lib/firefox/browser {17c621b4-2364-4c52-9573-88f2b8355946} 6718 true tab
59242 ?        I      0:00 [kworker/0:2-events]
59244 ?        I      0:00 [kworker/4:2-events]
59245 ?        I      0:00 [kworker/2:2]
59435 ?        I      0:01 [kworker/u32:3-events_power_efficient]
59456 ?        I<     0:00 [kworker/u33:1-rtw_tx_wq]
59492 ?        I      0:00 [kworker/1:2]
59493 ?        I      0:00 [kworker/5:1-mm_percpu_wq]
59499 ?        I<     0:00 [kworker/u33:0-rtw_tx_wq]
59521 ?        I      0:00 [kworker/u32:4-events_power_efficient]
59664 ?        Sl     0:00 /usr/bin/gedit --gapplication-service
59704 ?        I<     0:00 [kworker/u33:2-rtw_tx_wq]
59706 ?        I      0:00 [kworker/u32:2-events_unbound]
59710 pts/0    R+     0:00 ps ax

```

</details>
