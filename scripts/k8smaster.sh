#!/bin/bash
#
#	Kubernetes Master Installation
#

sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address  $(hostname -I | cut -d ' ' -f 2)

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

# Internes Pods Netzwerk
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.10.0/Documentation/kube-flannel.yml

# Pods auf Master Node erlauben
kubectl taint nodes --all node-role.kubernetes.io/master-

# Vagrant User Zugriff auf Cluster erlauben
cp -rp $HOME/.kube /home/vagrant/
chown -R vagrant:vagrant /home/vagrant/.kube

# Install nginx ingress 
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/default-backend.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/configmap.yaml 
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/tcp-services-configmap.yaml 
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/udp-services-configmap.yaml
kubectl apply -f  https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/rbac.yaml 
kubectl apply -f  https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/with-rbac.yaml 	
kubectl apply -f  /vagrant/addons/service-nodeport.yaml