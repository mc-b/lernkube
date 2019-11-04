OpenShift
---------

### Quick-Start (in der BASH Shell)

OpenShift Umgebung als VM Erstellen (muss auf Laufwerk C: ausgeführt werden):

    minishift start --vm-driver virtualbox --cpus 4 --memory 8GB
    
Umgebungsvariablen für den Zugriff setzen:

kubectl:

    export KUBECONFIG=/c/Users/${USERNAME}/.minishift/machines/minishift_kubeconfig
    
docker:

    export DOCKER_CERT_PATH=/c/Users/${USERNAME}/.minishift
    export DOCKER_TLS_VERIFY=1
    export DOCKER_HOST=tcp://192.168.99.102:2376
    
Testen:

    docker image ls
    kubectl get pods --all-namespaces    
         

