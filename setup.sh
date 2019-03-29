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
