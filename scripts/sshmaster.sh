#!/bin/bash
#
#	ssh fuer Zugriff Master auf Worker konfigurieren
#


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
echo "===================================================================="