vkan@l04-ubuntu:~/Documents/DZ/disk system$ vagrant up
Bringing machine 'otuslinux' up with 'virtualbox' provider...
==> otuslinux: Checking if box 'centos/7' version '2004.01' is up to date...
==> otuslinux: There was a problem while downloading the metadata for your box
==> otuslinux: to check for updates. This is not an error, since it is usually due
==> otuslinux: to temporary network problems. This is just a warning. The problem
==> otuslinux: encountered was:
==> otuslinux:
==> otuslinux: The requested URL returned error: 404
==> otuslinux:
==> otuslinux: If you want to check for box updates, verify your network connection
==> otuslinux: is valid and try again.
==> otuslinux: Clearing any previously set forwarded ports...
==> otuslinux: Clearing any previously set network interfaces...
==> otuslinux: Preparing network interfaces based on configuration...
    otuslinux: Adapter 1: nat
    otuslinux: Adapter 2: hostonly
==> otuslinux: Forwarding ports...
    otuslinux: 22 (guest) => 2222 (host) (adapter 1)
==> otuslinux: Running 'pre-boot' VM customizations...
==> otuslinux: Booting VM...
==> otuslinux: Waiting for machine to boot. This may take a few minutes...
    otuslinux: SSH address: 127.0.0.1:2222
    otuslinux: SSH username: vagrant
    otuslinux: SSH auth method: private key
==> otuslinux: Machine booted and ready!
==> otuslinux: Checking for guest additions in VM...
    otuslinux: No guest additions were detected on the base box for this VM! Guest
    otuslinux: additions are required for forwarded ports, shared folders, host only
    otuslinux: networking, and more. If SSH fails on this machine, please install
    otuslinux: the guest additions and repackage the box to continue.
    otuslinux:
    otuslinux: This is not an error message; everything may continue to work properly,
    otuslinux: in which case you may ignore this message.
==> otuslinux: Setting hostname...
==> otuslinux: Configuring and enabling network interfaces...
==> otuslinux: Rsyncing folder: /home/vkan/Documents/DZ/disk system/ => /vagrant
==> otuslinux: Machine already provisioned. Run `vagrant provision` or use the `--provision`
==> otuslinux: flag to force provisioning. Provisioners marked to run always will still run.
vkan@l04-ubuntu:~/Documents/DZ/disk system$ vagrant ssh
Last login: Wed Nov 22 06:11:56 2023 from 10.0.2.2
[vagrant@otuslinux ~]$ exit
logout
vkan@l04-ubuntu:~/Documents/DZ/disk system$ vagrant up
Bringing machine 'otuslinux' up with 'virtualbox' provider...
==> otuslinux: Checking if box 'centos/7' version '2004.01' is up to date...
==> otuslinux: Machine already provisioned. Run `vagrant provision` or use the `--provision`
==> otuslinux: flag to force provisioning. Provisioners marked to run always will still run.
vkan@l04-ubuntu:~/Documents/DZ/disk system$ vagrant up --provision
Bringing machine 'otuslinux' up with 'virtualbox' provider...
==> otuslinux: Checking if box 'centos/7' version '2004.01' is up to date...
==> otuslinux: Running provisioner: shell...
    otuslinux: Running: inline script
    otuslinux: Loaded plugins: fastestmirror
    otuslinux: Loading mirror speeds from cached hostfile
    otuslinux:  * base: ftp.man.poznan.pl
    otuslinux:  * extras: ftp.man.poznan.pl
    otuslinux:  * updates: ftp.man.poznan.pl
    otuslinux: Package mdadm-4.1-9.el7_9.x86_64 already installed and latest version
    otuslinux: Package 1:smartmontools-7.0-2.el7.x86_64 already installed and latest version
    otuslinux: Package hdparm-9.43-5.el7.x86_64 already installed and latest version
    otuslinux: Package gdisk-0.8.10-3.el7.x86_64 already installed and latest version
    otuslinux: Nothing to do
vkan@l04-ubuntu:~/Documents/DZ/disk system$ vagrant destroy
    otuslinux: Are you sure you want to destroy the 'otuslinux' VM? [y/N] y
==> otuslinux: Forcing shutdown of VM...
==> otuslinux: Destroying VM and associated drives...
vkan@l04-ubuntu:~/Documents/DZ/disk system$ vagrant up
Bringing machine 'otuslinux' up with 'virtualbox' provider...
==> otuslinux: Importing base box 'centos/7'...
==> otuslinux: Matching MAC address for NAT networking...
==> otuslinux: Checking if box 'centos/7' version '2004.01' is up to date...
==> otuslinux: Setting the name of the VM: disksystem_otuslinux_1700781875532_28591
==> otuslinux: Clearing any previously set network interfaces...
==> otuslinux: Preparing network interfaces based on configuration...
    otuslinux: Adapter 1: nat
    otuslinux: Adapter 2: hostonly
