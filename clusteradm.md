Kubernetes Cluster Administration
=================================

Angelegt an `kubeadm` zur Installation von Kubernetes Nodes gibt es ein Shellscript `clusteradm` um mehrere Nodes zu erstellen.

Bei den Nodes kann es sich um:
* einen Master und x-Worker Nodes 
* viele Master
handeln.

Die Nodes werden dabei auf mehrere physikalische Server verteilt. 
Der erste Server beinhaltet immer den Master und evtl. Worker Nodes. 
Die weiteren Server nur Worker Nodes oder weitere autonome Master.

Beispiele, basierend auf fünf physikalischen Servern sind:
* ein Master und vier Worker Nodes, als ein Grosser K8s Cluster
* fünf Master pro Server - Total 25 Master, z.B. damit jeder Lernende einen Master zur Verfügung hat
* ein Master und vier Worker auf dem ersten Server, weitere 20 Worker verteilt auf die weiteren Server, z.B. um einen grösseren Cluster zu testen.

Installation der Server
-----------------------

### Konfiguration der Server

Der Einfachheit halber wird mit statischen IP-Adressen für die Server gearbeitet.

Bei Ubuntu 18.x ist dazu die Datei `/etc/netplan/01-netcfg-yaml` zu ändern, z.B.

    # For more information, see netplan(5).
    network:
      version: 2
      renderer: networkd
      ethernets:
        enp2s0:
           dhcp4: no
           dhcp6: no
           addresses: [192.168.178.12/24]
           gateway4: 192.168.178.1

etc. für die weiteren Server.

Auf dem ersten Server wird mittels 

    ssh-keygen
    
ein SSH Key erstellt und der Key auf die anderen kopiert:

    ssh-copy-id <hostname>:
    
Testen mittels

    ssh <hostname>
    
### Installation der Software

Auf jedem Server wird VirtualBox, Vagrant und das geklonte Projekt `lernkube` benötigt. Die eigentlichern Kubernetes Nodes laufen immer in virtuellen Maschinen, damit wird eine grössere Flexibilität der Umgebung erreicht.

Installation VirtualBox und abhängige Software:

    sudo apt-get install -y git curl wget gcc make perl zip 
    wget https://download.virtualbox.org/virtualbox/6.0.8/virtualbox-6.0_6.0.8-130520~Ubuntu~xenial_amd64.deb
    sudo dpkg -i virtualbox-6.0_6.0.8-130520~Ubuntu~xenial_amd64.deb
    sudo apt-get install -f

Installation Vagrant und benötigte Plug-Ins:

    wget https://releases.hashicorp.com/vagrant/2.2.4/vagrant_2.2.4_x86_64.deb
    sudo dpkg -i vagrant_2.2.4_x86_64.deb
    vagrant plugin install vagrant-disksize

Clonen des Projektes `lernkube` von github:

    git clone https://github.com/mc-b/lernkube
    
Damit ist die Grundinstallation abgeschlossen. Um zu Testen ob die Installation funktioniert kann ein einfacher Cluster erstellt werden:

    cd lernkube
    vagrant up
        
läuft alles durch, erscheint am Schluss eine Meldung welche ungefähr so aussieht:

    ====================================================================
    VM: master-01, Cluster-IP: 192.168.137.100
    dashboard - Aufruf Dashboard, Login mit
    token:      .....
    ====================================================================

Cluster Umgebung aufbauen
-------------------------

### Layouts

Cluster Umgebungen basieren auf einem Layout. Ein Layout ist eine Anordnung bzw. Verteilung von virtuellen Maschinen auf den physikalischen Servern, z.B.:
* ein Master und vier Worker Nodes, als ein Grosser K8s Cluster
* fünf Master pro Server - Total 25 Master, z.B. damit jeder Lernende einen Master zur Verfügung hat
* ein Master und vier Worker auf dem ersten Server, weitere 20 Worker verteilt auf die weiteren Server, z.B. um einen grösseren Cluster zu testen.

Layouts basieren auf `config.yaml` für den ersten physikalischen Server und `<server>.yaml` Dateien, welche im `templates/<layout>` Verzeichnis abgelegt werden.
Der Name sollte sprechend sein, z.B.
* cluster5x1
* master5x5
* cluster5x5

#### Beispiel: ein Master und vier Worker Nodes

Datei `config.yaml`, die komplette Datei findet man im Verzeichnis `templates/cluster5x1`

    master:
      count: 1
      hostname: master
    worker:
      count: 0

Die Dateien `<server>.yaml`

    master:
      count: 0
      hostname: master
    worker:
      count: 1
      hostname: worker30     
      
**Zur Beachtung**: 
* Der Servername ist der gleiche wie bei `ssh <server>`.
* Der Eintrag `hostname`, für den Master, sollte nicht verändert werden und wenn dann `master` beinhalten.
* Der Eintrag `hostname`, für die Worker-Nodes, muss pro Server unterschiedlich sein und `worker` beinhalten.
* Wird mit fixen IPs gearbeitet sind diese manuell aufzuzählen, bzw. zu schauen, dass keine doppelte vorkommen.

**Starten**

    clusteradm up templates/cluster5x1
    clusteradm join templates/cluster5x1 master-01
    
#### Beispiel: fünf Master pro Server 

Datei `config.yaml`, die komplette Datei findet man im Verzeichnis `templates/master5x1`

    master:
      count: 5
      hostname: master10
    worker:
      count: 0

Die Dateien `<server>.yaml`

    master:
      count: 5
      hostname: master20
    worker:
      count: 0
      
**Zur Beachtung**: 
* Der Servername ist der gleiche wie bei `ssh <server>`.
* Der Eintrag `hostname`, für die Master-Nodes, muss pro Server unterschiedlich sein und `master` beinhalten.
* Wird mit fixen IPs gearbeitet sind diese manuell aufzuzählen, bzw. zu schauen, dass keine doppelte vorkommen.

**Starten**

Starten bzw. Erstellen der einzelnen VMs und anschliessendes Aufbereiten der Serverkeys, `kubectl` etc. für den Remotezugriff auf die VMs:

    clusteradm up templates/master5x1
    clusteradm zip templates/master5x1
   
Die erstellten ZIP Dateien, auf dem ersten physikalischen Server, sind den Lernenden abzugeben. Diese entpacken diese ein einem Verzeichnis ihrer Wahl und setzen die Umgebung mittels:
* Doppelklick auf `kubeps.bat` für Powershell
* Doppelklick auf `kubesh.bat` für Git/Bash (muss im PATH eingetragen sein)
* Starten einer Bash Umgebung wechsel ins entpackte Verzeichnis und Eingabe `source kubeenv`.

       
