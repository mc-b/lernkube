

$env:pod=(kubectl get -n weave pod --selector=weave-scope-component=app -o jsonpath='{.items..metadata.name}')
start-process http://localhost:4040
kubectl port-forward -n weave $env:pod 4040
