Elastic Container Service for Kubernetes (Amazon EKS)
-----------------------------------------------------

* [Produktseite](https://aws.amazon.com/de/eks/)
* [Getting Started with Amazon EKS](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html)

### Quick Start

**Schritt 1: Amazon EKS Voraussetzungen**

* IAM Role mit EKS und IAM Rechten (wie mehr Rechte desto besser!) anlegen, z.B. `k8srole`.
* IAM User anlegen und `k8srole` zuweisen. Es wird ein `AWS Access Key ID` und `AWS Secret Access Key` erstellt.
* Console Password freischalten und setzen.
* Ausloggen! und mit erstelltem User über die [AWS Console](https://mc-b.signin.aws.amazon.com/console) einloggen.

**Schritt 2: Erstellen und Konfigurieren Sie Ihren Amazon EKS-Cluster**

* Erstellen Sie Ihren Amazon EKS-Cluster, geht am einfachsten über das [UI](https://console.aws.amazon.com/eks/home#/clusters).


* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html) installieren und konfigurieren

	aws configure

* Die Konfigurationsdateien werden im Home Verzeichnis des User im Verzeichnis `/.aws` angelegt.

* Datei `config` im Home Unterverzeichnis `.kube` anlegen.

	apiVersion: v1
	clusters:
	- cluster:
	    server: <endpoint-url>
	    certificate-authority-data: <base64-encoded-ca-cert>
	  name: kubernetes
	contexts:
	- context:
	    cluster: kubernetes
	    user: aws
	  name: aws
	current-context: aws
	kind: Config
	preferences: {}
	users:
	- name: aws
	  user:
	    exec:
	      apiVersion: client.authentication.k8s.io/v1alpha1
	      command: aws-iam-authenticator
	      args:
	        - "token"
	        - "-i"
	        - "<cluster-name>"
	        
Und folgende Argumente ersetzen:
* **endpoint-url** - API server endpoint
* **base64-encoded-ca-cert** - Certificate authority
* **cluster-name** - Clustername, welcher beim Erstellen des EKS-Cluster eingegeben wurde.

Alle Werte sind durch Klick auf den Clustername im [Cluster UI](https://console.aws.amazon.com/eks/home#/clusters) ersichtlich.

Kontrollieren durch Eingabe von:

	kubectl get all

**Schritt 3: Starten und konfigurieren Sie Amazon EKS Worker Nodes**

* Öffnen Sie die AWS CloudFormation-Konsole unter [https://console.aws.amazon.com/cloudformation](https://console.aws.amazon.com/cloudformation)

    * Create new Stack
    * Specify an Amazon S3 template URL
    
Alle Details siehe [Launch Worker Nodes](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html#eks-launch-workers)

### Datenspeicherung

Diverse Pods stellen Daten auf einer PersistentVolume ab, z.B. die [DevOps Tools](https://github.com/mc-b/duk/tree/master/devops).
Azure stellt zwei [Persistente Volumes](https://docs.microsoft.com/de-ch/azure/aks/azure-disks-dynamic-pv) zur Verfügung. Auf diesem muss ein `PersistentVolumeClaim` mit Namen `data-claim` eingerichtet werden, damit die Pods gestartet werden können. Für Details siehe [Gemeinsames Datenverzeichnis](../data).

	kubectl create -f aws/io1-storage-class.yaml
	kubectl create -f aws/DataVolume.yaml

**Links**
* [Speichern von Daten](https://docs.aws.amazon.com/eks/latest/userguide/storage-classes.html)
	
### Dashboard einrichten

Dashboard mit allen Rolen anlegen

	kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
	kubectl create -f aws/eks-admin-service-account.yaml
	kubectl create -f aws/eks-admin-cluster-role-binding.yaml
	
Ausgabe des Tokens um sich im Dashboard anmelden zu können:	

	kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep eks-admin | awk '{print $1}')
	
Port Weiterleitung aktiveren und Dashboard mittels [http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/](http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/) aufrufen. Anmelden mittels Tokens.
	
	kubectl proxy
	
**Link**
* [DashBoard](https://docs.aws.amazon.com/eks/latest/userguide/dashboard-tutorial.html)

### Probleme

* Pods und Services können erstellt werden, aber nicht von Aussen angesprochen werden. Fehlt ein LoadBalancer?
* Die Datenspeicherung funktioniert nicht.
        