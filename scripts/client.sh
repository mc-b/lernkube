#!/bin/bash
#
# 	Aufbereitung Client Scripts und Programme.
#

sudo apt-get install -q 2 -y dos2unix

# Dashboard
cat >/vagrant/`hostname`/dashboard.bat <<%EOF%
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
unix2dos /vagrant/`hostname`/dashboard.bat

# dockerps.bat	
cat >/vagrant/`hostname`/dockerps.bat <<%EOF%
REM Setzt die Docker Umgebungsvariablen und startet PowerShell 
cd /d %~d0%~p0
set DOCKER_HOST=tcp://$(hostname -I | cut -d ' ' -f 2):2376
set DOCKER_TLS_VERIFY=1
set DOCKER_CERT_PATH=%~d0%~p0.docker
set PATH=%~d0%~p0bin;~d0%~p0git\\bin;%~d0%~p0git\\mingw64\\bin;%~d0%~p0git\\usr\\bin;%PATH%
set KUBECONFIG=%~d0%~p0.kube\\config
powershell.exe      
%EOF%
unix2dos /vagrant/`hostname`/dockerps.bat

# dockersh.bat	
cat >/vagrant/`hostname`/dockersh.bat <<%EOF%
REM Setzt die Docker Umgebungsvariablen und startet Git/Bash 
cd /d %~d0%~p0
set DOCKER_HOST=tcp://$(hostname -I | cut -d ' ' -f 2):2376
set DOCKER_TLS_VERIFY=1
set DOCKER_CERT_PATH=%~d0%~p0.docker
set PATH=%PATH%;%~d0%~p0bin
set KUBECONFIG=%~d0%~p0.kube\\config
start bash.exe   
%EOF%
unix2dos /vagrant/`hostname`/dockersh.bat	

# dockerenv	
cat >/vagrant/`hostname`/dockerenv <<%EOF%
#!/bin/bash
# Setzt die Docker Umgebungsvariablen, Aufruf mittels . ./dockerenv 
export DOCKER_HOST=tcp://$(hostname -I | cut -d ' ' -f 2):2376
export DOCKER_TLS_VERIFY=1
export DOCKER_CERT_PATH=\$(pwd)/.docker
export PATH=\$PATH:\$(pwd)/bin
export KUBECONFIG=\$(pwd)/.kube/config
%EOF%

# Hilfsscripts	
cd /vagrant
cp -rp bin /vagrant/`hostname`/

# kubectl CLI
curl -s -L https://storage.googleapis.com/kubernetes-release/release/v1.10.0/bin/windows/amd64/kubectl.exe -o /vagrant/`hostname`/bin/kubectl.exe