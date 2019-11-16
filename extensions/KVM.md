KVM
===

Installation (im Zusammenspiel mit MAAS)
----------------------------------------

    sudo add-apt-repository ppa:maas/stable -y  
    sudo apt update
    sudo apt upgrade -y
    sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils

Vagrant Erweiterungen
---------------------

    sudo apt-get build-dep vagrant ruby-libvirt
    sudo apt-get install -y qemu libvirt-daemon-system libvirt-clients ebtables dnsmasq-base
    sudo apt-get install -y libxslt-dev libxml2-dev libvirt-dev zlib1g-dev ruby-dev
    vagrant plugin install vagrant-libvirt
    
Box starten

    mkdir ubuntu18
    cd ubuntu18
    vagrant init generic/ubuntu1804
    vagrant up --provider=libvirt    
    
Boxen konvertieren
------------------

    vagrant plugin install vagrant-mutate
    vagrant box add ubuntu/xenial64
    vagrant mutate ubuntu/xenial64 libvirt
    
    vagrant init ubuntu/xenial64
    vagrant up --provider=libvirt     
   
    
### Links

* [Setup Headless Virtualization Server Using KVM In Ubuntu 18.04 LTS](https://www.ostechnix.com/setup-headless-virtualization-server-using-kvm-ubuntu/)
* [Setup Default Network](http://blog.programster.org/kvm-missing-default-network)
* [KVM + Vagrant](https://github.com/vagrant-libvirt/vagrant-libvirt)
* [Vagrant libvirt Boxen](https://app.vagrantup.com/boxes/search?provider=libvirt)
* [Boxen konvertieren](https://github.com/sciurus/vagrant-mutate)    
    