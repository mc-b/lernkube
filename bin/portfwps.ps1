Set-PSDebug -Trace 1

netsh interface portproxy add v4tov4 listenaddress=localhost listenport=32100  connectaddress=$args connectport=32100
netsh interface portproxy add v4tov4 listenaddress=localhost listenport=32200  connectaddress=$args connectport=32200
netsh interface portproxy add v4tov4 listenaddress=localhost listenport=32300  connectaddress=$args connectport=32300

netsh interface portproxy add v4tov4 listenaddress=localhost listenport=32080  connectaddress=$args connectport=32080
netsh interface portproxy add v4tov4 listenaddress=localhost listenport=32090  connectaddress=$args connectport=32090
netsh interface portproxy add v4tov4 listenaddress=localhost listenport=32180  connectaddress=$args connectport=32180
netsh interface portproxy add v4tov4 listenaddress=localhost listenport=32280  connectaddress=$args connectport=32280

netsh interface portproxy add v4tov4 listenaddress=localhost listenport=30443  connectaddress=$args connectport=30443
netsh interface portproxy add v4tov4 listenaddress=localhost listenport=6443  connectaddress=$args connectport=6443

netsh interface portproxy add v4tov4 listenaddress=localhost listenport=32088  connectaddress=$args connectport=32088
netsh interface portproxy add v4tov4 listenaddress=localhost listenport=32388  connectaddress=$args connectport=32388

