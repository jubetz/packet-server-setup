#!/bin/bash
#
# This stuff sets up the server with vagrant and libvirt, etc.
apt-get update -y
apt-get install -qy libvirt-bin libvirt-dev qemu-utils qemu
/etc/init.d/libvirt-bin restart
addgroup libvirtd
usermod -a -G libvirtd root
wget https://releases.hashicorp.com/vagrant/2.2.4/vagrant_2.2.4_x86_64.deb
dpkg -i vagrant_2.2.4_x86_64.deb
#
#
# This is for nvme storage mount then use by qemu/libvirt
parted -a optimal /dev/nvme0n1 mklabel gpt
parted -a optimal /dev/nvme0n1 mkpart primary ext4 0% 100%
mkfs.ext4 /dev/nvme0n1p1
mkdir /mnt/nvme
mount /dev/nvme0n1p1 /mnt/nvme -t ext4
# on a fresh server, the next two commands return
# don't think we need them.
#
#root@roobios:~# virsh pool-destroy default
#error: failed to get pool 'default'
#error: Storage pool not found: no storage pool with matching name 'default'
#
#root@roobios:~# virsh pool-undefine default
#error: failed to get pool 'default'
#error: Storage pool not found: no storage pool with matching name 'default'
#
#virsh pool-destroy default
#virsh pool-undefine default
mkdir /mnt/nvme/.libvirt
virsh pool-define-as --name default --type dir --target /mnt/nvme/.libvirt
virsh pool-autostart default
virsh pool-start default
mkdir /mnt/nvme/.vagrant_boxes
export VAGRANT_HOME=/mnt/nvme/.vagrant_boxes
vagrant plugin install vagrant-libvirt
vagrant plugin install vagrant-mutate
#
#
# TODO:
# here we should probably clone the repo https://github.com/CumulusNetworks/cldemo-vagrant-netq2ea 6 times in /mnt/nvme/ (need to make repo public)
# then softlink to it from /root
# Also add a copy for ssh keys?
