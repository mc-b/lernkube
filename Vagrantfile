# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'ipaddr'
require 'yaml'

x = YAML.load_file('config.yaml')
puts "Config: #{x.inspect}\n\n"
$private_nic_type = x.fetch('net').fetch('private_nic_type')

Vagrant.configure(2) do |config|

   # resize hd, need a plugin vagrant-disksize, see https://github.com/sprotheroe/vagrant-disksize
   config.disksize.size = '40GB'
   
   # Gemeinsames Datenverzeichnis fuer Kubernetes Master und workers
   config.vm.synced_folder "data", "/data"
    	
   # Docker Provisioner
   config.vm.provision "docker" do |d|
   end  	   

	# Master Node(s)
  _ip = IPAddr.new(x.fetch('ip').fetch('master'))
  (1..x.fetch('master').fetch('count')).each do |i|
    c = x.fetch('master')
    hostname = "master-%02d" % i

    config.vm.define hostname do |master|
      c = x.fetch('master')
      master.vm.box= "ubuntu/bionic64"
      
      # Virtualbox Feintuning
      master.vm.provider :virtualbox do |v|
        v.cpus = c.fetch('cpus')
        v.memory = c.fetch('memory')
        v.name = hostname
      end
      master.vm.network x.fetch('net').fetch('network_type'), ip: IPAddr.new(_ip.to_i + i - 1, Socket::AF_INET).to_s, nic_type: $private_nic_type
      master.vm.hostname = hostname
      
	  # Ports laut config.yaml (addons.ports) 
	  for p in x.fetch('addons').fetch('ports')
		  master.vm.network :forwarded_port, guest: p, host: p, auto_correct: true
	  end       
      
      # Installation
      master.vm.provision "shell", path: "scripts/docker.sh", args: [ IPAddr.new(_ip.to_i + i - 1, Socket::AF_INET).to_s ]
      master.vm.provision "shell", path: "scripts/k8sbase.sh", args: [ x.fetch('k8s').fetch('version') ]
      master.vm.provision "shell", path: "scripts/k8smaster.sh"
      master.vm.provision "shell", path: "scripts/k8saddons.sh"
      master.vm.provision "shell", path: "scripts/repositories.sh", args: x.fetch('addons').fetch('git')
      master.vm.provision "shell", path: "scripts/client.sh"
    
   end
  end

  # Worker Node(s)
  worker_ip = IPAddr.new(x.fetch('ip').fetch('worker'))
  (1..x.fetch('worker').fetch('count')).each do |i|
    c = x.fetch('worker')
    hostname = "worker-%02d" % i
    config.vm.define hostname do |worker|
      worker.vm.box   = "ubuntu/bionic64"
           
      # Virtualbox Feintuning
      worker.vm.provider "virtualbox" do |v|
        v.cpus = c.fetch('cpus')
        v.memory = c.fetch('memory')
        v.name = hostname
      end
      worker.vm.network x.fetch('net').fetch('network_type'), ip: IPAddr.new(worker_ip.to_i + i - 1, Socket::AF_INET).to_s, nic_type: $private_nic_type
      worker.vm.hostname = hostname
      
      # Installation
      worker.vm.provision "shell", path: "scripts/k8sbase.sh", args: [ x.fetch('k8s').fetch('version') ]
    end
  end

end
