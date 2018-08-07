#!/bin/bash
#
#	ssh fuer Zugriff Master auf Worker konfigurieren
#

cat >>/vagrant/ssh.config <<%EOF% 
Host $(hostname)
Hostname $(hostname -I | cut -d ' ' -f 2)
User vagrant
IdentityFile    /home/vagrant/.ssh/$(hostname).key
%EOF%


