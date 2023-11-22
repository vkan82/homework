***************************************************************************
1) Обновить ядро ОС из репозитория ELRepo.
***************************************************************************

Создал Vagrant файл, на основе которого произвел запуск ВМ и обновление ядра ОС.
 Содержание Vagrant файла:
 # Описываем Виртуальные машины
MACHINES = {
  # Указываем имя ВМ "kernel update"
  :"kernel-update" => {
              #Какой vm box будем использовать
              :box_name => "generic/centos8",
              #Указываем box_version
              :box_version => "4.2.16",
              #Указываем количество ядер ВМ
              :cpus => 2,
              #Указываем количество ОЗУ в мегабайтах
              :memory => 1024,
            }
}

Vagrant.configure("2") do |config|
  MACHINES.each do |boxname, boxconfig|
    # Отключаем проброс общей папки в ВМ
    config.vm.synced_folder ".", "/vagrant", disabled: true
    # Применяем конфигурацию ВМ
    config.vm.define boxname do |box|
      box.vm.box = boxconfig[:box_name]
      box.vm.box_version = boxconfig[:box_version]
      box.vm.host_name = boxname.to_s
      box.vm.provider "virtualbox" do |v|
        v.memory = boxconfig[:memory]
        v.cpus = boxconfig[:cpus]
      end
    end
  end
end

Запустил ВМ командой vagrant up, подключился по ssh командой vagrant ssh, обновил ядро ОС, ниже копия всех команд и действий.

vkan@l04-ubuntu:~/Documents/hw_1$ vagrant up
Bringing machine 'kernel-update' up with 'virtualbox' provider...
==> kernel-update: Box 'generic/centos8' could not be found. Attempting to find and install...
    kernel-update: Box Provider: virtualbox
    kernel-update: Box Version: 4.2.16
==> kernel-update: Loading metadata for box 'generic/centos8'
    kernel-update: URL: https://vagrantcloud.com/generic/centos8
==> kernel-update: Adding box 'generic/centos8' (v4.2.16) for provider: virtualbox
    kernel-update: Downloading: https://vagrantcloud.com/generic/boxes/centos8/versions/4.2.16/providers/virtualbox.box
    kernel-update: Calculating and comparing box checksum...
==> kernel-update: Successfully added box 'generic/centos8' (v4.2.16) for 'virtualbox'!
==> kernel-update: Importing base box 'generic/centos8'...
==> kernel-update: Matching MAC address for NAT networking...
==> kernel-update: Checking if box 'generic/centos8' version '4.2.16' is up to date...
==> kernel-update: Setting the name of the VM: hw_1_kernel-update_1688561600092_6842
==> kernel-update: Clearing any previously set network interfaces...
==> kernel-update: Preparing network interfaces based on configuration...
    kernel-update: Adapter 1: nat
==> kernel-update: Forwarding ports...
    kernel-update: 22 (guest) => 2222 (host) (adapter 1)
==> kernel-update: Running 'pre-boot' VM customizations...
==> kernel-update: Booting VM...
==> kernel-update: Waiting for machine to boot. This may take a few minutes...
    kernel-update: SSH address: 127.0.0.1:2222
    kernel-update: SSH username: vagrant
    kernel-update: SSH auth method: private key
    kernel-update: 
    kernel-update: Vagrant insecure key detected. Vagrant will automatically replace
    kernel-update: this with a newly generated keypair for better security.
    kernel-update: 
    kernel-update: Inserting generated public key within guest...
    kernel-update: Removing insecure key from the guest if it's present...
    kernel-update: Key inserted! Disconnecting and reconnecting using new SSH key...
==> kernel-update: Machine booted and ready!
==> kernel-update: Checking for guest additions in VM...
==> kernel-update: Setting hostname...
vkan@l04-ubuntu:~/Documents/hw_1$ vagrant ssh
[vagrant@kernel-update ~]$ uname -r
4.18.0-348.7.1.el8_5.x86_64
[vagrant@kernel-update ~]$ sudo yum install -y https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm 
Failed to set locale, defaulting to C.UTF-8
CentOS Linux 8 - AppStream                      1.1 MB/s | 8.4 MB     00:07    
CentOS Linux 8 - BaseOS                         1.0 MB/s | 4.6 MB     00:04    
CentOS Linux 8 - Extras                         8.2 kB/s |  10 kB     00:01    
Extra Packages for Enterprise Linux 8 - x86_64  863 kB/s |  16 MB     00:18    
elrepo-release-8.el8.elrepo.noarch.rpm          5.6 kB/s |  13 kB     00:02    
Dependencies resolved.
================================================================================
 Package             Arch        Version                Repository         Size
================================================================================
Installing:
 elrepo-release      noarch      8.3-1.el8.elrepo       @commandline       13 k

Transaction Summary
================================================================================
Install  1 Package

Total size: 13 k
Installed size: 5.0 k
Downloading Packages:
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                        1/1 
  Installing       : elrepo-release-8.3-1.el8.elrepo.noarch                 1/1 
  Verifying        : elrepo-release-8.3-1.el8.elrepo.noarch                 1/1 

Installed:
  elrepo-release-8.3-1.el8.elrepo.noarch                                        

