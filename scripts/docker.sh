#!/bin/bash
#
# 	Installiert Docker bzw. Feintuning

set -o xtrace

#sudo apt-get install -y libltdl7
#wget https://download.docker.com/linux/ubuntu/dists/xenial/pool/stable/amd64/docker-ce_18.06.1~ce~3-0~ubuntu_amd64.deb >/dev/null 2>&1
#sudo dpkg -i docker-ce_18.06.1~ce~3-0~ubuntu_amd64.deb
#sudo usermod -aG docker vagrant 

sudo apt update
sudo apt install -y docker.io
sudo usermod -aG docker vagrant 
    
# Abhandlung Container Cache

if  [ -d /vagrant/cr-cache/ ]
then
    for image in /vagrant/cr-cache/*.tar
    do
        sudo docker load -i ${image}
    done
fi

sudo docker image ls