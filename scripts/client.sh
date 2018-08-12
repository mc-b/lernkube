#!/bin/bash
#
# 	Aufbereitung Client Scripts und Programme.
#
sudo apt-get install -q 2 -y dos2unix

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

# Externer Zugriff
cp -rp $HOME/.kube $OUT/

# Dashboard
cat >$OUT/dashboard.bat <<%EOF%
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

# dockerps.bat	
cat >$OUT/dockerps.bat <<%EOF%
REM Setzt die Docker Umgebungsvariablen und startet PowerShell 
cd /d %~d0%~p0
set DOCKER_HOST=tcp://$(hostname -I | cut -d ' ' -f 2):2376
set DOCKER_TLS_VERIFY=1
set DOCKER_CERT_PATH=%~d0%~p0.docker
set PATH=%~d0%~p0bin;~d0%~p0git\\bin;%~d0%~p0git\\mingw64\\bin;%~d0%~p0git\\usr\\bin;%PATH%
set KUBECONFIG=%~d0%~p0.kube\\config
powershell.exe      
%EOF%
unix2dos $OUT/dockerps.bat

# dockersh.bat	
cat >$OUT/dockersh.bat <<%EOF%
REM Setzt die Docker Umgebungsvariablen und startet Git/Bash 
cd /d %~d0%~p0
set DOCKER_HOST=tcp://$(hostname -I | cut -d ' ' -f 2):2376
set DOCKER_TLS_VERIFY=1
set DOCKER_CERT_PATH=%~d0%~p0.docker
set PATH=%PATH%;%~d0%~p0bin
set KUBECONFIG=%~d0%~p0.kube\\config
start git-bash.exe   
%EOF%
unix2dos $OUT/dockersh.bat	

# kubeenv	
cat >$OUT/kubeenv <<%EOF%
#!/bin/bash
# Setzt die Docker Umgebungsvariablen, Aufruf mittels . ./kubeenv 
export DOCKER_HOST=tcp://$(hostname -I | cut -d ' ' -f 2):2376
export DOCKER_TLS_VERIFY=1
export DOCKER_CERT_PATH=\$(pwd)/.docker
export PATH=\$PATH:\$(pwd)/bin:\$(pwd)
export KUBECONFIG=\$(pwd)/.kube/config
%EOF%

# kubectl CLI
curl -s -L https://storage.googleapis.com/kubernetes-release/release/v1.10.0/bin/windows/amd64/kubectl.exe -o $OUT/bin/kubectl.exe