#!/bin/bash
#
# nobody has tested this yet :)
# probably need to test this out if/when we have to rebuild the server, I'm sure there are mistakes here.
#
# This stuff sets up the server with vagrant and libvirt, etc.
apt-get update -y
apt-get install libvirt-bin libvirt-dev qemu-utils qemu
/etc/init.d/libvirt-bin restart
addgroup libvirtd
usermod -a -G libvirtd root
wget https://releases.hashicorp.com/vagrant/2.2.4/vagrant_2.2.4_x86_64.deb
dpkg -i https://releases.hashicorp.com/vagrant/2.2.4/vagrant_2.2.4_x86_64.deb
vagrant plugin install vagrant-libvirt
vagrant plugin install vagrant-mutate
#
# This is for nvme storage mount then use by qemu/libvirt
parted -a optimal /dev/nvme0n1 mklabel gpt
parted -a optimal /dev/nvme0n1 mkpart primary ext4 0% 100%
mkfs.ext4 /dev/nvme0n1p1
mount /dev/nvme0n1p1 /mnt/nvme -t ext4
virsh pool-destroy default
virsh pool-undefine default
mkdir /mnt/nvme/.libvirt
virsh pool-define-as --name default --type dir --target /mnt/nvme/.libvirt
virsh pool-autostart default
virsh pool-start default
mkdir /mnt/nvme/.vagrant_boxes
export VAGRANT_HOME=/mnt/nvme/.vagrant_boxes
vagrant plugin install vagrant-libvirt
#
#
# TODO:
# here we should probably clone the repo https://github.com/CumulusNetworks/cldemo-vagrant-netq2ea 6 times in /mnt/nvme/ (need to make repo public)
# then softlink to it from /root
# Also add a copy for ssh keys?
