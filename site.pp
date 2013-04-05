Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/'] }
#Exec['apt-get update'] -> Package <| |>

#exec { 'apt-get update': }

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
  'curl', 'imagemagick', 'htop', 'exuberant-ctags', 'tmux',
  'libtcmalloc-minimal4', 'vim-nox', 'libv8-dev', 'libsqlite3-dev',
  'libqt4-dev', 'graphviz']:
}

##################################
# Timezone
file {
  "/etc/localtime": ensure => "/usr/share/zoneinfo/Brazil/East";
  "/etc/timezone":  content => "America/Sao_Paulo\n"
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

wget::fetch { "rake-completion":
  source      => "https://raw.github.com/calebthompson/dotfiles/master/rake/completion.sh",
  destination => "/home/vagrant/completion_scripts/rake",
  timeout     => 0,
  verbose     => false,
  require     => File['/home/vagrant/completion_scripts']
}

line {
  'source-rake-completion':
    file    => "/home/vagrant/.bashrc",
    line    => "source /home/vagrant/completion_scripts/rake",
    require => Wget::Fetch['rake-completion'];

  'migrate-alias':
    file => '/home/vagrant/.bashrc',
    line => 'alias migrate="rake db:migrate && RAILS_ENV=test rake db:migrate"';

  'rollback-alias':
    file => '/home/vagrant/.bashrc',
    line => 'alias rollback="rake db:rollback && RAILS_ENV=test rake db:rollback"';
}


##################################
# NodeJS
include nodejs

package { ['coffee-script', 'istanbul']:
  ensure   => present,
  provider => 'npm',
  require  => Class['nodejs']
}

##################################
# Heroku Toolbelt
exec {
  'wget -qO- https://toolbelt.heroku.com/install-ubuntu.sh | sh':
    creates => '/usr/local/heroku/bin/heroku'
}

##################################
# RUBY

$default_ruby = '2.0.0-p0'

file {
  '/home/vagrant/.gemrc':
    content => "
:verbose: true
gem: --no-ri --no-rdoc
:update_sources: true
:sources:
- http://gems.rubyforge.org
- http://gems.github.com
:backtrace: false
:bulk_threshold: 1000
:benchmark: false
"
}

rbenv::install { 'vagrant': }

rbenv::plugin::rubybuild { 'vagrant': }

rbenv::plugin::rbenvvars { 'vagrant':
  require => Rbenv::Install['vagrant']
}

rbenv::compile { $default_ruby:
  user   => 'vagrant',
  global => true
}

rbenv::gem { ['foreman', 'rubygems-bundler', 'tmuxinator', 'lol_dba']:
  user   => 'vagrant',
  ruby   => $default_ruby,
  require => Rbenv::Compile[$default_ruby]
}

exec { 'gem regenerate_binstubs"':
  unless  => 'gem list | grep -q rubygems-bundler',
  path    => "/home/vagrant/.rbenv/bin:/home/vagrant/.rbenv/versions/${default_ruby}/bin:/bin:/usr/bin",
  user    => 'vagrant',
  require => Rbenv::Gem['rubygems-bundler']
}

##################################
# PhantomJS
exec { 'install-phantomjs':
  command => 'curl http://phantomjs.googlecode.com/files/phantomjs-1.8.1-linux-x86_64.tar.bz2 | sudo tar xjfv - &&
              sudo ln -s /usr/local/share/phantomjs-1.8.1-linux-x86_64/bin/phantomjs /usr/local/bin/phantomjs',
  cwd     => '/usr/local/share',
  creates => '/usr/local/bin/phantomjs'
}

##################################
# Memcached
class { 'memcached':
  max_memory => 25,
  user       => 'root'
}

##################################
# PostgreSQL
package { 'libpq-dev': }
class { 'postgresql::server':
 acl   => ['host all all 127.0.0.1/32 trust', ],
}
exec {
  'vagrant-postgres-user':
    command => 'sudo -u postgres createuser --superuser vagrant 2>/dev/null',
    unless  => 'sudo -u postgres -- psql -c "\du" 2>/dev/null | grep -q vagrant',
    require => Class['postgresql::server'];
}

##################################
# Redis
class { 'redis': redis_max_memory => '10mb' }
exec  {
  'update-rc.d -f redis_6379 defaults 98 02':
    creates => '/etc/rc0.d/K02redis_6379',
    require => Class['redis']
}
