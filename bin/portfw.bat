REM Microservices Port weiterleiten an eigenen Server (als Administrator ausfuehren)
cd /d %~d0%~p0
set DOCKER_HOST=tcp://192.168.60.100:2376
set DOCKER_TLS_VERIFY=1
set DOCKER_CERT_PATH=%~d0%~p0.docker
set PATH=%PATH%;%~d0%~p0bin
set KUBECONFIG=%~d0%~p0.kube\config

start powershell -ep RemoteSigned -file %~d0%~p0\bin\portfwps.ps1 lernkube