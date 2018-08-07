#!/bin/bash
#
#	ssh fuer Zugriff Master auf Worker konfigurieren
#

NODES=$(find /vagrant/.vagrant -name private_key | grep worker | cut -d/ -f 5)

# keine Worker Nodes vorhanden - Exit!
if	[ "${NODES}" == "" ]
then
	exit 0
fi

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