Complete!
[vagrant@kernel-update ~]$ sudo yum --enablerepo elrepo-kernel install kernel-ml -y
Failed to set locale, defaulting to C.UTF-8
ELRepo.org Community Enterprise Linux Repositor  91 kB/s | 284 kB     00:03    
ELRepo.org Community Enterprise Linux Kernel Re 1.0 MB/s | 3.2 MB     00:03    
Dependencies resolved.
================================================================================
 Package              Arch      Version                  Repository        Size
================================================================================
Installing:
 kernel-ml            x86_64    6.4.1-1.el8.elrepo       elrepo-kernel    112 k
Installing dependencies:
 kernel-ml-core       x86_64    6.4.1-1.el8.elrepo       elrepo-kernel     38 M
 kernel-ml-modules    x86_64    6.4.1-1.el8.elrepo       elrepo-kernel     34 M

Transaction Summary
================================================================================
Install  3 Packages

Total download size: 71 M
Installed size: 112 M
Downloading Packages:
(1/3): kernel-ml-6.4.1-1.el8.elrepo.x86_64.rpm  125 kB/s | 112 kB     00:00    
(2/3): kernel-ml-modules-6.4.1-1.el8.elrepo.x86 2.4 MB/s |  34 MB     00:14    
(3/3): kernel-ml-core-6.4.1-1.el8.elrepo.x86_64 2.4 MB/s |  38 MB     00:16    
--------------------------------------------------------------------------------
Total                                           4.3 MB/s |  71 MB     00:16     
ELRepo.org Community Enterprise Linux Kernel Re 1.6 MB/s | 1.7 kB     00:00    
Importing GPG key 0xBAADAE52:
 Userid     : "elrepo.org (RPM Signing Key for elrepo.org) <secure@elrepo.org>"
 Fingerprint: 96C0 104F 6315 4731 1E0B B1AE 309B C305 BAAD AE52
 From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-elrepo.org
Key imported successfully
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                        1/1 
  Installing       : kernel-ml-core-6.4.1-1.el8.elrepo.x86_64               1/3 
  Running scriptlet: kernel-ml-core-6.4.1-1.el8.elrepo.x86_64               1/3 
  Installing       : kernel-ml-modules-6.4.1-1.el8.elrepo.x86_64            2/3 
  Running scriptlet: kernel-ml-modules-6.4.1-1.el8.elrepo.x86_64            2/3 
  Installing       : kernel-ml-6.4.1-1.el8.elrepo.x86_64                    3/3 
  Running scriptlet: kernel-ml-core-6.4.1-1.el8.elrepo.x86_64               3/3 
  Running scriptlet: kernel-ml-6.4.1-1.el8.elrepo.x86_64                    3/3 
  Verifying        : kernel-ml-6.4.1-1.el8.elrepo.x86_64                    1/3 
  Verifying        : kernel-ml-core-6.4.1-1.el8.elrepo.x86_64               2/3 
  Verifying        : kernel-ml-modules-6.4.1-1.el8.elrepo.x86_64            3/3 

Installed:
  kernel-ml-6.4.1-1.el8.elrepo.x86_64                                           
  kernel-ml-core-6.4.1-1.el8.elrepo.x86_64                                      
  kernel-ml-modules-6.4.1-1.el8.elrepo.x86_64                                   

Complete!
[vagrant@kernel-update ~]$ reboot
Failed to set wall message, ignoring: Interactive authentication required.
Failed to reboot system via logind: Interactive authentication required.
Failed to open initctl fifo: Permission denied
Failed to talk to init daemon.
[vagrant@kernel-update ~]$ Connection to 127.0.0.1 closed by remote host.
vkan@l04-ubuntu:~/Documents/hw_1$ vagrant ssh
Last login: Wed Jul  5 13:23:49 2023 from 10.0.2.2
[vagrant@kernel-update ~]$ uname -r
4.18.0-348.7.1.el8_5.x86_64
[vagrant@kernel-update ~]$ sudo grub2-mkconfig -o /boot/grub2/grub.cfg
Generating grub configuration file ...
done
[vagrant@kernel-update ~]$ nano /boot/grub2/grub.cfg
-bash: nano: command not found
[vagrant@kernel-update ~]$ sudo nano /boot/grub2/grub.cfg
sudo: nano: command not found
[vagrant@kernel-update ~]$ sudo yum install nano
Failed to set locale, defaulting to C.UTF-8
CentOS Linux 8 - AppStream                      3.1 kB/s | 4.3 kB     00:01    
CentOS Linux 8 - BaseOS                         5.1 kB/s | 3.9 kB     00:00    
CentOS Linux 8 - Extras                         2.3 kB/s | 1.5 kB     00:00    
ELRepo.org Community Enterprise Linux Repositor 465  B/s | 3.0 kB     00:06    
Extra Packages for Enterprise Linux 8 - x86_64   14 kB/s |  28 kB     00:02    
Dependencies resolved.
================================================================================
 Package        Architecture     Version                 Repository        Size
================================================================================
Installing:
 nano           x86_64           2.9.8-1.el8             baseos           581 k

Transaction Summary
================================================================================
Install  1 Package

