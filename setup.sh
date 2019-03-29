#!/bin/bash

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
# add the work here for name storage mount and use by qemu/libvirt
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
mkdir .vagrant_boxes
export VAGRANT_HOME=/mnt/nvme/.vagrant_boxes
vagrant plugin install vagrant-libvirt

