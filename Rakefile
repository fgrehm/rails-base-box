desc 'Recreates .box file'
task :rebuild do
  unless Dir.exists?('./modules')
    sh 'librarian-puppet install'
  end
  sh 'vagrant up'
  sh 'vagrant ssh -c "sudo apt-get update && sudo apt-get upgrade -y"'
  sh 'vagrant reload' # To ensure the VM can boot properly after the upgrade

  # FROM: http://chrisyallop.com/2012/04/customising-a-vagrant-box-with-veewee/
  # Zero out the free space to save space in the final image
  sh 'sudo dd if=/dev/zero of=/EMPTY bs=1M && sudo rm -f /EMPTY'

  sh 'vagrant package --base quantal64'
end

task :default => :rebuild
