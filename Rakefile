desc 'Recreates .box file'
task :rebuild do
  unless Dir.exists?('./modules')
    sh 'librarian-puppet install'
  end
  sh 'vagrant up'
  sh 'vagrant ssh -c "sudo apt-get update && sudo apt-get upgrade -y"'
  sh 'vagrant reload' # To ensure the VM can boot properly after the upgrade
  sh 'vagrant package'
end

task :default => :rebuild
