#!/bin/bash
#
#	Kubernetes Basis Installation
#
VERSION=${1}

set -o xtrace

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" >> /etc/apt/sources.list.d/Kubernetes.list
sudo apt-get -q 2 update
sudo apt-get install -q 2 -y kubelet=${VERSION} kubeadm=${VERSION}

# Bug vagrant, @see https://linuxacademy.com/community/posts/show/topic/29447-pod-is-not-found-eventhough-pod-status-is-up-and-running-why
if  [ "$(hostname | cut -d- -f1)" = "worker" ]
then
    cat <<%EOF% >>/etc/systemd/system/kubelet.service.d/10-kubeadm.conf
Environment="KUBELET_EXTRA_ARGS=--node-ip=$(hostname -I | cut '-d ' -f2)"
%EOF%

    systemctl daemon-reload
    systemctl restart kubelet

fi