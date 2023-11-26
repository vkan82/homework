# Disk system

Запускаем ВМ с помощью Vagrantfile (/homework/02/Vagrantfile).
Подключаемся с помощью vagrant ssh.
Ниже процесс уменьшения размера тома, команды и результаты:

```shell
vkan@l04-ubuntu:~/Documents/DZ/disk system$ vagrant up
vkan@l04-ubuntu:~/Documents/DZ/disk system$ vagrant ssh
[vagrant@otuslinux ~]$ lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   40G  0 disk
-sda1   8:1    0   40G  0 part /
sdb      8:16   0  250M  0 disk
sdc      8:32   0  250M  0 disk
sdd      8:48   0  250M  0 disk
sde      8:64   0  250M  0 disk
sdf      8:80   0  250M  0 disk
[vagrant@otuslinux ~]$                 :sata4 => {
-bash: :sata4: command not found
[vagrant@otuslinux ~]$                         :dfile => './sata4.vdi',
-bash: :dfile: command not found
[vagrant@otuslinux ~]$                         :size => 250,
-bash: :size: command not found
[vagrant@otuslinux ~]$                         :port => 4
-bash: :port: command not found
[vagrant@otuslinux ~]$ mdadm --zero-superblock --force /dev/sd{b,c,d,e,f}
mdadm: must be super-user to perform this action
[vagrant@otuslinux ~]$ sudo mdadm --zero-superblock --force /dev/sd{b,c,d,e,f}
mdadm: Unrecognised md component device - /dev/sdb
mdadm: Unrecognised md component device - /dev/sdc
mdadm: Unrecognised md component device - /dev/sdd
mdadm: Unrecognised md component device - /dev/sde
mdadm: Unrecognised md component device - /dev/sdf
[vagrant@otuslinux ~]$ sudo mdadm --create --verbose /dev/md0 -l 5 -n 5 /dev/sd{b,c,d,e,f}
mdadm: layout defaults to left-symmetric
mdadm: layout defaults to left-symmetric
mdadm: chunk size defaults to 512K
mdadm: size set to 253952K
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.
[vagrant@otuslinux ~]$ cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4]
md0 : active raid5 sdf[5] sde[3] sdd[2] sdc[1] sdb[0]
      1015808 blocks super 1.2 level 5, 512k chunk, algorithm 2 [5/5] [UUUUU]

unused devices: <none>
[vagrant@otuslinux ~]$ sudo mdadm -D /dev/md0
/dev/md0:
           Version : 1.2
     Creation Time : Thu Nov 23 23:31:04 2023
        Raid Level : raid5
        Array Size : 1015808 (992.00 MiB 1040.19 MB)
     Used Dev Size : 253952 (248.00 MiB 260.05 MB)
      Raid Devices : 5
     Total Devices : 5
       Persistence : Superblock is persistent

       Update Time : Thu Nov 23 23:31:07 2023
             State : clean
    Active Devices : 5
   Working Devices : 5
    Failed Devices : 0
     Spare Devices : 0

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

              Name : otuslinux:0  (local to host otuslinux)
              UUID : 9c156e70:058e980f:a7ce3717:382ae298
            Events : 18

    Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync   /dev/sdb
       1       8       32        1      active sync   /dev/sdc
       2       8       48        2      active sync   /dev/sdd
       3       8       64        3      active sync   /dev/sde
       5       8       80        4      active sync   /dev/sdf
[vagrant@otuslinux ~]$ sudo mdadm --detail --scan --verbose
ARRAY /dev/md0 level=raid5 num-devices=5 metadata=1.2 name=otuslinux:0 UUID=9c156e70:058e980f:a7ce3717:382ae298
   devices=/dev/sdb,/dev/sdc,/dev/sdd,/dev/sde,/dev/sdf
[vagrant@otuslinux ~]$ sudo mkdir /etc/mdadm
[vagrant@otuslinux mdadm]$ sudo -i
[root@otuslinux ~]# echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
[root@otuslinux ~]# mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf
[root@otuslinux ~]# cat /etc/mdadm/mdadm.conf
DEVICE partitions
ARRAY /dev/md0 level=raid5 num-devices=5 metadata=1.2 name=otuslinux:0 UUID=9c156e70:058e980f:a7ce3717:382ae298
[root@otuslinux ~]# exit
logout
[vagrant@otuslinux mdadm]$ sudo mdadm /dev/md0 --fail /dev/sde
mdadm: set /dev/sde faulty in /dev/md0
[vagrant@otuslinux mdadm]$ cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4]
md0 : active raid5 sdf[5] sde[3](F) sdd[2] sdc[1] sdb[0]
      1015808 blocks super 1.2 level 5, 512k chunk, algorithm 2 [5/4] [UUU_U]

unused devices: <none>
[vagrant@otuslinux mdadm]$ sudo mdadm -D /dev/md0
/dev/md0:
           Version : 1.2
     Creation Time : Thu Nov 23 23:31:04 2023
        Raid Level : raid5
        Array Size : 1015808 (992.00 MiB 1040.19 MB)
     Used Dev Size : 253952 (248.00 MiB 260.05 MB)
      Raid Devices : 5
     Total Devices : 5
       Persistence : Superblock is persistent

       Update Time : Thu Nov 23 23:42:44 2023
             State : clean, degraded
    Active Devices : 4
   Working Devices : 4
    Failed Devices : 1
     Spare Devices : 0

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

              Name : otuslinux:0  (local to host otuslinux)
              UUID : 9c156e70:058e980f:a7ce3717:382ae298
            Events : 20

    Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync   /dev/sdb
       1       8       32        1      active sync   /dev/sdc
       2       8       48        2      active sync   /dev/sdd
       -       0        0        3      removed
       5       8       80        4      active sync   /dev/sdf

       3       8       64        -      faulty   /dev/sde
[vagrant@otuslinux mdadm]$ sudo mdadm /dev/md0 --remove /dev/sde
mdadm: hot removed /dev/sde from /dev/md0
[vagrant@otuslinux mdadm]$ sudo mdadm /dev/md0 --add /dev/sde
mdadm: added /dev/sde
[vagrant@otuslinux mdadm]$ cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4]
md0 : active raid5 sde[6] sdf[5] sdd[2] sdc[1] sdb[0]
      1015808 blocks super 1.2 level 5, 512k chunk, algorithm 2 [5/5] [UUUUU]

unused devices: <none>
[vagrant@otuslinux mdadm]$ sudo mdadm -D /dev/md0
/dev/md0:
           Version : 1.2
     Creation Time : Thu Nov 23 23:31:04 2023
        Raid Level : raid5
        Array Size : 1015808 (992.00 MiB 1040.19 MB)
     Used Dev Size : 253952 (248.00 MiB 260.05 MB)
      Raid Devices : 5
     Total Devices : 5
       Persistence : Superblock is persistent

       Update Time : Thu Nov 23 23:44:25 2023
             State : clean
    Active Devices : 5
   Working Devices : 5
    Failed Devices : 0
     Spare Devices : 0

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

              Name : otuslinux:0  (local to host otuslinux)
              UUID : 9c156e70:058e980f:a7ce3717:382ae298
            Events : 40

    Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync   /dev/sdb
       1       8       32        1      active sync   /dev/sdc
       2       8       48        2      active sync   /dev/sdd
       6       8       64        3      active sync   /dev/sde
       5       8       80        4      active sync   /dev/sdf
[vagrant@otuslinux mdadm]$ sudo parted -s /dev/md0 mklabel gpt
[vagrant@otuslinux mdadm]$ sudo parted /dev/md0 mkpart primary ext4 0% 20%
Information: You may need to update /etc/fstab.

[vagrant@otuslinux mdadm]$ sudo parted /dev/md0 mkpart primary ext4 20% 40%
Information: You may need to update /etc/fstab.

[vagrant@otuslinux mdadm]$ sudo parted /dev/md0 mkpart primary ext4 40% 60%
Information: You may need to update /etc/fstab.

[vagrant@otuslinux mdadm]$ sudo parted /dev/md0 mkpart primary ext4 60% 80%
Information: You may need to update /etc/fstab.

[vagrant@otuslinux mdadm]$ sudo parted /dev/md0 mkpart primary ext4 80% 100%
Information: You may need to update /etc/fstab.

[vagrant@otuslinux mdadm]$ for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$i; done
mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=1024 (log=0)
Fragment size=1024 (log=0)
Stride=512 blocks, Stripe width=2048 blocks
50200 inodes, 200704 blocks
10035 blocks (5.00%) reserved for the super user
First data block=1
Maximum filesystem blocks=33816576
25 block groups
8192 blocks per group, 8192 fragments per group
2008 inodes per group
Superblock backups stored on blocks:
	8193, 24577, 40961, 57345, 73729

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done

mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=1024 (log=0)
Fragment size=1024 (log=0)
Stride=512 blocks, Stripe width=2048 blocks
50800 inodes, 202752 blocks
10137 blocks (5.00%) reserved for the super user
First data block=1
Maximum filesystem blocks=33816576
25 block groups
8192 blocks per group, 8192 fragments per group
2032 inodes per group
Superblock backups stored on blocks:
	8193, 24577, 40961, 57345, 73729

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done

mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=1024 (log=0)
Fragment size=1024 (log=0)
Stride=512 blocks, Stripe width=2048 blocks
51200 inodes, 204800 blocks
10240 blocks (5.00%) reserved for the super user
First data block=1
Maximum filesystem blocks=33816576
25 block groups
8192 blocks per group, 8192 fragments per group
2048 inodes per group
Superblock backups stored on blocks:
	8193, 24577, 40961, 57345, 73729

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done

mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=1024 (log=0)
Fragment size=1024 (log=0)
Stride=512 blocks, Stripe width=2048 blocks
50800 inodes, 202752 blocks
10137 blocks (5.00%) reserved for the super user
First data block=1
Maximum filesystem blocks=33816576
25 block groups
8192 blocks per group, 8192 fragments per group
2032 inodes per group
Superblock backups stored on blocks:
	8193, 24577, 40961, 57345, 73729

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done

mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=1024 (log=0)
Fragment size=1024 (log=0)
Stride=512 blocks, Stripe width=2048 blocks
50200 inodes, 200704 blocks
10035 blocks (5.00%) reserved for the super user
First data block=1
Maximum filesystem blocks=33816576
25 block groups
8192 blocks per group, 8192 fragments per group
2008 inodes per group
Superblock backups stored on blocks:
	8193, 24577, 40961, 57345, 73729

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done

[vagrant@otuslinux mdadm]$ sudo mkdir -p /raid/part{1,2,3,4,5}
[vagrant@otuslinux mdadm]$ for i in $(seq 1 5); do sudo mount /dev/md0p$i /raid/part$i; done
[vagrant@otuslinux mdadm]$ lsblk
NAME      MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
sda         8:0    0   40G  0 disk  
-sda1      8:1    0   40G  0 part  /
sdb         8:16   0  250M  0 disk  
-md0       9:0    0  992M  0 raid5
  |-md0p1 259:0    0  196M  0 md    /raid/part1
  |-md0p2 259:1    0  198M  0 md    /raid/part2
  |-md0p3 259:2    0  200M  0 md    /raid/part3
  |-md0p4 259:3    0  198M  0 md    /raid/part4
  -md0p5 259:4    0  196M  0 md    /raid/part5
sdc         8:32   0  250M  0 disk  
-md0       9:0    0  992M  0 raid5
  |-md0p1 259:0    0  196M  0 md    /raid/part1
  |-md0p2 259:1    0  198M  0 md    /raid/part2
  |-md0p3 259:2    0  200M  0 md    /raid/part3
  |-md0p4 259:3    0  198M  0 md    /raid/part4
  -md0p5 259:4    0  196M  0 md    /raid/part5
sdd         8:48   0  250M  0 disk  
-md0       9:0    0  992M  0 raid5
  |-md0p1 259:0    0  196M  0 md    /raid/part1
  |-md0p2 259:1    0  198M  0 md    /raid/part2
  |-md0p3 259:2    0  200M  0 md    /raid/part3
  |-md0p4 259:3    0  198M  0 md    /raid/part4
  -md0p5 259:4    0  196M  0 md    /raid/part5
sde         8:64   0  250M  0 disk  
-md0       9:0    0  992M  0 raid5
  |-md0p1 259:0    0  196M  0 md    /raid/part1
  |-md0p2 259:1    0  198M  0 md    /raid/part2
  |-md0p3 259:2    0  200M  0 md    /raid/part3
  |-md0p4 259:3    0  198M  0 md    /raid/part4
  -md0p5 259:4    0  196M  0 md    /raid/part5
sdf         8:80   0  250M  0 disk  
-md0       9:0    0  992M  0 raid5
  |-md0p1 259:0    0  196M  0 md    /raid/part1
  |-md0p2 259:1    0  198M  0 md    /raid/part2
  |-md0p3 259:2    0  200M  0 md    /raid/part3
  |-md0p4 259:3    0  198M  0 md    /raid/part4
  -md0p5 259:4    0  196M  0 md    /raid/part5
```
