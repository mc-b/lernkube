Azure Kubernetes Service 
------------------------

Quick Start basierend auf [Deploy an Azure Kubernetes Service (AKS) cluster](https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough).

### Quick Start

[Azure CLI](https://docs.microsoft.com/de-ch/cli/azure/install-azure-cli?view=azure-cli-latest) Installieren

PowerShell starten für Zugriff auf Azure CLI und Anmelden via Azure CLI:

	az login

Ressourcen Gruppe `k8sGroup` erstellen

	az group create --name k8sGroup --location eastus
	
Kubernetes Cluster `k8sCluster` erstellen

	az aks create --resource-group k8sGroup --name k8sCluster --node-count 1 --enable-addons monitoring --generate-ssh-keys

*Optional*: Installieren des Kubernetes CLI `kubectl`, falls noch nicht installiert.

	az aks install-cli

Konfigurieren des Zugriff auf den Kubernetes Cluster, d.h. Erstellen einer `./kube/config` Datei im HOME-Verzeichnis, mittels

	az aks get-credentials --resource-group k8sGroup --name k8sCluster
	
Überprüfen ob eine Verbindung möglich ist und weitere Informationen zum Cluster ausgeben:

	kubectl get nodes
	kubectl cluster-info

### Starten und Tests von Pods
	
Pods können mittels `kubectl` oder über das Dashboard gestartet werden. Jeder `Service` Einträg mit `type` erhält eine eigene IP-Adresse. 
Die IP-Adresse und der Originale Port bilden den URL für den Zugriff auf den `Service`.

Z.B.:

	kubectl create -f duk/osticket
	
	kubectl get svc,pod

Ausgabe:

	NAME                 TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
	svc/osticket         LoadBalancer   10.98.204.102    40.1.20.178   80:30610/TCP     8s
	svc/osticket-mysql   ClusterIP      None             <none>        3306/TCP         8s
	
	NAME                                 READY     STATUS              RESTARTS   AGE
	po/osticket-595946777d-z4ls4         0/1       ContainerCreating   0          9s
	po/osticket-mysql-7f89fb59df-sbsnt   0/1       ContainerCreating   0          9s

OS Ticket ist via `http://40.1.20.178:80` erreichbar, das Port Mapping auf 30610 wird ignoriert.	

### Datenspeicherung	

Diverse Pods stellen Daten auf einer PersistentVolume ab, z.B. die [DevOps Tools](https://github.com/mc-b/duk/tree/master/devops).
Azure stellt zwei [Persistente Volumes](https://docs.microsoft.com/de-ch/azure/aks/azure-disks-dynamic-pv) zur Verfügung. Auf diesem muss ein `PersistentVolumeClaim` mit Namen `data-claim` eingerichtet werden, damit die Pods gestartet werden können. Für Details siehe [Gemeinsames Datenverzeichnis](../data)

	az aks show --resource-group k8sGroup --name k8sCluster  -o tsv --query nodeResourceGroup

	az storage account create --resource-group MC_k8sGroup_k8sCluster_eastus --name k8store --sku Standard_LRS
	
**Hinweis**: Falls das Erstellen mittels `az store account create` nicht funktioniert, `Speicherkonto` in `Ressourcengruppe` `MC_k8sGroup_k8sCluster_eastus` manuell anlegen.

	kubectl create -f azure/azure-file-sc.yaml
	kubectl create -f azure/azure-pvc-roles.yaml
	kubectl create -f azure/DataVolume.yaml
	
	kubectl get sc,pvc
	
### Dashboard

Rolle freischalten

	kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard
	
Dashboard aufrufen
	
	az aks browse --resource-group k8sGroup --name k8sCluster

### Aufräumen

Durch das Löschen der Ressource Gruppe wird auch der Kubernetes mit allen Daten gelöscht.

	az group delete --name k8sGroup --yes --no-wait

### Probleme

* Die Datenspeicherung funktioniert nicht sauber. So kann z.B. Gogs zwar alle Dateien anlegen, aber nicht auf die SQLLite Datenbank zugreifen.
* Bekommt ein Service keine Externe IP, ist darauf zu Achten, dass `LoadBalancer` statt `NodePort` bei `type` eingetragen ist. 

