# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'ipaddr'
require 'yaml'

x = YAML.load_file('config.yaml')
puts "Config: #{x.inspect}\n\n"

Vagrant.configure(2) do |config|

   # Ubuntu 16.04 - Ubuntu 18.x gibt Probleme mit dind.
   config.vm.box = "ubuntu/xenial64"

   # resize hd, need a plugin vagrant-disksize, see https://github.com/sprotheroe/vagrant-disksize
   config.disksize.size = '40GB'
   
   # Gemeinsames Datenverzeichnis fuer Kubernetes Master und workers
   config.vm.synced_folder "data", "/data"
  
   # default router 
   config.vm.provision "shell",
	run: "always",
	path: "scripts/defaultrouter.sh", args: x.fetch('net').fetch('default_router')     
    	
   # Docker Provisioner
   config.vm.provision "docker" do |d|
   end  	   

   # Worker Node(s)
   worker_ip = IPAddr.new(x.fetch('ip').fetch('worker'))
   (1..x.fetch('worker').fetch('count')).each do |i|
    c = x.fetch('worker')
    hostname = "worker-%02d" % i
    config.vm.define hostname do |worker|
           
      # Virtualbox Feintuning
      worker.vm.provider "virtualbox" do |v|
        v.cpus = c.fetch('cpus')
        v.memory = c.fetch('memory')
        v.name = hostname
      end
      if x["use_dhcp"] == true
  		worker.vm.network "public_network", use_dhcp_assigned_default_route: true
      else
        worker.vm.network x.fetch('net').fetch('network_type'), ip: IPAddr.new(worker_ip.to_i + i - 1, Socket::AF_INET).to_s
      end
      worker.vm.hostname = hostname
      
      # Installation
      worker.vm.provision "shell", path: "scripts/k8sbase.sh", args: [ x.fetch('k8s').fetch('version') ]
      worker.vm.provision "shell", path: "scripts/sshworker.sh"
      worker.vm.provision "shell", path: "scripts/cleanup.sh"
    end
   end
  
   # Master Node(s)
   _ip = IPAddr.new(x.fetch('ip').fetch('master'))
   (1..x.fetch('master').fetch('count')).each do |i|
    c = x.fetch('master')
    hostname = "master-%02d" % i

    config.vm.define hostname do |master|
      c = x.fetch('master')
      
      # Virtualbox Feintuning
      master.vm.provider :virtualbox do |v|
        v.cpus = c.fetch('cpus')
        v.memory = c.fetch('memory')
        v.name = hostname
      end
      if x["use_dhcp"] == true
        master.vm.network "public_network", use_dhcp_assigned_default_route: true
      else
      	master.vm.network x.fetch('net').fetch('network_type'), ip: IPAddr.new(_ip.to_i + i - 1, Socket::AF_INET).to_s
      end
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
      master.vm.provision "shell", path: "scripts/sshmaster.sh"
      master.vm.provision "shell", path: "scripts/cleanup.sh"
    
   end
  end
  
end