==> otuslinux: Forwarding ports...
    otuslinux: 22 (guest) => 2222 (host) (adapter 1)
==> otuslinux: Running 'pre-boot' VM customizations...
==> otuslinux: Booting VM...
==> otuslinux: Waiting for machine to boot. This may take a few minutes...
    otuslinux: SSH address: 127.0.0.1:2222
    otuslinux: SSH username: vagrant
    otuslinux: SSH auth method: private key
    otuslinux:
    otuslinux: Vagrant insecure key detected. Vagrant will automatically replace
    otuslinux: this with a newly generated keypair for better security.
    otuslinux:
    otuslinux: Inserting generated public key within guest...
    otuslinux: Removing insecure key from the guest if it's present...
    otuslinux: Key inserted! Disconnecting and reconnecting using new SSH key...
==> otuslinux: Machine booted and ready!
==> otuslinux: Checking for guest additions in VM...
    otuslinux: No guest additions were detected on the base box for this VM! Guest
    otuslinux: additions are required for forwarded ports, shared folders, host only
    otuslinux: networking, and more. If SSH fails on this machine, please install
    otuslinux: the guest additions and repackage the box to continue.
    otuslinux:
    otuslinux: This is not an error message; everything may continue to work properly,
    otuslinux: in which case you may ignore this message.
==> otuslinux: Setting hostname...
==> otuslinux: Configuring and enabling network interfaces...
==> otuslinux: Rsyncing folder: /home/vkan/Documents/DZ/disk system/ => /vagrant
==> otuslinux: Running provisioner: shell...
    otuslinux: Running: inline script
    otuslinux: Loaded plugins: fastestmirror
    otuslinux: Determining fastest mirrors
    otuslinux:  * base: ftp.pbone.net
    otuslinux:  * extras: ftp.pbone.net
    otuslinux:  * updates: ftp.pbone.net
    otuslinux: Resolving Dependencies
    otuslinux: --> Running transaction check
    otuslinux: ---> Package gdisk.x86_64 0:0.8.10-3.el7 will be installed
    otuslinux: ---> Package hdparm.x86_64 0:9.43-5.el7 will be installed
    otuslinux: ---> Package mdadm.x86_64 0:4.1-9.el7_9 will be installed
    otuslinux: --> Processing Dependency: libreport-filesystem for package: mdadm-4.1-9.el7_9.x86_64
    otuslinux: ---> Package smartmontools.x86_64 1:7.0-2.el7 will be installed
    otuslinux: --> Processing Dependency: mailx for package: 1:smartmontools-7.0-2.el7.x86_64
    otuslinux: --> Running transaction check
    otuslinux: ---> Package libreport-filesystem.x86_64 0:2.1.11-53.el7.centos will be installed
    otuslinux: ---> Package mailx.x86_64 0:12.5-19.el7 will be installed
    otuslinux: --> Finished Dependency Resolution
    otuslinux:
    otuslinux: Dependencies Resolved
    otuslinux:
    otuslinux: ================================================================================
    otuslinux:  Package                  Arch       Version                  Repository   Size
    otuslinux: ================================================================================
    otuslinux: Installing:
    otuslinux:  gdisk                    x86_64     0.8.10-3.el7             base        190 k
    otuslinux:  hdparm                   x86_64     9.43-5.el7               base         83 k
    otuslinux:  mdadm                    x86_64     4.1-9.el7_9              updates     439 k
    otuslinux:  smartmontools            x86_64     1:7.0-2.el7              base        546 k
    otuslinux: Installing for dependencies:
    otuslinux:  libreport-filesystem     x86_64     2.1.11-53.el7.centos     base         41 k
    otuslinux:  mailx                    x86_64     12.5-19.el7              base        245 k
    otuslinux:
    otuslinux: Transaction Summary
    otuslinux: ================================================================================
    otuslinux: Install  4 Packages (+2 Dependent packages)
    otuslinux:
    otuslinux: Total download size: 1.5 M
    otuslinux: Installed size: 4.3 M
    otuslinux: Downloading packages:
    otuslinux: Public key for libreport-filesystem-2.1.11-53.el7.centos.x86_64.rpm is not installed
    otuslinux: warning: /var/cache/yum/x86_64/7/base/packages/libreport-filesystem-2.1.11-53.el7.centos.x86_64.rpm: Header V3 RSA/SHA256 Signature, key ID f4a80eb5: NOKEY
    otuslinux: Public key for mdadm-4.1-9.el7_9.x86_64.rpm is not installed
    otuslinux: --------------------------------------------------------------------------------
    otuslinux: Total                                              158 kB/s | 1.5 MB  00:09
    otuslinux: Retrieving key from file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
    otuslinux: Importing GPG key 0xF4A80EB5:
    otuslinux:  Userid     : "CentOS-7 Key (CentOS 7 Official Signing Key) <security@centos.org>"
    otuslinux:  Fingerprint: 6341 ab27 53d7 8a78 a7c2 7bb1 24c6 a8a7 f4a8 0eb5
    otuslinux:  Package    : centos-release-7-8.2003.0.el7.centos.x86_64 (@anaconda)
    otuslinux:  From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
    otuslinux: Running transaction check
    otuslinux: Running transaction test
    otuslinux: Transaction test succeeded
    otuslinux: Running transaction
    otuslinux:   Installing : libreport-filesystem-2.1.11-53.el7.centos.x86_64             1/6
    otuslinux:   Installing : mailx-12.5-19.el7.x86_64                                     2/6
    otuslinux:   Installing : 1:smartmontools-7.0-2.el7.x86_64                             3/6
    otuslinux:   Installing : mdadm-4.1-9.el7_9.x86_64                                     4/6
    otuslinux:   Installing : hdparm-9.43-5.el7.x86_64                                     5/6
    otuslinux:   Installing : gdisk-0.8.10-3.el7.x86_64                                    6/6
    otuslinux:   Verifying  : mdadm-4.1-9.el7_9.x86_64                                     1/6
    otuslinux:   Verifying  : 1:smartmontools-7.0-2.el7.x86_64                             2/6
    otuslinux:   Verifying  : gdisk-0.8.10-3.el7.x86_64                                    3/6
    otuslinux:   Verifying  : mailx-12.5-19.el7.x86_64                                     4/6
    otuslinux:   Verifying  : hdparm-9.43-5.el7.x86_64                                     5/6
    otuslinux:   Verifying  : libreport-filesystem-2.1.11-53.el7.centos.x86_64             6/6
    otuslinux:
    otuslinux: Installed:
    otuslinux:   gdisk.x86_64 0:0.8.10-3.el7          hdparm.x86_64 0:9.43-5.el7
    otuslinux:   mdadm.x86_64 0:4.1-9.el7_9           smartmontools.x86_64 1:7.0-2.el7
    otuslinux:
    otuslinux: Dependency Installed:
    otuslinux:   libreport-filesystem.x86_64 0:2.1.11-53.el7.centos mailx.x86_64 0:12.5-19.el7
    otuslinux:
    otuslinux: Complete!
