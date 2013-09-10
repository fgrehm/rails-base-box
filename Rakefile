desc 'Recreates .box file'
task :rebuild do
  # TODO: Switch to bindler
  unless `vagrant plugin list`.include? 'vagrant-cachier'
    sh 'vagrant plugin install vagrant-cachier'
  end

  sh "vagrant destroy -f"

  provider = ENV['PROVIDER'] || ENV['VAGRANT_DEFAULT_PROVIDER']
  extra    = provider ? "--provider=#{provider}" : ''
  sh "vagrant up --no-provision #{extra}"
  sh 'vagrant ssh -c "sudo apt-get update && sudo apt-get upgrade -y"'
  sh 'vagrant reload'

  sh 'vagrant ssh -c "rm /home/vagrant/.rbenv/cache/*"'

  unless provider == 'lxc'
    # FROM: https://gist.github.com/3775253
    sh 'vagrant ssh -c "sudo /vagrant/purge.sh"'
  end

  # Ensure vagrant-cachier symlinks gets removed
  sh 'vagrant halt'

  provider = provider ? "#{provider}-" : ''
  require 'time'
  box_file_name = "#{provider}quantal64-rails-#{Date.today}.box"
  sh "rm -f #{box_file_name} && vagrant package --output #{box_file_name}"
end