Total download size: 581 k
Installed size: 2.2 M
Is this ok [y/N]: y
Downloading Packages:
nano-2.9.8-1.el8.x86_64.rpm                     110 kB/s | 581 kB     00:05    
--------------------------------------------------------------------------------
Total                                           110 kB/s | 581 kB     00:05     
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                        1/1 
  Installing       : nano-2.9.8-1.el8.x86_64                                1/1 
  Running scriptlet: nano-2.9.8-1.el8.x86_64                                1/1 
  Verifying        : nano-2.9.8-1.el8.x86_64                                1/1 

Installed:
  nano-2.9.8-1.el8.x86_64                                                       

Complete!
[vagrant@kernel-update ~]$ sudo nano /boot/grub2/grub.cfg
[vagrant@kernel-update ~]$ sudo reboot
Connection to 127.0.0.1 closed by remote host.
vkan@l04-ubuntu:~/Documents/hw_1$ vagrant ssh
^C
vkan@l04-ubuntu:~/Documents/hw_1$ vagrant ssh
Last login: Wed Jul  5 13:37:16 2023 from 10.0.2.2
[vagrant@kernel-update ~]$ rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
error: can't create transaction lock on /var/lib/rpm/.rpm.lock (Permission denied)
error: https://www.elrepo.org/RPM-GPG-KEY-elrepo.org: key 1 import failed.
[vagrant@kernel-update ~]$ sudo yum install https://www.elrepo.org/elrepo-release-8.0-2.el8.elrepo.noarch.rpm
Failed to set locale, defaulting to C.UTF-8
CentOS Linux 8 - AppStream                      3.0 kB/s | 4.3 kB     00:01    
CentOS Linux 8 - BaseOS                         6.1 kB/s | 3.9 kB     00:00    
CentOS Linux 8 - Extras                         2.7 kB/s | 1.5 kB     00:00    
ELRepo.org Community Enterprise Linux Repositor 2.0 kB/s | 3.0 kB     00:01    
Extra Packages for Enterprise Linux 8 - x86_64   16 kB/s |  28 kB     00:01    
elrepo-release-8.0-2.el8.elrepo.noarch.rpm      9.2 kB/s |  12 kB     00:01    
Dependencies resolved.
================================================================================
 Package             Arch        Version                Repository         Size
================================================================================
Downgrading:
 elrepo-release      noarch      8.0-2.el8.elrepo       @commandline       12 k

Transaction Summary
================================================================================
Downgrade  1 Package

Total size: 12 k
Is this ok [y/N]: y
Downloading Packages:
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                        1/1 
  Downgrading      : elrepo-release-8.0-2.el8.elrepo.noarch                 1/2 
  Cleanup          : elrepo-release-8.3-1.el8.elrepo.noarch                 2/2 
  Verifying        : elrepo-release-8.0-2.el8.elrepo.noarch                 1/2 
  Verifying        : elrepo-release-8.3-1.el8.elrepo.noarch                 2/2 

Downgraded:
  elrepo-release-8.0-2.el8.elrepo.noarch                                        

Complete!
[vagrant@kernel-update ~]$ yum repolist
Failed to set locale, defaulting to C.UTF-8
repo id           repo name
appstream         CentOS Linux 8 - AppStream
baseos            CentOS Linux 8 - BaseOS
elrepo            ELRepo.org Community Enterprise Linux Repository - el8
epel              Extra Packages for Enterprise Linux 8 - x86_64
extras            CentOS Linux 8 - Extras
[vagrant@kernel-update ~]$ sudo dnf --enablerepo=elrepo-kernel install kernel-ml 
Failed to set locale, defaulting to C.UTF-8
ELRepo.org Community Enterprise Linux Kernel Re 1.3 kB/s | 3.0 kB     00:02    
Package kernel-ml-6.4.1-1.el8.elrepo.x86_64 is already installed.
Dependencies resolved.
Nothing to do.
Complete!
[vagrant@kernel-update ~]$ uname -msr
Linux 4.18.0-348.7.1.el8_5.x86_64 x86_64
[vagrant@kernel-update ~]$ Connection to 127.0.0.1 closed by remote host.
vkan@l04-ubuntu:~/Documents/hw_1$ vagrant destroy
    kernel-update: Are you sure you want to destroy the 'kernel-update' VM? [y/N] y
==> kernel-update: Destroying VM and associated drives...
vkan@l04-ubuntu:~/Documents/hw_1$ vagrant up
Bringing machine 'kernel-update' up with 'virtualbox' provider...
==> kernel-update: Importing base box 'generic/centos8'...
==> kernel-update: Matching MAC address for NAT networking...
==> kernel-update: Checking if box 'generic/centos8' version '4.2.16' is up to date...
==> kernel-update: Setting the name of the VM: hw_1_kernel-update_1688566754600_78392
==> kernel-update: Clearing any previously set network interfaces...
==> kernel-update: Preparing network interfaces based on configuration...
    kernel-update: Adapter 1: nat
==> kernel-update: Forwarding ports...
    kernel-update: 22 (guest) => 2222 (host) (adapter 1)
