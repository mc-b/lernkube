#!/bin/bash
#
#   Kubernetes Master Installation
#
if [ -f /vagrant/kubeadm.yaml ]
then
    sudo kubeadm init --config /vagrant/kubeadm.yaml
else
    sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address  $(hostname -I | cut -d ' ' -f 2) --apiserver-cert-extra-sans $1
fi    

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# this for loop waits until kubectl can access the api server that kubeadm has created
for i in {1..150}; do # timeout for 5 minutes
   ./kubectl get po &> /dev/null
   if [ $? -ne 1 ]; then
      break
  fi
  sleep 2
done

# Pods auf Master Node erlauben
kubectl taint nodes --all node-role.kubernetes.io/master-

# Internes Pods Netzwerk (mit: --iface enp0s8, weil vagrant bei Hostonly Adapters gleiche IP vergibt)
sysctl net.bridge.bridge-nf-call-iptables=1
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/k8s-manifests/kube-flannel-rbac.yml
# kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
kubectl apply -f /vagrant/addons/kube-flannel.yaml


# Vagrant User Zugriff auf Cluster erlauben
cp -rp $HOME/.kube /home/vagrant/
chown -R vagrant:vagrant /home/vagrant/.kube

# Install ingress bare metal, https://kubernetes.github.io/ingress-nginx/deploy/
kubectl apply -f /vagrant/addons/ingress-mandatory.yaml
kubectl apply -f /vagrant/addons/service-nodeport.yaml

##########################
# Package Manager (HELM - Achtung bei Versionwechsel auch client.sh aendern).
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
helm repo add stable https://charts.helm.sh/stable