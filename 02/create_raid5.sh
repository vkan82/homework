#!/bin/bash
sudo mdadm --zero-superblock --force /dev/sd{b,c,d,e,f}
sudo mdadm --create --verbose /dev/md0 -l 5 -n 5 /dev/sd{b,c,d,e,f}
sudo mkdir /etc/mdadm
echo "DEVICE partitions" | sudo tee /etc/mdadm/mdadm.conf
sudo mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' | sudo tee -a /etc/mdadm/mdadm.conf
sudo parted -s /dev/md0 mklabel gpt
sudo parted /dev/md0 mkpart primary ext4 0% 20%
sudo parted /dev/md0 mkpart primary ext4 20% 40%
sudo parted /dev/md0 mkpart primary ext4 40% 60%
sudo parted /dev/md0 mkpart primary ext4 60% 80%
sudo parted /dev/md0 mkpart primary ext4 80% 100%
for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$i; done
sudo mkdir -p /raid/part{1,2,3,4,5}
for i in $(seq 1 5); do sudo mount /dev/md0p$i /raid/part$i; done
echo '/dev/md0p1 /raid/part1 ext4    defaults    1 2' | sudo tee -a /etc/fstab
echo '/dev/md0p2 /raid/part2 ext4    defaults    1 2' | sudo tee -a /etc/fstab
echo '/dev/md0p3 /raid/part3 ext4    defaults    1 2' | sudo tee -a /etc/fstab
echo '/dev/md0p4 /raid/part4 ext4    defaults    1 2' | sudo tee -a /etc/fstab
echo '/dev/md0p5 /raid/part5 ext4    defaults    1 2' | sudo tee -a /etc/fstab
cat /proc/mdstat
