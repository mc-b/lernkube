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

Beispiele, basierend auf sechs physikalischen Servern sind:
* ein Master und fünf Worker Nodes, als ein Grosser K8s Cluster
* vier Master pro Server - Total 24 Master, z.B. damit jeder Lernende einen Master zur Verfügung hat
* ein Master und drei Worker auf dem ersten Server, weitere 20 Worker verteilt auf die weiteren Server, z.B. um einen grösseren Cluster zu testen.

**Nach er erstmaligen Installation der physikalsichen Server wird keine weitere SW auf diese Installiert. SW wird nur in die Virtuellen Maschinen installiert, bzw. es werden Container gestartet**

Installation der Server
-----------------------

### Konfiguration der Server

Der Einfachheit halber wird mit statischen IP-Adressen für die Server gearbeitet.

Bei Ubuntu 18.x ist dazu die Datei `/etc/netplan/50-cloud-yaml` zu ändern, z.B.

    # For more information, see netplan(5).
    network:
      ethernets:
        eno1:
           dhcp4: false
           addresses: [172.16.17.XX/24]
           gateway4: 172.16.17.1
           nameservers:
               addresses: [10.62.98.8,10.62.99.8]           
      version: 2

etc. für die weiteren Server.

Auf dem ersten Server wird mittels 

    ssh-keygen
    
ein SSH Key erstellt und der Key auf die anderen kopiert:

    ssh-copy-id <hostname>:
    
Testen mittels

    ssh <hostname>
    
Um immer mit den gleichen ssh Namen auf die Server zuzugreifen ist auf dem ersten Server eine Datei `.ssh/config` mit folgendem Inhalt zu erstellen:

    Host w1
        Hostname 172.16.17.X1
    Host w2
        Hostname 172.16.17.X2

etc. Damit können die anderen Server mittels `ssh w1`, `ssh w2` etc. angesprochen werden.     
    
### Installation der Software

Auf jedem Server wird VirtualBox, Vagrant und das geklonte Projekt `lernkube` benötigt. Die eigentlichern Kubernetes Nodes laufen immer in virtuellen Maschinen, damit wird eine grössere Flexibilität der Umgebung erreicht.

Installation VirtualBox und abhängige Software:

    sudo apt-get update
    sudo apt-get install -y git curl wget gcc make perl zip virtualbox

Installation Vagrant und benötigte Plug-Ins:

    wget https://releases.hashicorp.com/vagrant/2.2.4/vagrant_2.2.4_x86_64.deb
    sudo dpkg -i vagrant_2.2.4_x86_64.deb
    vagrant plugin install vagrant-disksize

Clonen des Projektes `lernkube` von github:

    git clone https://github.com/mc-b/lernkube
    
**Trick**: zuerst `lernkube` clonen und obige Befehle in separate Datei rausschreiben und ausführen mittels `bash -x install` 
    
Damit ist die Grundinstallation abgeschlossen. Um zu Testen ob die Installation funktioniert kann ein einfacher Cluster erstellt werden:

    cd lernkube
    vagrant up
        
läuft alles durch, erscheint am Schluss eine Meldung welche ungefähr so aussieht:

    ====================================================================
    VM: master-01, Cluster-IP: 192.168.137.100
    dashboard - Aufruf Dashboard, Login mit
    token:      .....
    ====================================================================

Aufräumen nicht vergessen

    vagrant destroy -f

Cluster Umgebung aufbauen
-------------------------

### Layouts

Cluster Umgebungen basieren auf einem Layout. Ein Layout ist eine Anordnung bzw. Verteilung von virtuellen Maschinen auf den physikalischen Servern, z.B.:
* ein Master und fünf Worker Nodes, als ein Grosser K8s Cluster
* vier Master pro Server - Total 24 Master, z.B. damit jeder Lernende einen Master zur Verfügung hat
* ein Master und drei Worker auf dem ersten Server, weitere 20 Worker verteilt auf die weiteren Server, z.B. um einen grösseren Cluster zu testen.

Layouts basieren auf `config.yaml` für den ersten physikalischen Server und `<server>.yaml` Dateien, welche im `templates/<layout>` Verzeichnis abgelegt werden.
Der Name sollte sprechend sein, z.B.
* cluster6x1
* master6x4
* cluster6x4

**ACHTUNG**: je nach Netzwerk ist der Eintrag `default_router` richtig zu setzen, bzw. zu entfernen

Fixe IP-Adressen ohne DHCP Server und manuellem Gateway Eintrag:

    default_router: "route add default gw 172.16.17.1 enp0s8 && route del default gw 10.0.2.2 enp0s3"
    
Mit vorhandenem DHCP Server und automatischem Routing:   

    default_router: ""

#### Beispiel: ein Master und vier Worker Nodes

Datei `config.yaml`, die komplette Datei findet man im Verzeichnis `templates/cluster6x1`

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

    clusteradm status templates/cluster6x1
    clusteradm destroy templates/cluster6x1
    clusteradm up templates/cluster6x1
    clusteradm join templates/cluster6x1 master-01
    
#### Beispiel: vier Master pro Server 

Datei `config.yaml`, die komplette Datei findet man im Verzeichnis `templates/master6x4`

    master:
      count: 4
      hostname: master00
    worker:
      count: 0

Die Dateien `<server>.yaml`

    master:
      count: 4
      hostname: masterX0
    worker:
      count: 0
      
**Zur Beachtung**: 
* Der Servername ist der gleiche wie bei `ssh <server>`.
* Der Eintrag `hostname`, für die Master-Nodes, muss pro Server unterschiedlich sein und `master` beinhalten.
* Wird mit fixen IPs gearbeitet sind diese manuell aufzuzählen, bzw. zu schauen, dass keine doppelte vorkommen.

**Starten**

Starten bzw. Erstellen der einzelnen VMs und anschliessendes Aufbereiten der Serverkeys, `kubectl` etc. für den Remotezugriff auf die VMs:

    clusteradm status templates/master6x4
    clusteradm destroy templates/master6x4
    clusteradm up templates/master6x4
    clusteradm zip templates/master6x4
   
Die erstellten ZIP Dateien, auf dem ersten physikalischen Server, sind den Lernenden abzugeben. Diese entpacken diese ein einem Verzeichnis ihrer Wahl und setzen die Umgebung mittels:
* Doppelklick auf `kubeps.bat` für Powershell
* Doppelklick auf `kubesh.bat` für Git/Bash (muss im PATH eingetragen sein)
* Starten einer Bash Umgebung wechsel ins entpackte Verzeichnis und Eingabe `source kubeenv`.

       
