#!/bin/bash
#
# 	Installiert Docker bzw. Feintuning

    set -o xtrace

    sudo apt-get install -y libltdl7
	wget https://download.docker.com/linux/ubuntu/dists/xenial/pool/stable/amd64/docker-ce_18.03.0~ce-0~ubuntu_amd64.deb
    sudo dpkg -i docker-ce_18.03.0~ce-0~ubuntu_amd64.deb
