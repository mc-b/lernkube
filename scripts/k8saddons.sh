#!/bin/bash
#
#	Kubernetes Add-ons Installation
#

# Dashboard und User einrichten - Zugriff kubectl proxy und beim Login skip druecken
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
kubectl apply -f /vagrant/addons/dashboard-admin.yaml

# Standard Persistent Volume und Claim
kubectl create -f /vagrant/data/
	
# Weave Scope 
kubectl apply -f "https://cloud.weave.works/k8s/scope.yaml?k8s-version=$(kubectl version | base64 | tr -d '\n')"
