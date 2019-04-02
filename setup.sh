#!/bin/bash
#
# This stuff sets up the server with vagrant and libvirt, etc.
apt-get update -y
apt-get install -qy libvirt-bin libvirt-dev qemu-utils qemu git
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
echo "/dev/nvme0n1p1  /mnt/nvme ext4  defaults  0 0" >> /etc/fstab
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
# crank up the swapfile size
fallocate -l 4G /mnt/nvme/swapfile
chmod 600 /mnt/nvme/swapfile
mkswap /mnt/nvme/swapfile
swapon /mnt/nvme/swapfile
echo "/mnt/nvme/swapfile  none  swap  sw  0 0" >>/etc/fstab
swapoff /dev/sda2
#
# copy repos and softlink them
git clone https://github.com/CumulusNetworks/cldemo-vagrant-netq2ea.git /mnt/nvme/1_cldemo-vagrant-netq2ea
git clone https://github.com/CumulusNetworks/cldemo-vagrant-netq2ea.git /mnt/nvme/2_cldemo-vagrant-netq2ea
git clone https://github.com/CumulusNetworks/cldemo-vagrant-netq2ea.git /mnt/nvme/3_cldemo-vagrant-netq2ea
git clone https://github.com/CumulusNetworks/cldemo-vagrant-netq2ea.git /mnt/nvme/4_cldemo-vagrant-netq2ea
git clone https://github.com/CumulusNetworks/cldemo-vagrant-netq2ea.git /mnt/nvme/5_cldemo-vagrant-netq2ea
git clone https://github.com/CumulusNetworks/cldemo-vagrant-netq2ea.git /mnt/nvme/6_cldemo-vagrant-netq2ea
ln -s /mnt/nvme/6_cldemo-vagrant-netq2ea /root/6_cldemo-vagrant-netq2ea
ln -s /mnt/nvme/6_cldemo-vagrant-netq2ea /root/5_cldemo-vagrant-netq2ea
ln -s /mnt/nvme/6_cldemo-vagrant-netq2ea /root/4_cldemo-vagrant-netq2ea
ln -s /mnt/nvme/6_cldemo-vagrant-netq2ea /root/3_cldemo-vagrant-netq2ea
ln -s /mnt/nvme/6_cldemo-vagrant-netq2ea /root/2_cldemo-vagrant-netq2ea
ln -s /mnt/nvme/6_cldemo-vagrant-netq2ea /root/1_cldemo-vagrant-netq2ea
#
# Also add a copy for ssh keys?
