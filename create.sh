#!/bin/bash
#
#       Erstellt die Kubernetes VM pro Lehrer
#

export TEACHERS="xx1 xx2"
export FIP=60

#
# Bestehende VM loeschen
#
function destroy
{
	IP=$FIP
	for t in ${TEACHERS}
	do
		echo "destroy VM ${t}kube"
        if	[ -d ${t}kube ]
        then
        	cd ${t}kube && vagrant destroy -f ; cd ..
        fi
        rm -rf ${t}kube
		rm -f ${t}-10.1.66.${IP}.zip
		let IP=IP+1
    done
}

#
# Zertifikate und SW fuer Zugriff aufbereiten
#
function client
{
	IP=$FIP
	for t in ${TEACHERS}
	do
	    mkdir -p ${t}kube/.ssh
	        
	    cat >${t}kube/.ssh/config <<%EOF%
Host ${t}kube
Hostname 10.1.66.${IP}
User vagrant
IdentityFile    ~/.ssh/10.1.66.${IP}.key
%EOF%
	
		cat >${t}kube/dashboard.bat <<%EOF%
REM Startet Firefox mit der Dashboard Startseite und den Proxy 
cd /d %~d0%~p0
set DOCKER_HOST=tcp://10.1.66.${IP}:2376
set DOCKER_TLS_VERIFY=1
set DOCKER_CERT_PATH=%~d0%~p0.docker
set PATH=%PATH%;%~d0%~p0bin
set KUBECONFIG=%~d0%~p0.kube\\config
start firefox\\firefoxportable.exe http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/. /B
kubectl proxy        
%EOF%
		unix2dos ${t}kube/dashboard.bat
	
	cat >${t}kube/dockerps.bat <<%EOF%
REM Setzt die Docker Umgebungsvariablen und startet PowerShell 
cd /d %~d0%~p0
set DOCKER_HOST=tcp://10.1.66.${IP}:2376
set DOCKER_TLS_VERIFY=1
set DOCKER_CERT_PATH=%~d0%~p0.docker
set PATH=%PATH%;%~d0%~p0bin;~d0%~p0git\\bin;%~d0%~p0git\\usr\\bin
set KUBECONFIG=%~d0%~p0.kube\\config
powershell.exe      
%EOF%
		unix2dos ${t}kube/dockerps.bat
	
		cat >${t}kube/dockersh.bat <<%EOF%
REM Setzt die Docker Umgebungsvariablen und startet PowerShell 
cd /d %~d0%~p0
set DOCKER_HOST=tcp://10.1.66.${IP}:2376
set DOCKER_TLS_VERIFY=1
set DOCKER_CERT_PATH=%~d0%~p0.docker
set PATH=%PATH%;%~d0%~p0bin
set KUBECONFIG=%~d0%~p0.kube\\config
start %~d0%~p0git\\git-bash.exe   
%EOF%
		unix2dos ${t}kube/dockersh.bat	
	
		cp ${t}kube/.vagrant/machines/default/virtualbox/private_key ${t}kube/.ssh/10.1.66.${IP}.key
		rm -f ${t}-10.1.66.${IP}.zip
		cd ${t}kube && zip -4 -y -r -q ../${t}-10.1.66.${IP}.zip .docker .kube/config .ssh *.bat bin firefox git; cd ..
	
    	let IP=IP+1
	done
}

#
# Neue VMs anlegen 
#
function vm
{
	# alte VM zuerst loeschen
	destroy

	# Neue VM anlegen	
	IP=$FIP
	for t in ${TEACHERS}
	do
        echo "create ${t}kube with ip ${IP}"
        cp -rp template ${t}kube
        sed -i -e "s/192.168.178.102/10.1.66.${IP}/g" ${t}kube/Vagrantfile
        sed -i -e "s/vgkube/${t}kube/g" ${t}kube/Vagrantfile

        cd ${t}kube && vagrant up ; cd ..	
        let IP=IP+1        
    done
    
    # Client SW aufbereiten
    client
}

########################
#
#	Hauptprogramm

if	[ $# -eq 0 ]
then
	echo "destroy - VM's loeschen"
	echo "vm - VM's neu anlegen" 
	echo "client - Client SW aufbereiten"
else
	$*
fi


