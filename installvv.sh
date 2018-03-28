#!/bin/bash
#
#	Installiert die benoetigte Software fuer eine VirtualBox/Vagrant Umgebung
#

sudo apt-get update && sudo apt-get -y dist-upgrade && sudo apt-get -y autoremove
sudo apt-get -y install gcc make linux-headers-$(uname -r) dkms

# VirtualBox
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
sudo sh -c 'echo "deb http://download.virtualbox.org/virtualbox/debian $(lsb_release -sc) contrib" >> /etc/apt/sources.list'
sudo apt-get update
sudo apt-get install -y virtualbox-5.2 git unzip zip dos2unix curl wget
curl -O http://download.virtualbox.org/virtualbox/5.2.4/Oracle_VM_VirtualBox_Extension_Pack-5.2.4-119785.vbox-extpack
sudo VBoxManage extpack install Oracle_VM_VirtualBox_Extension_Pack-5.2.4-119785.vbox-extpack

# Vagrant
wget https://releases.hashicorp.com/vagrant/2.0.3/vagrant_2.0.3_x86_64.deb?_ga=2.21104755.952897466.1521814486-1390085671.1521814486
mv vagrant_2.0.3_x86_64.deb\?_ga\=2.21104755.952897466.1521814486-1390085671.1521814486  vagrant_2.0.3_x86_64.deb
sudo dpkg -i -y vagrant_2.0.3_x86_64.deb
vagrant plugin install vagrant-disksize


