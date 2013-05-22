# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  config.vm.box = "quantal64"

  config.vm.network :private_network, ip: "192.168.50.33"
  config.vm.network :forwarded_port, guest: 8080, host: 8080

  config.vm.provider :virtualbox do |vb, vb_config|
    vb.customize [ "modifyvm", :id, "--memory", 1024, "--cpus", "2" ]
    vb_config.vm.box_url = "https://github.com/downloads/roderik/VagrantQuantal64Box/quantal64.box"
  end

  config.vm.provider :lxc do |lxc, lxc_config|
    lxc_config.vm.box_url = "http://dl.dropbox.com/u/13510779/lxc-quantal-amd64-2013-05-08.box"
  end

  config.vm.provision :puppet do |puppet|
    puppet.module_path    = "modules"
    puppet.manifests_path = "."
    puppet.manifest_file  = "site.pp"
    puppet.options << [ '--verbose', '--debug' ]
  end
end
