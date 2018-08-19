Debug Services
--------------

Ein Problem, das bei Neuinstallationen von Kubernetes häufig auftritt, ist, dass ein Service nicht richtig funktioniert. Sie haben `kubectl create -f YAML-Datei` ausgeführt Deployment, Pods und ein Service erstellt, aber Sie erhalten keine Antwort, wenn Sie versuchen, darauf zuzugreifen.

Auf dieser Seite sind Mögliche Debugging Möglichkeiten aufgeführt. Die Seite basiert auf [Debug Services](https://kubernetes.io/docs/tasks/debug-application-cluster/debug-service/)

### Cluster 

Ein Kubernetes Cluster mit Flannel aufgesetzt mit Vagrant funktioniert nicht. Siehe [](https://github.com/coreos/flannel/blob/master/Documentation/troubleshooting.md#vagrant)
 

### Commands in Pods

	kubectl run -it --rm --restart=Never busybox --image=busybox sh


### Start Debug Services

	kubectl run hostnames --image=k8s.gcr.io/serve_hostname \
	                        --labels=app=hostnames \
	                        --port=9376 \
	                        --replicas=3
	                        
	kubectl expose deployment hostnames --port=32100 --target-port=9376	                        
	
	
	