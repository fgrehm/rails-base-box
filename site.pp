Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/'] }

# From http://projects.puppetlabs.com/projects/1/wiki/Simple_Text_Patterns
define line($file, $line, $ensure = 'present') {
  case $ensure {
    default : { err ( "unknown ensure value ${ensure}" ) }
    present: {
      exec { "/bin/echo '${line}' >> '${file}'":
        unless => "/bin/grep -qFx '${line}' '${file}'"
      }
    }
    absent: {
      exec { "/bin/grep -vFx '${line}' '${file}' | /usr/bin/tee '${file}' > /dev/null 2>&1":
        onlyif => "/bin/grep -qFx '${line}' '${file}'"
      }
    }
  }
}

##################################
# Misc packages
package { [
  'curl', 'imagemagick', 'htop', 'exuberant-ctags', 'tmux', 'libtcmalloc-minimal4',
  'vim-nox', 'libsqlite3-dev', 'graphviz', 'wget']:
}

##################################
# Common ground for completions
file { '/home/vagrant/completion_scripts':
  ensure => directory,
  owner  => 'vagrant',
  group  => 'vagrant'
}

##################################
# Ruby / Rails goodies

exec {
  'download-rake-completion':
    command => 'wget https://raw.github.com/calebthompson/dotfiles/master/rake/completion.sh',
    creates => '/home/vagrant/completion_scripts/rake',
    cwd     => '/home/vagrant/completion_scripts',
    user    => 'vagrant',
    require => File['/home/vagrant/completion_scripts'];
}

line {
  'source-rake-completion':
    file    => "/home/vagrant/.bashrc",
    line    => "source /home/vagrant/completion_scripts/rake",
    require => Exec['download-rake-completion'];

  'migrate-alias':
    file => '/home/vagrant/.bashrc',
    line => 'alias migrate="rake db:migrate && RAILS_ENV=test rake db:migrate"';

  'rollback-alias':
    file => '/home/vagrant/.bashrc',
    line => 'alias rollback="rake db:rollback && RAILS_ENV=test rake db:rollback"';
}

##################################
# Heroku Toolbelt
exec {
  'wget -qO- https://toolbelt.heroku.com/install-ubuntu.sh | sh':
    creates => '/usr/local/heroku/bin/heroku'
}
