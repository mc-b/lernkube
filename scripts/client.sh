#!/bin/bash
#
# 	Aufbereitung Client Scripts und Programme.
#

function info
{
cat <<%EOF%
echo "===================================================================="
echo "VM: $(hostname), Cluster-IP: $(hostname -I | cut -d ' ' -f 2)"
echo ""
echo "dashboard - Aufruf Dashboard, Login mit"
echo "$(kubectl -n kube-system describe secret  $(kubectl -n kube-system get secret | grep kubernetes-dashboard-token | awk ' { print $1 }' ) | grep token:)"
echo "weave - Aufruf Weave ein Werkzeug zur grafischen Visualisierung der Container"
echo ""
echo "kubectl apply -f YAML-Datei - Service, laut YAML-Datei, starten bzw. aktualisieren"
echo "kubectl delete -f YAML-Datei - Service, laut YAML-Datei, loeschen"
echo "startsvc 'service' - Oeffnet Service UI im Browser"
echo "runbash 'service' - Wechselt in die Bash des Containers 'service'"
echo "logs 'service' - Liefert Loginformationen des Containers'"
echo ""
echo "docker image ls - Anzeige der Images"
echo "docker build - Builden eines Images laut Dockerfile"
echo ""
echo "vagrant ssh $(hostname) - Wechselt in die VM"
echo "===================================================================="
%EOF%
}

sudo apt-get install -q 2 -y dos2unix bsdtar

# wenn nur 1 Master Scripts in /vagrant ablegen
if	[ $1 -eq 1 ]
then
	sudo rm -rf /vagrant/.kube /vagrant/.docker /vagrant/*.bat
	export OUT=/vagrant
else
	export OUT=/vagrant/$(hostname)
	sudo rm -rf $OUT/
    sudo mkdir -p $OUT/
    # Hilfsscripts
    sudo cp -rp /vagrant/bin $OUT/
fi
    
# Docker - Externer Zugriff
sudo cp -rp /home/vagrant/.docker $OUT/

# kuberntes - Externer Zugriff
cp -rp $HOME/.kube $OUT/

# Dashboard
cat >$OUT/dashboard.bat <<%EOF%
@ECHO OFF
REM Startet den Browser mit der Dashboard Startseite und den Proxy 
cd /d %~d0%~p0
set DOCKER_HOST=tcp://$(hostname -I | cut -d ' ' -f 2):2376
set DOCKER_TLS_VERIFY=1
set DOCKER_CERT_PATH=%~d0%~p0.docker
set PATH=%PATH%;%~d0%~p0bin
set KUBECONFIG=%~d0%~p0.kube\\config
start http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/. /B
kubectl proxy     
%EOF%
unix2dos $OUT/dashboard.bat

# kubeps.bat	
cat >$OUT/kubeps.bat <<%EOF%
@ECHO OFF
REM Setzt die Docker Umgebungsvariablen und startet PowerShell 
cd /d %~d0%~p0
set DOCKER_HOST=tcp://$(hostname -I | cut -d ' ' -f 2):2376
set DOCKER_TLS_VERIFY=1
set DOCKER_CERT_PATH=%~d0%~p0.docker
set PATH=%~d0%~p0bin;~d0%~p0git\\bin;%~d0%~p0git\\mingw64\\bin;%~d0%~p0git\\usr\\bin;%PATH%
set KUBECONFIG=%~d0%~p0.kube\\config
$(info)  
powershell.exe    
%EOF%
unix2dos $OUT/kubeps.bat

# kubesh.bat	
cat >$OUT/kubesh.bat <<%EOF%
@ECHO OFF
REM Wechselt in die VM mittels ssh 
cd /d %~d0%~p0
start vagrant ssh master-01   
%EOF%
unix2dos $OUT/kubesh.bat	

# kubeenv	
cat >$OUT/kubeenv <<%EOF%
#!/bin/bash
# Setzt die Docker Umgebungsvariablen, Aufruf mittels . ./kubeenv 
export DOCKER_HOST=tcp://$(hostname -I | cut -d ' ' -f 2):2376
export DOCKER_TLS_VERIFY=1
export DOCKER_CERT_PATH=\$(pwd)/.docker
export PATH=\$PATH:\$(pwd)/bin:\$(pwd)
export KUBECONFIG=\$(pwd)/.kube/config
$(info)  
%EOF%

# fuer Linux alle Scripts ausfuehrbar
chmod +x $OUT/bin/*

# kubectl CLI
curl -s -L https://storage.googleapis.com/kubernetes-release/release/v1.15.1/bin/windows/amd64/kubectl.exe -o $OUT/bin/kubectl.exe
# docker CLI
( cd $OUT/bin/ && curl -s -L https://download.docker.com/win/static/stable/x86_64/docker-17.09.0-ce.zip | bsdtar xvf - && mv docker/docker.exe . && rm -rf docker)
# helm CLI
( cd $OUT/bin/ && curl -s -L https://storage.googleapis.com/kubernetes-helm/helm-v2.10.0-rc.3-windows-amd64.zip | bsdtar xvf - && mv windows-amd64/helm.exe . && rm -rf windows-amd64)
# kubeless
( cd $OUT/bin/ && curl -s -L https://github.com/kubeless/kubeless/releases/download/v1.0.0/kubeless_windows-amd64.zip | bsdtar xvf - && mv bundles/kubeless_windows-amd64/kubeless.exe . && rm -rf bundles)
