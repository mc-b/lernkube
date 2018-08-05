$service=$args[0]

start (kubectl config view -o=jsonpath='{ .clusters[0].cluster.server }' | `
%{ $_-replace "https:","http:"} | `
%{ $_-replace "6443", (kubectl get svc $service -o=jsonpath='{ .spec.ports[0].nodePort }')})