==> kernel-update: Running 'pre-boot' VM customizations...
==> kernel-update: Booting VM...
==> kernel-update: Waiting for machine to boot. This may take a few minutes...
    kernel-update: SSH address: 127.0.0.1:2222
    kernel-update: SSH username: vagrant
    kernel-update: SSH auth method: private key
    kernel-update: 
    kernel-update: Vagrant insecure key detected. Vagrant will automatically replace
    kernel-update: this with a newly generated keypair for better security.
    kernel-update: 
    kernel-update: Inserting generated public key within guest...
    kernel-update: Removing insecure key from the guest if it's present...
    kernel-update: Key inserted! Disconnecting and reconnecting using new SSH key...
==> kernel-update: Machine booted and ready!
==> kernel-update: Checking for guest additions in VM...
==> kernel-update: Setting hostname...
vkan@l04-ubuntu:~/Documents/hw_1$ vagrant ssh
[vagrant@kernel-update ~]$ uname -r
4.18.0-348.7.1.el8_5.x86_64
[vagrant@kernel-update ~]$ sudo dnf install -y https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm 
Failed to set locale, defaulting to C.UTF-8
CentOS Linux 8 - AppStream                      768 kB/s | 8.4 MB     00:11    
CentOS Linux 8 - BaseOS                         432 kB/s | 4.6 MB     00:10    
CentOS Linux 8 - Extras                          10 kB/s |  10 kB     00:01    
Extra Packages for Enterprise Linux 8 - x86_64  1.4 MB/s |  16 MB     00:11    
elrepo-release-8.el8.elrepo.noarch.rpm          7.8 kB/s |  13 kB     00:01    
Dependencies resolved.
================================================================================
 Package             Arch        Version                Repository         Size
================================================================================
Installing:
 elrepo-release      noarch      8.3-1.el8.elrepo       @commandline       13 k

Transaction Summary
================================================================================
Install  1 Package

Total size: 13 k
Installed size: 5.0 k
Downloading Packages:
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                        1/1 
  Installing       : elrepo-release-8.3-1.el8.elrepo.noarch                 1/1 
  Verifying        : elrepo-release-8.3-1.el8.elrepo.noarch                 1/1 

Installed:
  elrepo-release-8.3-1.el8.elrepo.noarch                                        

Complete!
[vagrant@kernel-update ~]$ sudo dnf --enablerepo elrepo-kernel install kernel-ml -y
Failed to set locale, defaulting to C.UTF-8
ELRepo.org Community Enterprise Linux Repositor 101 kB/s | 284 kB     00:02    
ELRepo.org Community Enterprise Linux Kernel Re 588 kB/s | 3.2 MB     00:05    
Dependencies resolved.
================================================================================
 Package              Arch      Version                  Repository        Size
================================================================================
Installing:
 kernel-ml            x86_64    6.4.1-1.el8.elrepo       elrepo-kernel    112 k
Installing dependencies:
 kernel-ml-core       x86_64    6.4.1-1.el8.elrepo       elrepo-kernel     38 M
 kernel-ml-modules    x86_64    6.4.1-1.el8.elrepo       elrepo-kernel     34 M

Transaction Summary
================================================================================
Install  3 Packages

Total download size: 71 M
Installed size: 112 M
Downloading Packages:
(1/3): kernel-ml-6.4.1-1.el8.elrepo.x86_64.rpm  128 kB/s | 112 kB     00:00    
(2/3): kernel-ml-modules-6.4.1-1.el8.elrepo.x86 2.6 MB/s |  34 MB     00:12    
(3/3): kernel-ml-core-6.4.1-1.el8.elrepo.x86_64 2.8 MB/s |  38 MB     00:13    
--------------------------------------------------------------------------------
Total                                           5.0 MB/s |  71 MB     00:14     
ELRepo.org Community Enterprise Linux Kernel Re 1.6 MB/s | 1.7 kB     00:00    
Importing GPG key 0xBAADAE52:
 Userid     : "elrepo.org (RPM Signing Key for elrepo.org) <secure@elrepo.org>"
 Fingerprint: 96C0 104F 6315 4731 1E0B B1AE 309B C305 BAAD AE52
 From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-elrepo.org
Key imported successfully
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                        1/1 
  Installing       : kernel-ml-core-6.4.1-1.el8.elrepo.x86_64               1/3 
  Running scriptlet: kernel-ml-core-6.4.1-1.el8.elrepo.x86_64               1/3 
  Installing       : kernel-ml-modules-6.4.1-1.el8.elrepo.x86_64            2/3 
  Running scriptlet: kernel-ml-modules-6.4.1-1.el8.elrepo.x86_64            2/3 
  Installing       : kernel-ml-6.4.1-1.el8.elrepo.x86_64                    3/3 
  Running scriptlet: kernel-ml-core-6.4.1-1.el8.elrepo.x86_64               3/3 
  Running scriptlet: kernel-ml-6.4.1-1.el8.elrepo.x86_64                    3/3 
  Verifying        : kernel-ml-6.4.1-1.el8.elrepo.x86_64                    1/3 
  Verifying        : kernel-ml-core-6.4.1-1.el8.elrepo.x86_64               2/3 
  Verifying        : kernel-ml-modules-6.4.1-1.el8.elrepo.x86_64            3/3 

Installed:
  kernel-ml-6.4.1-1.el8.elrepo.x86_64                                           
  kernel-ml-core-6.4.1-1.el8.elrepo.x86_64                                      
  kernel-ml-modules-6.4.1-1.el8.elrepo.x86_64                                   