vkan@l04-ubuntu:~/Documents/DZ/disk system$ vagrant ssh
[vagrant@otuslinux ~]$ lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   40G  0 disk
`-sda1   8:1    0   40G  0 part /
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
`-sda1      8:1    0   40G  0 part  /
sdb         8:16   0  250M  0 disk  
`-md0       9:0    0  992M  0 raid5
  |-md0p1 259:0    0  196M  0 md    /raid/part1
  |-md0p2 259:1    0  198M  0 md    /raid/part2
  |-md0p3 259:2    0  200M  0 md    /raid/part3
  |-md0p4 259:3    0  198M  0 md    /raid/part4
  `-md0p5 259:4    0  196M  0 md    /raid/part5
sdc         8:32   0  250M  0 disk  
`-md0       9:0    0  992M  0 raid5
  |-md0p1 259:0    0  196M  0 md    /raid/part1
  |-md0p2 259:1    0  198M  0 md    /raid/part2
  |-md0p3 259:2    0  200M  0 md    /raid/part3
  |-md0p4 259:3    0  198M  0 md    /raid/part4
  `-md0p5 259:4    0  196M  0 md    /raid/part5
sdd         8:48   0  250M  0 disk  
`-md0       9:0    0  992M  0 raid5
  |-md0p1 259:0    0  196M  0 md    /raid/part1
  |-md0p2 259:1    0  198M  0 md    /raid/part2
  |-md0p3 259:2    0  200M  0 md    /raid/part3
  |-md0p4 259:3    0  198M  0 md    /raid/part4
  `-md0p5 259:4    0  196M  0 md    /raid/part5
sde         8:64   0  250M  0 disk  
`-md0       9:0    0  992M  0 raid5
  |-md0p1 259:0    0  196M  0 md    /raid/part1
  |-md0p2 259:1    0  198M  0 md    /raid/part2
  |-md0p3 259:2    0  200M  0 md    /raid/part3
  |-md0p4 259:3    0  198M  0 md    /raid/part4
  `-md0p5 259:4    0  196M  0 md    /raid/part5
sdf         8:80   0  250M  0 disk  
`-md0       9:0    0  992M  0 raid5
  |-md0p1 259:0    0  196M  0 md    /raid/part1
  |-md0p2 259:1    0  198M  0 md    /raid/part2
  |-md0p3 259:2    0  200M  0 md    /raid/part3
  |-md0p4 259:3    0  198M  0 md    /raid/part4
  `-md0p5 259:4    0  196M  0 md    /raid/part5
