# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  config.vm.box     = "quantal64"
  config.vm.box_url = "https://github.com/downloads/roderik/VagrantQuantal64Box/quantal64.box"

  config.vm.provision :puppet do |puppet|
    puppet.module_path    = "modules"
    puppet.manifests_path = "."
    puppet.manifest_file  = "site.pp"
    puppet.options << [ '--verbose' ]
    puppet.options << ['--debug '] if ENV['DEBUG']
  end
end
