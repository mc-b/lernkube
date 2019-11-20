MAAS
====

[MAAS](https://maas.io/) steht für Self-Service-Remote-Installation von Windows, CentOS, ESXi und Ubuntu auf realen Servern. Es verwandelt das Rechenzentrum in eine Bare-Metal-Cloud.

In Zukunft soll das Shellscript [clusteradm](../clusteradm.md) durch die [MAAS](https://maas.io/) Lösung ersetzt bzw. ergänzt werden. Damit soll eine Umgebung mit mehreren `lernkube`-Clustern einfach erstellt, gewartet und überwacht werden.

Das ist u.a. wichtig wenn pro Modul oder Unterrichtsraum ein eigener Cluster zur Verfügung steht. 

Lehrbeauftragte und Dozenten sollen via Web Oberfläche, einfach `lernkube`-Cluster erstellen, warten und überwachen können.

**TODO**
* Installationsvariante MAAS statt vagrant, siehe Links.

***
## Installation Software - MAAS Server

Als [Anforderungen](https://maas.io/docs/maas-requirements) wird ein Server mit 4.5 GB memory, 4.5 GHz CPU, and 45 GB of disk space gewünscht.

Für Testumgebungen genügt die Hälfte.

### Netzwerkbridge erstellen

Zuerst muss ein zusätzliches Interface, die Bridge `br0`, erstellt werden.

Diese leitet den IP Verkehr von der VM weiter ins Internet, ausserdem benötigt der MAAS Server eine fixe IP.

Datei `/etc/netplan/01-netcnf.yaml` editieren, bzw. ergänzen:

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
    
### MAAS

    sudo add-apt-repository ppa:maas/stable -y  
    sudo apt update
    sudo apt upgrade -y
    sudo apt install -y maas jq
    sudo maas init --admin-username ubuntu --admin-password password --admin-email xx.yy@zz.ch

### UI von MAAS aufrufen [ip:5240](http://localhost:5240)

* SSH-Key z.B. `id_rsa.pub` manuell eintragen
* DNS Server eintragen. 
* Bei Subnets DHCP Server aktivieren auf 172.16.17.x, Gateway IP: 172.16.17.1 und DNS Server eintragen

**Server frisch starten, ansonsten werden die Änderungen nicht übernommen.**

* Images syncen

### Testen

DHCP Testen

    sudo nmap --script broadcast-dhcp-discover -e virbr0
    
Custom Box hinzufügen

    maas $profile boot-resources create name=custom/$imagedisplayname architecture=amd64/generic content=@$tgzfilepath    
    
### Customising Installationsscript

Datei `/etc/maas/preseeds/curtin_userdata_ubuntu` erstellen und folgendes eintragen:

    #cloud-config
    debconf_selections:
     maas: |
      {{for line in str(curtin_preseed).splitlines()}}
      {{line}}
      {{endfor}}
    #
    late_commands:
      maas: [wget, '--no-proxy', {{node_disable_pxe_url|escape.json}}, '--post-data', {{node_disable_pxe_data|escape.json}}, '-O', '/dev/null']
      10_git: ["curtin", "in-target", "--", "sh", "-c", "apt-get -y install git curl wget"]
      20_git: ["curtin", "in-target", "--", "sh", "-c", "git clone https://github.com/mc-b/lernkube /home/ubuntu/lernkube && chown -R 1000:1000 /home/ubuntu/lernkube"]
      30_git: ["curtin", "in-target", "--", "sh", "-x", "/home/ubuntu/lernkube/scripts/docker.sh"]

Beim Deployen von Ubuntu Images wird zusätzlich das Projekt `lernkube` geclont und Docker installiert. 
Die `maas` Befehle sind notwendig, dass die VM richtig beendet wird und sauber rebooted.
 
***
## Installation KVM Hosts 

Am einfachsten ist es die weiteren Maschinen via Netzwerk (PXE Boot) zu booten und automatisch installieren zu lassen.

Weitere geht es bei [MAAS CLI](#maas-cli)

### Manuelle Konfiguration KVM Host

Wird ein Server manuell mit Ubuntu 18.x installiert ist er wie folgt zu konfiguieren:

KVM installieren

    sudo add-apt-repository ppa:maas/stable -y  
    sudo apt update
    sudo apt upgrade -y
    sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils jq
 
User maas aufbereiten und Zugriff auf ubuntu geben (als user ubuntu)

    sudo chsh -s /bin/bash maas  
    sudo su - maas  
    ssh-keygen -f ~/.ssh/id\_rsa -N ''  
    logout  
    sudo cat ~maas/.ssh/id\_rsa.pub | tee -a ~/.ssh/authorized_keys

Testen

    sudo -H -u maas bash -c 'virsh -c qemu+ssh://ubuntu@localhost/system list --all'

### virsh Netzwerk entfernen/erweitern, weil von maas bedient

Da neu **MAAS** die Rolle des DHCP Server übernimmt, muss der DHCP Server von **virsh** abgeschaltet werden.

Das wird durch entfernen und neu erstellen des `default` Netzwerkes erreicht.
 
    sudo virsh net-list
    sudo virsh net-destroy default
    sudo virsh net-undefine default

    cat <<%EOF% >net.xml
        <network>
          <name>default</name>
          <uuid>9a05da11-e96b-47f3-8253-a3a482e445f5</uuid>
          <forward mode='nat'/>
          <bridge name='virbr0' stp='on' delay='0'/>
          <mac address='52:54:00:0a:cd:22'/>
          <ip address='192.168.122.1' netmask='255.255.255.0'>
          </ip>
        </network>
    %EOF%

    sudo virsh net-define net.xml
    sudo virsh net-autostart default  
    sudo virsh net-start default

Anschliessend wird eine Bridge `br0`, welche den Verkehr zum Interface `br0` weitereleitet erstellt.

    cat <<%EOF% >br0.xml
    <network>
      <name>br0</name>
      <forward mode='bridge'/>
      <bridge name='br0'/>
    </network>
    %EOF%

    sudo virsh net-define br0.xml
    sudo virsh net-start br0
    sudo virsh net-autostart br0

### Disk Pool einrichten

Optional kann ein Disk Pool eingerichtet werden. Standardmässig sollte dieser schon vorhanden sein.

    sudo virsh pool-define-as default dir - - - - "/var/lib/libvirt/images"  
    sudo virsh pool-autostart default  
    sudo virsh pool-start default 
 
### UI von MAAS aufrufen [ip:5240](http://localhost:5240)    
 
* Aktuelle Maschine als Pod eintragen
* Pod -> Compose VM
    
### Testen (optional)

    virt-install --name=test1-vm \
    --vcpus=1 \
    --memory=1024 \
    --cdrom=$HOME/cdrom/debian-9.9.0-amd64-netinst.iso \
    --disk size=5 \
    --os-variant=debian8  --graphic vnc

*** 
## MAAS CLI

Die MAAS Kommandline eignet sich um mehrere VMs zu erstellen.

Einloggen:

    maas login ubuntu http://localhost:5240/MAAS/api/2.0
    
Den API Key findet man im MAAS UI unter `ubuntu`.

Ids der Pods finden, diese brauchen wir um VMs zu erstellen. "tbz5-01pod" durch Pod Name ersetzen.

    maas ubuntu pods read | jq '.[] | select (.name=="tbz5-01pod") | .name, .id'

Mit diesen Informationen können wir die VMs erstellen

    for x in {01..08} ; do maas ubuntu pod compose 1 memory=1024 cpu=1 pool=0 hostname=m300-${x} ; done           
    
Tip: werden vorher im MAAS UI mehrere Pools erstellt, können die VMs über diese selektioniert werden.
    
## Links

* [Bridge KVM](https://askubuntu.com/questions/1054350/netplan-bridge-for-kvm-on-ubuntu-server-18-04-with-static-ips)
* [Static IP Ubuntu 18](https://linuxconfig.org/how-to-configure-static-ip-address-on-ubuntu-18-04-bionic-beaver-linux)
* [broadcast-dhcp-discover](https://nmap.org/nsedoc/scripts/broadcast-dhcp-discover.html)
* [Setup Default Network](http://blog.programster.org/kvm-missing-default-network)
* [Customising MAAS installs](https://ubuntu.com/blog/customising-maas-installs)
* [MAAS Blog Übersicht](https://ubuntu.com/blog/tag/maas)
* [curtin](https://maas.io/docs/custom-node-setup-preseed) 
* [Customising MAAS](https://ubuntu.com/blog/customising-maas-installs)
* [Customising MAAS installs](http://mattjarvis.org.uk/post/customising-maas/)
* [Ubuntu MAAS 2.2 Wake on LAN Driver Patch](https://github.com/yosefrow/MAAS-WoL-driver)
