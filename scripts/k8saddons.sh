#!/bin/bash
#
#	Kubernetes Add-ons Installation
#

# Dashboard und User einrichten - Zugriff via kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}') Ermitteln
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-rc5/aio/deploy/recommended.yaml
kubectl apply -f /vagrant/addons/dashboard-admin.yaml

# Standard Persistent Volume und Claim
kubectl create -f /vagrant/data/
	
# Weave Scope 
kubectl apply -f "https://cloud.weave.works/k8s/scope.yaml?k8s-version=$(kubectl version | base64 | tr -d '\n')"
