NFS
===

**Problematik**:
* Verteilt sich ein Kubernetes Cluster auf mehrere physikalische Maschinen, funktioniert die Weiterleitung auf den Hostpath [/data](https://github.com/mc-b/lernkube/tree/master/data) nicht mehr. D.h. je nach dem auf welcher Node der Container gestartet wird, werden die Daten auf eine andere physikalische Maschine geschrieben.

**Lösung**:
* [NFS](https://wiki.ubuntuusers.de/NFS/)-Share auf einem der physikalischen Servern einrichten.

Installation 
------------

Einrichten von NFS und Samba, auf einer physikalischen Maschine. Damit ist sichergestellt, dass Unix/Linux und Windows Systeme Zugriff darauf haben und die Daten nach zerstören der VMs/Container noch vorhanden sind.

### NFS Server

Installation NFS

    sudo apt-get update
    sudo apt install -y nfs-kernel-server
    
Shared Folder anlegen

    sudo mkdir -p /data /data/storage /data/storage/k8s /data/config /data/templates
    sudo chown -R ubuntu:ubuntu /data
    sudo chmod 777 /data/storage
    
Zugriff für Subnetze (192.168.2.0 = eigenes Subnets, 10.244.0.0 = Kubernetes/flannel) freischalten
    
    cat <<%EOF% >>/etc/exports
    # Storage RW
    /data/storage 192.168.2.0/24(rw,sync,no_subtree_check,all_squash,anonuid=1000,anongid=1000)
    /data/storage/k8s 10.244.0.0/16(rw,sync,no_subtree_check,all_squash,anonuid=1000,anongid=1000)
    # Templates RO
    /data/templates 192.168.2.0/24(ro,sync,no_subtree_check)
    /data/templates 10.244.0.0/16(ro,sync,no_subtree_check)
    # Config RO
    /data/config 192.168.2.0/24(ro,sync,no_subtree_check)
    /data/config 10.244.0.0/16(ro,sync,no_subtree_check)    
    %EOF%
     
    sudo exportfs -a
    sudo systemctl restart nfs-kernel-server

### NFS Client Windows

* [NFS für Windows 10 freischalten](https://forum.qnapclub.de/blog/entry/360-netzwerk-nfs-teil-2-die-alternative-zur-microsoft-netzwerk-freigabe-smb-samba-wi/)

### Kubernetes

    +---------------------------------------------------------------+
    ! Pods Verbinden sich mit PVC data-claim                        !   
    !   volumeMounts:                                               !
    !   - mountPath: "<Path im Container>"                          !
    !     subPath: <Path im PersistenVolume>                        !
    !     name: "host-data"                                         !
    ! volumes:                                                      !
    ! - name: "data"                                                !
    !   persistentVolumeClaim (PVC):                                !
    !    claimName: data-claim                                      !
    +---------------------------------------------------------------+
    ! PersistentVolumeClaim: data-claim fordert Speicher von Volume !   
    +---------------------------------------------------------------+
    ! PersistentVolume (PV): local-storage zeigt auf NFS Share /data!   
    +---------------------------------------------------------------+

Storage einrichten, ggf. IP-Adresse des NFS Servers in `DataVolume.yaml` ändern und PV und PVC erstellen 

    kubectl apply -f lernkube/nfs


### Links

* [Install NFS Server and Client on Ubuntu 18.04 LTS](https://vitux.com/install-nfs-server-and-client-on-ubuntu/)


