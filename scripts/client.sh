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
echo "$(kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}') | grep token:)"
echo "weave - Aufruf Weave ein Werkzeug zur grafischen Visualisierung der Container"
echo ""
echo "vagrant ssh $(hostname) - Wechselt in die VM"
echo "===================================================================="
%EOF%
}

sudo apt-get install -q 2 -y dos2unix bsdtar

# wenn nur 1 Master Scripts in /vagrant ablegen
if	[ $1 -eq 1 ]
then
	sudo rm -rf /vagrant/.kube /vagrant/*.bat
	export OUT=/vagrant
else
	export OUT=/vagrant/$(hostname)
	sudo rm -rf $OUT/
    sudo mkdir -p $OUT/
    # Hilfsscripts
    sudo cp -rp /vagrant/bin $OUT/
fi
    
# Kubernetes - Externer Zugriff
cp -rp $HOME/.kube $OUT/

# Dashboard
cat >$OUT/dashboard.bat <<%EOF%
@ECHO OFF
REM Startet den Browser mit der Dashboard Startseite und den Proxy 
echo ============= Dashboard - port-forward to 8001 =====================
echo VM: $(hostname), Cluster-IP: $(hostname -I | cut -d ' ' -f 2)
echo ""
echo Dashboard, login mit:
echo $(kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}') | grep token:)
echo ====================================================================
cd /d %~d0%~p0
set PATH=%PATH%;%~d0%~p0bin
set KUBECONFIG=%~d0%~p0.kube\\config
start http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/ /B
kubectl proxy     
%EOF%
unix2dos $OUT/dashboard.bat

# Weave.bat
cat >$OUT/weave.bat <<%EOF%
@ECHO OFF
REM Startet die Weave Oberflaeche 
echo ============= Weave Scope - port-forward to 4040 ===================
echo VM: $(hostname), Cluster-IP: $(hostname -I | cut -d ' ' -f 2)
echo ====================================================================
cd /d %~d0%~p0
set PATH=%PATH%;%~d0%~p0bin
set KUBECONFIG=%~d0%~p0.kube\\config
start http://localhost:4040
kubectl port-forward -n weave $(kubectl get -n weave pod --selector=weave-scope-component=app -o jsonpath='{.items..metadata.name}') 4040 &
%EOF%
unix2dos $OUT/weave.bat

# kubeps.bat	
cat >$OUT/kubeps.bat <<%EOF%
@ECHO OFF
REM Setzt die Umgebungsvariablen und startet PowerShell 
cd /d %~d0%~p0
set PATH=%~d0%~p0bin;~d0%~p0git\\bin;%~d0%~p0git\\mingw64\\bin;%~d0%~p0git\\usr\\bin;%PATH%
set KUBECONFIG=%~d0%~p0.kube\\config
$(info)  
powershell.exe    
%EOF%
unix2dos $OUT/kubeps.bat

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

# kubesh.bat	
cat >$OUT/kubesh.bat <<%EOF%
@ECHO OFF
REM Wechselt in die VM mittels ssh 
cd /d %~d0%~p0
start vagrant ssh master-01   
%EOF%
unix2dos $OUT/kubesh.bat	

# fuer Linux alle Scripts ausfuehrbar
chmod +x $OUT/bin/*

# kubectl CLI
curl -s -L https://storage.googleapis.com/kubernetes-release/release/v1.19.2/bin/windows/amd64/kubectl.exe -o $OUT/bin/kubectl.exe
# helm CLI
( cd $OUT/bin/ && curl -s -L https://get.helm.sh/helm-v3.1.0-windows-amd64.zip | bsdtar xvf - && mv windows-amd64/helm.exe . && rm -rf windows-amd64)
