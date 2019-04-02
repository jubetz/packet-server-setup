#!/bin/bash
#
echo "HEY START THE SCP IMAGE COPY NOW CAUSE ITS LIKE 6GB"
sleep 3
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
sleep 5
mkfs.ext4 /dev/nvme0n1p1
mkdir /mnt/nvme
mount /dev/nvme0n1p1 /mnt/nvme -t ext4
echo "/dev/nvme0n1p1  /mnt/nvme ext4  defaults  0 0" >> /etc/fstab
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
# TODO: remove /dev/sda2 entry from fstab else it comes back at reboot
#
# copy repos and softlink them. repo is private right now (ssh keys?) so it asks for user/pass
# so do it once manually then copy it
mkdir /mnt/nvme/1_cldemo-vagrant-netq2ea
mkdir /mnt/nvme/2_cldemo-vagrant-netq2ea
mkdir /mnt/nvme/3_cldemo-vagrant-netq2ea
mkdir /mnt/nvme/4_cldemo-vagrant-netq2ea
mkdir /mnt/nvme/5_cldemo-vagrant-netq2ea
mkdir /mnt/nvme/6_cldemo-vagrant-netq2ea
git clone https://github.com/CumulusNetworks/cldemo-vagrant-netq2ea.git /mnt/nvme/1_cldemo-vagrant-netq2ea
#git clone https://github.com/CumulusNetworks/cldemo-vagrant-netq2ea.git /mnt/nvme/2_cldemo-vagrant-netq2ea
#git clone https://github.com/CumulusNetworks/cldemo-vagrant-netq2ea.git /mnt/nvme/3_cldemo-vagrant-netq2ea
#git clone https://github.com/CumulusNetworks/cldemo-vagrant-netq2ea.git /mnt/nvme/4_cldemo-vagrant-netq2ea
#git clone https://github.com/CumulusNetworks/cldemo-vagrant-netq2ea.git /mnt/nvme/5_cldemo-vagrant-netq2ea
#git clone https://github.com/CumulusNetworks/cldemo-vagrant-netq2ea.git /mnt/nvme/6_cldemo-vagrant-netq2ea
cp -R /mnt/nvme/1_cldemo-vagrant-netq2ea/* /mnt/nvme/2_cldemo-vagrant-netq2ea/
cp -R /mnt/nvme/1_cldemo-vagrant-netq2ea/* /mnt/nvme/3_cldemo-vagrant-netq2ea/
cp -R /mnt/nvme/1_cldemo-vagrant-netq2ea/* /mnt/nvme/4_cldemo-vagrant-netq2ea/
cp -R /mnt/nvme/1_cldemo-vagrant-netq2ea/* /mnt/nvme/5_cldemo-vagrant-netq2ea/
cp -R /mnt/nvme/1_cldemo-vagrant-netq2ea/* /mnt/nvme/6_cldemo-vagrant-netq2ea/
ln -s /mnt/nvme/6_cldemo-vagrant-netq2ea /root/6_cldemo-vagrant-netq2ea
ln -s /mnt/nvme/5_cldemo-vagrant-netq2ea /root/5_cldemo-vagrant-netq2ea
ln -s /mnt/nvme/4_cldemo-vagrant-netq2ea /root/4_cldemo-vagrant-netq2ea
ln -s /mnt/nvme/3_cldemo-vagrant-netq2ea /root/3_cldemo-vagrant-netq2ea
ln -s /mnt/nvme/2_cldemo-vagrant-netq2ea /root/2_cldemo-vagrant-netq2ea
ln -s /mnt/nvme/1_cldemo-vagrant-netq2ea /root/1_cldemo-vagrant-netq2ea
#
# update the wbid so the pods don't step on each other
sed -i -e 's/wbid = 1/wbid = 2/' /mnt/nvme/2_cldemo-vagrant-netq2ea/Vagrantfile
sed -i -e 's/wbid = 1/wbid = 3/' /mnt/nvme/3_cldemo-vagrant-netq2ea/Vagrantfile
sed -i -e 's/wbid = 1/wbid = 4/' /mnt/nvme/4_cldemo-vagrant-netq2ea/Vagrantfile
sed -i -e 's/wbid = 1/wbid = 5/' /mnt/nvme/5_cldemo-vagrant-netq2ea/Vagrantfile
sed -i -e 's/wbid = 1/wbid = 6/' /mnt/nvme/6_cldemo-vagrant-netq2ea/Vagrantfile
# 
# copy ssh keys
cp /mnt/nvme/1_cldemo-vagrant-netq2ea/authorized_keys /root/.ssh/authorized_keys
#
# TODO
# vagrant box add once scp copy is done
