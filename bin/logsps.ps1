kubectl logs "$(kubectl get pod --selector=app=$args -o jsonpath='{.items..metadata.name}')" 
