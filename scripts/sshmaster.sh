#!/bin/bash
#
#	ssh fuer Zugriff Master auf Worker konfigurieren
#

####
# evtl. vorhandene /vagrant/templates/config/authorized_keys anfuegen

if [ -f "/vagrant/templates/config/authorized_keys" ]
then
    cat /vagrant/templates/config/authorized_keys >>/home/vagrant/.ssh/authorized_keys
fi

####
# Wireguard installieren wenn wg0.conf vorhanden ist

if [ -f "/vagrant/templates/config/wg0.conf" ]
then
    add-apt-repository -y ppa:wireguard/wireguard
    apt-get update
    apt-get install -y wireguard
    cp /vagrant/templates/config/wg0.conf /etc/wireguard/
    chmod 750 /etc/wireguard
    systemctl enable wg-quick@wg0.service
    systemctl start wg-quick@wg0.service
fi        

####
# Worker Joinen

NODES=$(find /vagrant/.vagrant -name private_key | grep worker | cut -d/ -f 5)

# Worker Nodes vorhanden - joinen
if	[ "${NODES}" != "" ]
then

	# Private Keys von NODES kopieren
	for node in ${NODES}
	do
		cp -v /vagrant/.vagrant/machines/${node}/virtualbox/private_key /home/vagrant/.ssh/${node}.key
	done
	
	mv -v /vagrant/ssh.config /home/vagrant/.ssh/config
	chmod -R o-rwx,g-rwx /home/vagrant/.ssh
	chown -R vagrant:vagrant /home/vagrant/.ssh/
	
	# NODES mit Master joinen
	
	join=$(kubeadm token create --print-join-command)
	
	for node in ${NODES}
	do
		su vagrant -c "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${node} sudo ${join}"
	done
	
fi

echo "===================================================================="
echo "VM: $(hostname), Cluster-IP: $(hostname -I | cut -d ' ' -f 2)"
echo "Dashboard $(kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}') | grep token:)"
echo "===================================================================="