Complete!
[vagrant@kernel-update ~]$ sudo reboot
Connection to 127.0.0.1 closed by remote host.
vkan@l04-ubuntu:~/Documents/hw_1$ uname -r
5.19.0-46-generic
vkan@l04-ubuntu:~/Documents/hw_1$ vagrant ssh
Last login: Wed Jul  5 14:19:46 2023 from 10.0.2.2
[vagrant@kernel-update ~]$ uname -r
6.4.1-1.el8.elrepo.x86_64
[vagrant@kernel-update ~]$ sudo grub2-mkconfig -o /boot/grub2/grub.cfg
Generating grub configuration file ...
done
[vagrant@kernel-update ~]$ sudo grub2-set-default 0
[vagrant@kernel-update ~]$ sudo rebbot
sudo: rebbot: command not found
[vagrant@kernel-update ~]$ sudo reboot
Connection to 127.0.0.1 closed by remote host.
vkan@l04-ubuntu:~/Documents/hw_1$ vagrant ssh
Last login: Wed Jul  5 14:24:52 2023 from 10.0.2.2
[vagrant@kernel-update ~]$ uname -r
6.4.1-1.el8.elrepo.x86_64

***************************************************************************
2) Создать Vagrant box c помощью Packer
***************************************************************************
Создал json-файл:
{"builders": [
    {
      "boot_command": [
        "<tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg<enter><wait>"
      ],
      "boot_wait": "10s",
      "disk_size": "10240",
      "export_opts": [
        "--manifest",
        "--vsys",
        "0",
        "--description",
        "{{user `artifact_description`}}",
        "--version",
        "{{user `artifact_version`}}"
      ],
      "guest_os_type": "RedHat_64",
      "http_directory": "http",
      "iso_checksum": "7d239247ed42e4ddb4d3175070f85818e282c089e7df76b57d0686c551407c7a",
      "iso_url": "http://mirror.yandex.ru/centos/8-stream/isos/x86_64/CentOS-Stream-8-20230704.1-x86_64-boot.iso",
      "name": "{{user `image_name`}}",
      "output_directory": "builds",
      "shutdown_command": "sudo -S /sbin/halt -h -p",
      "shutdown_timeout": "5m",
      "ssh_password": "vagrant",
      "ssh_port": 22,
      "ssh_pty": true,
      "ssh_timeout": "40m",
      "ssh_username": "vagrant",
      "type": "virtualbox-iso",
      "vboxmanage": [
        [
          "modifyvm",
          "{{.Name}}",
          "--memory",
          "1024"
        ],
        [
          "modifyvm",
          "{{.Name}}",
          "--cpus",
          "2"
        ]
      ],
      "vm_name": "packer-centos-vm"
    }
  ],
  "post-processors": [
    {
      "compression_level": "7",
      "output": "centos-{{user `artifact_version`}}-kernel-5-x86_64-Minimal.box",
      "type": "vagrant"
    }
  ],
  "provisioners": [
    {
      "execute_command": "{{.Vars}} sudo -S -E bash '{{.Path}}'",
      "expect_disconnect": true,
      "override": {
        "{{user `image_name`}}": {
          "scripts": [
            "scripts/stage-1-kernel-update.sh",
            "scripts/stage-2-clean.sh"
          ]
        }
      },
      "pause_before": "10s",
      "start_retry_timeout": "1m",
      "type": "shell"
    }
  ],
  "variables": {
    "artifact_description": "CentOS Stream 8 with kernel 5.x",
    "artifact_version": "8",
    "image_name": "centos-8"
  }
}

-----------------------------------------
Создал ks.cfg
reboot --eject
eula --agreed
lang en_US.UTF-8
keyboard us
timezone UTC+3
network --bootproto=dhcp --device=link --activate
network --hostname=otus-c8
rootpw vagrant
authconfig --enableshadow --passalgo=sha512
user --groups=wheel --name=vagrant --password=vagrant --gecos="vagrant"
selinux --enforcing
firewall --disabled
firstboot --disable
text
url --url="http://mirror.centos.org/centos/8-stream/BaseOS/x86_64/os/"
bootloader --location=mbr --append="ipv6.disable=1 crashkernel=auto"
skipx
logging --level=info
zerombr
clearpart --all --initlabel
autopart --type=lvm
%post
#yum install -y policycoreutils-python
echo "# Allow vagrant to run any commands anywhere" >> /etc/sudoers
echo "vagrant   ALL=(ALL)   NOPASSWD: ALL" >> /etc/sudoers
echo "vagrant ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/vagrant
# Change ssh port
#/usr/bin/sed -i "s%#Port 22%Port 43389%g" "/etc/ssh/sshd_config"
#/usr/bin/sed -i "s%#PermitRootLogin yes%PermitRootLogin no%g" "/etc/ssh/sshd_config"
#/sbin/semanage port -a -t ssh_port_t -p tcp 22822
#/usr/bin/firewall-cmd --permanent --zone=public --remove-service=ssh
%end

------------------------------------------------------
Создал два скрипта "scripts/stage-1-kernel-update.sh", "scripts/stage-2-clean.sh".

scripts/stage-1-kernel-update.sh:

#!/bin/bash

