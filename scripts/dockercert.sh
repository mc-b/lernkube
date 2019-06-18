#!/bin/bash
#
# 	Docker Feintuning

    set -o xtrace

    curl -s -L https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64 -o cfssljson
    curl -s -L https://pkg.cfssl.org/R1.2/cfssl_linux-amd64 -o cfssl
    sudo chmod +x cfssljson cfssl
    sudo mv cfssljson cfssl /usr/local/bin
    cd /vagrant/csr
    cfssl gencert -initca ca-csr.json | cfssljson -bare ca
    cat >docker-server-csr.json <<%EOF%
{
  "CN": "*.kubestack.io",
  "hosts": [
    "127.0.0.1",
    "$(hostname)",
    "$1",
    "$(hostname -I | cut -d ' ' -f 2)"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CH",
      "L": "Zurich",
      "O": "Docker",
      "OU": "Docker Engine",
      "ST": "ZH"
    }
  ]
}
%EOF%

    cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=server docker-server-csr.json | cfssljson -bare docker-server
    cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=client docker-client-csr.json | cfssljson -bare docker-client
    sudo cp ca.pem /etc/docker/ca.pem
    sudo mv docker-server-key.pem /etc/docker/server-key.pem
    sudo mv docker-server.pem /etc/docker/server.pem
    sudo chmod 0600 /etc/docker/*.pem
    sudo chown root:root /etc/docker/*.pem
    mkdir -p /home/vagrant/.docker
    mv ca.pem /home/vagrant/.docker/
    mv docker-client.pem /home/vagrant/.docker/cert.pem
    mv docker-client-key.pem /home/vagrant/.docker/key.pem
    chmod 0600 /home/vagrant/.docker/*.pem
    chmod 0700 /home/vagrant/.docker
    chown vagrant:vagrant /home/vagrant/.docker
    
    sudo cat > /etc/systemd/system/docker.service <<%EOF%
[Service]
Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
ExecStart=/usr/bin/dockerd --tlsverify --tlscacert=/etc/docker/ca.pem --tlscert=/etc/docker/server.pem \
--tlskey=/etc/docker/server-key.pem -H=0.0.0.0:2376 -H fd:// \
--insecure-registry=localhost:32500 --insecure-registry=localhost:32512 --insecure-registry=localhost:32513 \
--insecure-registry=$(hostname -I | cut -d ' ' -f 2):32512 --insecure-registry=$(hostname -I | cut -d ' ' -f 2):32513
ExecReload=/bin/kill -s HUP $MAINPID
LimitNOFILE=1048576
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNPROC=infinity
LimitCORE=infinity
# Uncomment TasksMax if your systemd version supports it.
# Only systemd 226 and above support this version.
TasksMax=infinity
TimeoutStartSec=0
# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes
# kill only the docker process, not all processes in the cgroup
KillMode=process
# restart the docker process if it exits prematurely
Restart=on-failure
StartLimitBurst=3
StartLimitInterval=60s

[Install]
WantedBy=multi-user.target
%EOF%

    sudo rm /vagrant/csr/*.csr /vagrant/csr/*.pem /vagrant/csr/docker-server-csr.json

    sudo systemctl daemon-reload
    sudo systemctl restart docker
