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

Diverse Pods stellen Daten auf einer PersistentVolume ab, z.B. die [DevOps Tools](https://github.com/mc-b/duk/tree/master/devops).
Azure stellt zwei [Persistente Volumes](https://docs.microsoft.com/de-ch/azure/aks/azure-disks-dynamic-pv) zur Verfügung. Auf diesem muss ein `PersistentVolumeClaim` mit Namen `data-claim` eingerichtet werden, damit die Pods gestartet werden können. Für Details siehe [Gemeinsames Datenverzeichnis](../data)

	az aks show --resource-group k8sGroup --name k8sCluster  -o tsv --query nodeResourceGroup

	az storage account create --resource-group MC_k8sGroup_k8sCluster_eastus --name k8store --sku Standard_LRS
	
**Hinweis**: Falls das Erstellen mittels `az store account create` nicht funktioniert, `Speicherkonto` in `Ressourcengruppe` `MC_k8sGroup_k8sCluster_eastus` manuell anlegen.

	kubectl create -f azure/azure-file-sc.yaml
	kubectl create -f azure/azure-pvc-roles.yaml
	kubectl create -f azure/DataVolume.yaml
	
	kubectl get sc,pvc
	
 

