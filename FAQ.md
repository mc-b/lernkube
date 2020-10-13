### FAQ

#### Vagrant

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

**vagrant kann keine Host-only Netzwerkadapter mehr erstellen**
* Wenn das VPN WireGuard installiert ist, werden die Netzwerkadapter Geräte falsch bezeichnet. Dadurch findet VirtualBox diese nicht mehr.
* **Lösung:** `public_network` oder nur NAT im Vagrantfile verwenden. 

**Alle anderen Fehler.**
* **Lösung:** Vagrant mittels `vagrant up --debug` starten.

#### Container

**Wie ersetzte ich Docker mit containerd?**
* **Lösung:** Im Vagrantfile die `docker` Scripts, ca. Zeile 55 und 99, auskommentieren und `containerd` Scripts aktivieren

**Wie ersetzte ich Docker mit cri-o?**
* **Lösung:** Im Vagrantfile die `docker` Scripts, ca. Zeile 55 und 99, auskommentieren und `cri-o` Scripts aktivieren.

**Welche Tools und Übungen/Beispiele funktionieren nicht mit `containerd` oder `cri-o`?**
* Das Caching der Container mittels Verzeichnis `cr-cache` 
* `Weave Scope` findet keine Container
* `jenkins` braucht zwingend `Docker`.
* Mit `cri-o` funktionieren die Docker Übungen/Beispiel nicht.

**Wie kann ich bei `containerd` und `cri-o` anschauen, welche Images vorhanden sind?**
* `sudo crictl images` zeigt die Images
* `sudo crictl ps` oder `sudo crictl pods` die laufenden Container/Pods.

#### Kubernetes

**Ein `kubectl` Befehl funktioniert nicht wie gewünscht.**<br>
* **Lösung:** `kubectl -v9 ...` voranstellen um mehr Debugging Informationen zu erhalten.  

**Die Pods auf den Worker Nodes können nicht mittels `kubectl exec` angesprochen werden**<br>
**Problem:** Vagrant weisst als erste IP Adresse immer fix 10.0.2.15 zu. Diese IP-Adresse übernimmt auch K8s.

    kubectl get node worker-01 -o yaml | grep address
    
    addresses:
    - address: 10.0.2.15
    - address: worker-01
    
**Lösung:** Einloggen auf jeder Worker-Node, Datei `/etc/systemd/system/kubelet.service.d/10-kubeadm.conf` um IP-Adresse erweitern und Restart kubelet.

    cat <<%EOF% >>/etc/systemd/system/kubelet.service.d/10-kubeadm.conf
    Environment="KUBELET_EXTRA_ARGS=--node-ip="$(hostname -I | cut '-d ' -f2)"
    %EOF%

    systemctl daemon-reload
    systemctl restart kubelet    

@see: [Playing with kubeadm in Vagrant Machines, Part 2](https://medium.com/@joatmon08/playing-with-kubeadm-in-vagrant-machines-part-2-bac431095706)
  