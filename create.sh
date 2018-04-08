#!/bin/bash
#
#       Erstellt die Kubernetes VM pro Lehrer
#

# Einstellungen
source config.sh

#
# Bestehende VM loeschen
#
function destroy
{
	IP=$FIP
	for t in ${VMS}
	do
		echo "destroy VM ${t}kube"
        if	[ -d ${t}kube ]
        then
        	cd ${t}kube && vagrant destroy -f ; cd ..
        fi
        rm -rf ${t}kube
		rm -f ${t}-${VM_IPPREFIX}.${IP}.zip
		let IP=IP+1
    done
}

#
# Alle VMs stoppen
#
function halt
{
	for t in ${VMS}
	do
		echo "halt VM ${t}kube"
        if	[ -d ${t}kube ]
        then
        	cd ${t}kube && vagrant halt ; cd ..
        fi
    done
}

#
# Alle VMs starten
#
function up
{
	for t in ${VMS}
	do
		echo "up VM ${t}kube"
        if	[ -d ${t}kube ]
        then
        	cd ${t}kube && vagrant up ; cd ..
        fi
    done
}

#
# Zertifikate und SW fuer Zugriff aufbereiten
#
function client
{
	IP=$FIP
	for t in ${VMS}
	do
	    mkdir -p ${t}kube/.ssh
	        
	    cat >${t}kube/.ssh/config <<%EOF%
Host ${t}kube
Hostname ${VM_IPPREFIX}.${IP}
User vagrant
IdentityFile    ~/.ssh/${VM_IPPREFIX}.${IP}.key
%EOF%
	
		cat >${t}kube/dashboard.bat <<%EOF%
REM Startet Firefox mit der Dashboard Startseite und den Proxy 
cd /d %~d0%~p0
set DOCKER_HOST=tcp://${VM_IPPREFIX}.${IP}:2376
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
set DOCKER_HOST=tcp://${VM_IPPREFIX}.${IP}:2376
set DOCKER_TLS_VERIFY=1
set DOCKER_CERT_PATH=%~d0%~p0.docker
set PATH=%PATH%;%~d0%~p0bin;~d0%~p0git\\bin;%~d0%~p0git\\mingw64\\bin
set KUBECONFIG=%~d0%~p0.kube\\config
powershell.exe      
%EOF%
		unix2dos ${t}kube/dockerps.bat
	
		cat >${t}kube/dockersh.bat <<%EOF%
REM Setzt die Docker Umgebungsvariablen und startet PowerShell 
cd /d %~d0%~p0
set DOCKER_HOST=tcp://${VM_IPPREFIX}.${IP}:2376
set DOCKER_TLS_VERIFY=1
set DOCKER_CERT_PATH=%~d0%~p0.docker
set PATH=%PATH%;%~d0%~p0bin
set KUBECONFIG=%~d0%~p0.kube\\config
start %~d0%~p0git\\git-bash.exe   
%EOF%
		unix2dos ${t}kube/dockersh.bat	
	
		cp ${t}kube/.vagrant/machines/default/virtualbox/private_key ${t}kube/.ssh/${VM_IPPREFIX}.${IP}.key
		rm -f ${t}-${VM_IPPREFIX}.${IP}.zip
		cd ${t}kube && zip -4 -y -r -q ../${t}-${VM_IPPREFIX}.${IP}.zip .docker .kube/config .ssh *.bat bin firefox git; cd ..
	
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
	export IP=$FIP
	for t in ${VMS}
	do
        echo "create ${t}kube with ip ${VM_IPPREFIX}.${IP}"
        cp -rp template ${t}kube
        export VM_HOSTNAME=${t}kube
        envsubst '${VM_GATEWAY} ${VM_IPPREFIX} ${IP} ${VM_MEMORY} ${VM_HOSTNAME} ${VM_BRIDGE}' <template/Vagrantfile >${t}kube/Vagrantfile
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
	echo "halt - alle VM's stoppen"
	echo "up - alle VM's starten"
	echo "destroy - VM's loeschen"
	echo "vm - VM's neu anlegen" 
	echo "client - Client SW aufbereiten"
else
	$*
fi