# Установка репозитория elrepo
sudo yum install -y https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm
# Установка нового ядра из репозитория elrepo-kernel
yum --enablerepo elrepo-kernel install kernel-ml -y

# Обновление параметров GRUB
grub2-mkconfig -o /boot/grub2/grub.cfg
grub2-set-default 0
echo "Grub update done."
# Перезагрузка ВМ
shutdown -r now

scripts/stage-2-clean.sh:

#!/bin/bash

# Обновление и очистка всех ненужных пакетов
yum update -y
yum clean all


# Добавление ssh-ключа для пользователя vagrant
mkdir -pm 700 /home/vagrant/.ssh
curl -sL https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub -o /home/vagrant/.ssh/authorized_keys
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh


# Удаление временных файлов
rm -rf /tmp/*
rm  -f /var/log/wtmp /var/log/btmp
rm -rf /var/cache/* /usr/share/doc/*
rm -rf /var/cache/yum
rm -rf /vagrant/home/*.iso
rm  -f ~/.bash_history
history -c

rm -rf /run/log/journal/*
sync
grub2-set-default 0
echo "###   Hi from second stage" >> /boot/grub2/grub.cfg

----------------------------------------------------------------------
Ниже копия команд и действий по созданию образа:

vkan@l04-ubuntu:~/Documents/hw_1/packer$ packer build centos.json
virtualbox-iso.centos-8: output will be in this color.

==> virtualbox-iso.centos-8: Retrieving Guest additions
==> virtualbox-iso.centos-8: Trying /usr/share/virtualbox/VBoxGuestAdditions.iso
==> virtualbox-iso.centos-8: Trying /usr/share/virtualbox/VBoxGuestAdditions.iso
==> virtualbox-iso.centos-8: /usr/share/virtualbox/VBoxGuestAdditions.iso => /usr/share/virtualbox/VBoxGuestAdditions.iso
==> virtualbox-iso.centos-8: Retrieving ISO
==> virtualbox-iso.centos-8: Trying http://mirror.yandex.ru/centos/8-stream/isos/x86_64/CentOS-Stream-8-20230704.1-x86_64-boot.iso
==> virtualbox-iso.centos-8: Trying http://mirror.yandex.ru/centos/8-stream/isos/x86_64/CentOS-Stream-8-20230704.1-x86_64-boot.iso?checksum=sha256%3A7d239247ed42e4ddb4d3175070f85818e282c089e7df76b57d0686c551407c7a
==> virtualbox-iso.centos-8: http://mirror.yandex.ru/centos/8-stream/isos/x86_64/CentOS-Stream-8-20230704.1-x86_64-boot.iso?checksum=sha256%3A7d239247ed42e4ddb4d3175070f85818e282c089e7df76b57d0686c551407c7a => /home/vkan/.cache/packer/18687c5458bc53c8a9f103ba709b94f85530fcbc.iso
==> virtualbox-iso.centos-8: Starting HTTP server on port 8068
==> virtualbox-iso.centos-8: Creating virtual machine...
==> virtualbox-iso.centos-8: Creating hard drive builds/packer-centos-vm.vdi with size 10240 MiB...
==> virtualbox-iso.centos-8: Mounting ISOs...
    virtualbox-iso.centos-8: Mounting boot ISO...
==> virtualbox-iso.centos-8: Creating forwarded port mapping for communicator (SSH, WinRM, etc) (host port 3686)
==> virtualbox-iso.centos-8: Executing custom VBoxManage commands...
    virtualbox-iso.centos-8: Executing: modifyvm packer-centos-vm --memory 1024
    virtualbox-iso.centos-8: Executing: modifyvm packer-centos-vm --cpus 2
==> virtualbox-iso.centos-8: Starting the virtual machine...
==> virtualbox-iso.centos-8: Waiting 10s for boot...
==> virtualbox-iso.centos-8: Typing the boot command...
==> virtualbox-iso.centos-8: Using SSH communicator to connect: 127.0.0.1
==> virtualbox-iso.centos-8: Waiting for SSH to become available...
==> virtualbox-iso.centos-8: Connected to SSH!
==> virtualbox-iso.centos-8: Uploading VirtualBox version info (6.1.44)
==> virtualbox-iso.centos-8: Uploading VirtualBox guest additions ISO...
==> virtualbox-iso.centos-8: Pausing 10s before the next provisioner...
==> virtualbox-iso.centos-8: Provisioning with shell script: scripts/stage-1-kernel-update.sh
    virtualbox-iso.centos-8: CentOS Stream 8 - AppStream                     2.9 MB/s |  31 MB     00:10
    virtualbox-iso.centos-8: CentOS Stream 8 - BaseOS                        1.9 MB/s |  41 MB     00:21
    virtualbox-iso.centos-8: CentOS Stream 8 - Extras                        9.6 kB/s |  18 kB     00:01
    virtualbox-iso.centos-8: CentOS Stream 8 - Extras common packages        5.3 kB/s | 6.6 kB     00:01
    virtualbox-iso.centos-8: elrepo-release-8.el8.elrepo.noarch.rpm          6.9 kB/s |  13 kB     00:01
    virtualbox-iso.centos-8: Dependencies resolved.
    virtualbox-iso.centos-8: ================================================================================
    virtualbox-iso.centos-8:  Package             Arch        Version                Repository         Size
    virtualbox-iso.centos-8: ================================================================================
    virtualbox-iso.centos-8: Installing:
    virtualbox-iso.centos-8:  elrepo-release      noarch      8.3-1.el8.elrepo       @commandline       13 k
    virtualbox-iso.centos-8:
    virtualbox-iso.centos-8: Transaction Summary
    virtualbox-iso.centos-8: ================================================================================
    virtualbox-iso.centos-8: Install  1 Package
    virtualbox-iso.centos-8:
    virtualbox-iso.centos-8: Total size: 13 k
    virtualbox-iso.centos-8: Installed size: 5.0 k
    virtualbox-iso.centos-8: Downloading Packages:
    virtualbox-iso.centos-8: Running transaction check
    virtualbox-iso.centos-8: Transaction check succeeded.
    virtualbox-iso.centos-8: Running transaction test
    virtualbox-iso.centos-8: Transaction test succeeded.
    virtualbox-iso.centos-8: Running transaction
    virtualbox-iso.centos-8:   Preparing        :                                                        1/1
    virtualbox-iso.centos-8:   Installing       : elrepo-release-8.3-1.el8.elrepo.noarch                 1/1
    virtualbox-iso.centos-8:   Verifying        : elrepo-release-8.3-1.el8.elrepo.noarch                 1/1
    virtualbox-iso.centos-8:
    virtualbox-iso.centos-8: Installed:
    virtualbox-iso.centos-8:   elrepo-release-8.3-1.el8.elrepo.noarch
    virtualbox-iso.centos-8:
    virtualbox-iso.centos-8: Complete!
    virtualbox-iso.centos-8: ELRepo.org Community Enterprise Linux Repositor 119 kB/s | 276 kB     00:02
    virtualbox-iso.centos-8: ELRepo.org Community Enterprise Linux Kernel Re 1.0 MB/s | 2.7 MB     00:02
    virtualbox-iso.centos-8: Dependencies resolved.
    virtualbox-iso.centos-8: ================================================================================
    virtualbox-iso.centos-8:  Package              Arch      Version                  Repository        Size
    virtualbox-iso.centos-8: ================================================================================
    virtualbox-iso.centos-8: Installing:
    virtualbox-iso.centos-8:  kernel-ml            x86_64    6.4.2-1.el8.elrepo       elrepo-kernel    112 k
    virtualbox-iso.centos-8: Installing dependencies:
    virtualbox-iso.centos-8:  kernel-ml-core       x86_64    6.4.2-1.el8.elrepo       elrepo-kernel     38 M
    virtualbox-iso.centos-8:  kernel-ml-modules    x86_64    6.4.2-1.el8.elrepo       elrepo-kernel     34 M
    virtualbox-iso.centos-8:
    virtualbox-iso.centos-8: Transaction Summary
    virtualbox-iso.centos-8: ================================================================================
    virtualbox-iso.centos-8: Install  3 Packages
    virtualbox-iso.centos-8:
    virtualbox-iso.centos-8: Total download size: 71 M
    virtualbox-iso.centos-8: Installed size: 112 M
    virtualbox-iso.centos-8: Downloading Packages:
    virtualbox-iso.centos-8: (1/3): kernel-ml-6.4.2-1.el8.elrepo.x86_64.rpm  130 kB/s | 112 kB     00:00
    virtualbox-iso.centos-8: (2/3): kernel-ml-modules-6.4.2-1.el8.elrepo.x86 1.4 MB/s |  34 MB     00:24
    virtualbox-iso.centos-8: (3/3): kernel-ml-core-6.4.2-1.el8.elrepo.x86_64 1.3 MB/s |  38 MB     00:28
    virtualbox-iso.centos-8: --------------------------------------------------------------------------------
    virtualbox-iso.centos-8: Total                                           2.5 MB/s |  71 MB     00:28
    virtualbox-iso.centos-8: ELRepo.org Community Enterprise Linux Kernel Re 1.6 MB/s | 1.7 kB     00:00
    virtualbox-iso.centos-8: Importing GPG key 0xBAADAE52:
    virtualbox-iso.centos-8:  Userid     : "elrepo.org (RPM Signing Key for elrepo.org) <secure@elrepo.org>"
    virtualbox-iso.centos-8:  Fingerprint: 96C0 104F 6315 4731 1E0B B1AE 309B C305 BAAD AE52
    virtualbox-iso.centos-8:  From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-elrepo.org
    virtualbox-iso.centos-8: Key imported successfully
    virtualbox-iso.centos-8: Running transaction check
    virtualbox-iso.centos-8: Transaction check succeeded.
    virtualbox-iso.centos-8: Running transaction test
    virtualbox-iso.centos-8: Transaction test succeeded.
    virtualbox-iso.centos-8: Running transaction
    virtualbox-iso.centos-8:   Preparing        :                                                        1/1
    virtualbox-iso.centos-8:   Installing       : kernel-ml-core-6.4.2-1.el8.elrepo.x86_64               1/3
    virtualbox-iso.centos-8:   Running scriptlet: kernel-ml-core-6.4.2-1.el8.elrepo.x86_64               1/3
    virtualbox-iso.centos-8: /usr/sbin/ldconfig: /usr/lib64/llvm15/lib/libclang.so.15 is not a symbolic link
    virtualbox-iso.centos-8:
    virtualbox-iso.centos-8:
    virtualbox-iso.centos-8:   Installing       : kernel-ml-modules-6.4.2-1.el8.elrepo.x86_64            2/3
    virtualbox-iso.centos-8:   Running scriptlet: kernel-ml-modules-6.4.2-1.el8.elrepo.x86_64            2/3
    virtualbox-iso.centos-8:   Installing       : kernel-ml-6.4.2-1.el8.elrepo.x86_64                    3/3
    virtualbox-iso.centos-8:   Running scriptlet: kernel-ml-core-6.4.2-1.el8.elrepo.x86_64               3/3
    virtualbox-iso.centos-8:   Running scriptlet: kernel-ml-6.4.2-1.el8.elrepo.x86_64                    3/3
    virtualbox-iso.centos-8: /sbin/ldconfig: /usr/lib64/llvm15/lib/libclang.so.15 is not a symbolic link
    virtualbox-iso.centos-8:
    virtualbox-iso.centos-8:
    virtualbox-iso.centos-8:   Verifying        : kernel-ml-6.4.2-1.el8.elrepo.x86_64                    1/3
    virtualbox-iso.centos-8:   Verifying        : kernel-ml-core-6.4.2-1.el8.elrepo.x86_64               2/3
    virtualbox-iso.centos-8:   Verifying        : kernel-ml-modules-6.4.2-1.el8.elrepo.x86_64            3/3
    virtualbox-iso.centos-8:
    virtualbox-iso.centos-8: Installed:
    virtualbox-iso.centos-8:   kernel-ml-6.4.2-1.el8.elrepo.x86_64
    virtualbox-iso.centos-8:   kernel-ml-core-6.4.2-1.el8.elrepo.x86_64
    virtualbox-iso.centos-8:   kernel-ml-modules-6.4.2-1.el8.elrepo.x86_64
    virtualbox-iso.centos-8:
    virtualbox-iso.centos-8: Complete!
    virtualbox-iso.centos-8: Generating grub configuration file ...
    virtualbox-iso.centos-8: done
    virtualbox-iso.centos-8: Grub update done.
==> virtualbox-iso.centos-8: Provisioning with shell script: scripts/stage-2-clean.sh
    virtualbox-iso.centos-8: Last metadata expiration check: 0:01:52 ago on Thu 06 Jul 2023 11:45:21 PM EDT.
    virtualbox-iso.centos-8: Dependencies resolved.
    virtualbox-iso.centos-8: Nothing to do.
    virtualbox-iso.centos-8: Complete!
    virtualbox-iso.centos-8: 39 files removed
==> virtualbox-iso.centos-8: Gracefully halting virtual machine...
==> virtualbox-iso.centos-8: Preparing to export machine...
    virtualbox-iso.centos-8: Deleting forwarded port mapping for the communicator (SSH, WinRM, etc) (host port 3686)
==> virtualbox-iso.centos-8: Exporting virtual machine...
    virtualbox-iso.centos-8: Executing: export packer-centos-vm --output builds/packer-centos-vm.ovf --manifest --vsys 0 --description CentOS Stream 8 with kernel 5.x --version 8
==> virtualbox-iso.centos-8: Cleaning up floppy disk...
==> virtualbox-iso.centos-8: Deregistering and deleting VM...
==> virtualbox-iso.centos-8: Running post-processor: vagrant
==> virtualbox-iso.centos-8 (vagrant): Creating a dummy Vagrant box to ensure the host system can create one correctly
==> virtualbox-iso.centos-8 (vagrant): Creating Vagrant box for 'virtualbox' provider
    virtualbox-iso.centos-8 (vagrant): Copying from artifact: builds/packer-centos-vm-disk001.vmdk
    virtualbox-iso.centos-8 (vagrant): Copying from artifact: builds/packer-centos-vm.mf
    virtualbox-iso.centos-8 (vagrant): Copying from artifact: builds/packer-centos-vm.ovf
    virtualbox-iso.centos-8 (vagrant): Renaming the OVF to box.ovf...
    virtualbox-iso.centos-8 (vagrant): Compressing: Vagrantfile
    virtualbox-iso.centos-8 (vagrant): Compressing: box.ovf
    virtualbox-iso.centos-8 (vagrant): Compressing: metadata.json
    virtualbox-iso.centos-8 (vagrant): Compressing: packer-centos-vm-disk001.vmdk
    virtualbox-iso.centos-8 (vagrant): Compressing: packer-centos-vm.mf
Build 'virtualbox-iso.centos-8' finished after 39 minutes 22 seconds.

==> Wait completed after 39 minutes 22 seconds

==> Builds finished. The artifacts of successful builds are:
--> virtualbox-iso.centos-8: 'virtualbox' provider box: centos-8-kernel-5-x86_64-Minimal.box

**************************************************************************************
3) Загрузить Vagrant box в Vagrant Cloud
**************************************************************************************
Зашел в vagrant cloud: vagrant cloud auth login
Опубликовал образ: 
vagrant cloud publish --release samo82/centos8-kernel6 1.0 virtualbox centos-8-kernel-5-x86_64-Minimal.box
