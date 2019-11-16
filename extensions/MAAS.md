MAAS
====

## Installation Software

### KVM

    sudo add-apt-repository ppa:maas/stable -y  
    sudo apt update
    sudo apt upgrade -y
    sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils
    
### Netzwerkbridge erstellen

Datei `/etc/netplan/01-netcnf.yaml` editieren, bzw. ergänzen:

    network:
      version: 2
      renderer: NetworkManager
      ethernets:
      
        enp42s0:
          gateway4: 192.168.1.1
          dhcp4: false
          # Specify static address, and netmask.
          addresses: [192.168.1.10/24, '2001:1::10/64']
      bridges:
        br0:
          dhcp4: false
          interfaces: [enp42s0] 
          
---

# This file describes the network interfaces available on your system
# For more information, see netplan(5).
network:
  version: 2
  renderer: networkd
  ethernets:
    enp5s0:
      dhcp4: false
      dhcp6: false
  bridges:
    br0:
      dhcp4: false
      dhcp6: false
      interfaces: [enp5s0]
      addresses: [172.16.17.13/24]
      gateway4: 172.16.17.1
      nameservers:
       addresses: [10.62.98.8,10.62.99.8,8.8.8.8]
           
        
Aktiveren
          
    sudo netplan --debug apply   
    
### virsh Netzwerk entfernen/erweitern, weil von maas bedient

nur Bridge ergänzen

    cat <<%EOF% >br0.xml
    <network>
      <name>br0</name>
      <forward mode='bridge'/>
      <bridge name='br0'/>
    </network>
    %EOF%

    virsh net-define br0.xml
    virsh net-start br0
    virsh net-autostart br0

Default Netzwerk entfernen und neu bauen

    sudo virsh net-list
    sudo virsh net-destroy default
    sudo virsh net-undefine default

    cat <<%EOF% >net.xml
        <network>
          <name>default</name>
          <uuid>9a05da11-e96b-47f3-8253-a3a482e445f5</uuid>
          <forward mode='nat'/>
          <bridge name='virbr0' stp='on' delay='0'/>
          <mac address='52:54:00:0a:cd:21'/>
          <ip address='192.168.122.1' netmask='255.255.255.0'>
          </ip>
        </network>
    %EOF%

    sudo virsh net-define net.xml
    sudo virsh net-autostart default  
    sudo virsh net-start default

### Disk Pool einrichten

sudo virsh pool-define-as default dir - - - - "/var/lib/libvirt/images"  
sudo virsh pool-autostart default  
sudo virsh pool-start default              

### Testen

    virt-install --name=test1-vm \
    --vcpus=1 \
    --memory=1024 \
    --cdrom=$HOME/cdrom/debian-9.9.0-amd64-netinst.iso \
    --disk size=5 \
    --os-variant=debian8  --graphic vnc

### MAAS

    sudo apt install -y maas
    sudo maas init --admin-username ubuntu --admin-password password --admin-email marcel.bernet@tbz.ch

User maas aufbereiten und Zugriff auf ubuntu geben (als user ubuntu)

    sudo chsh -s /bin/bash maas  
    sudo su - maas  
    ssh-keygen -f ~/.ssh/id\_rsa -N ''  
    logout  
    sudo cat ~maas/.ssh/id\_rsa.pub | tee -a ~/.ssh/authorized_keys

Testen

    sudo -H -u maas bash -c 'virsh -c qemu+ssh://ubuntu@localhost/system list --all'

UI von MAAS aufrufen [ip:5240](http://localhost:5240)

* SSH-Key z.B. `id_remote.pub` manuell eintragen
* DNS Server eintragen 
* Images syncen
* Bei Subnets DHCP Server aktivieren auf 192.168.122.x 
* Aktuelle Maschine als Pod eintragen
* Pod -> Compose VM

DHCP Testen

    sudo nmap --script broadcast-dhcp-discover -e virbr0

## Links

* [Bridge KVM](https://askubuntu.com/questions/1054350/netplan-bridge-for-kvm-on-ubuntu-server-18-04-with-static-ips)
* [Static IP Ubuntu 18](https://linuxconfig.org/how-to-configure-static-ip-address-on-ubuntu-18-04-bionic-beaver-linux)
* [broadcast-dhcp-discover](https://nmap.org/nsedoc/scripts/broadcast-dhcp-discover.html)
* [Setup Default Network](http://blog.programster.org/kvm-missing-default-network)


    
     
