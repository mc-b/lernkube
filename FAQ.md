### FAQ

**Vagrant kann unter Windows 10 keine VM erzeugen, weil Hyper-V aktiv ist**
* **Lösung:** Hyper-V wie in [Hyper-V unter Windows 10 aktivieren und deaktivieren](https://www.xcep.net/blog/hyper-v-unter-windows-10-aktivieren-und-deaktivieren/) beschrieben, deaktiveren. 

**Vagrant up finishes but VM's not showing up in VirtualBox**
* Das vagrant/mmdb Beispiel kann keinen Netzwerkadapter anlegen.
* **Lösung:** Netzwerk manuell unter Datei -> Einstellungen -> Netzwerk -> Host-only Netzwerke mit IPv4 Adresse 192.168.60.1 und Netzmaske 255.255.255.0 anlegen.

**VirtualBox und vagrant nicht mehr Synchron.**
* **Lösung:** VM in VirtualBox manuell löschen und im Beispielverzeichnis (wo Vagrantfile steht) das Verzeichnis .vagrant weglöschen.

**Vagrant kann keine ssh Verbindung zur VM aufbauen.**
* **Lösung:** Firewall deaktivieren.

**vagrant up kann keine Host Ordner mehr mounten.**
* **Lösung:** Installieren Sie VirtualBox in der Version 5.2.6 ab Download

**Vagrant und VirtualBox Produzieren nicht nachvollziehbare Fehler.**
* **Lösung:** Beispiele in ein Verzeichnis ohne " " Leerschlag clonen/downloaden.

**vagrant wird in der Bash nicht gefunden.**
* **Lösung:** Verzeichnis wo sich vagrant.exe befindet in PATH eintragen.

**Alle anderen Fehler.**
* **Lösung:** Vagrant mittels `vagrant up --debug` starten.
