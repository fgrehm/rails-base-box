Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/'] }
#Exec['apt-get update'] -> Package <| |>

#exec { 'apt-get update': }

##################################
# Misc packages
package { [
  'curl', 'imagemagick', 'htop', 'exuberant-ctags', 'tmux',
  'libtcmalloc-minimal4', 'nodejs', 'vim-nox', 'libv8-dev', 'libsqlite3-dev',
  'libqt4-dev']:
}

##################################
# Timezone
file {
  "/etc/localtime": ensure => "/usr/share/zoneinfo/Brazil/East";
  "/etc/timezone":  content => "America/Sao_Paulo\n"
}

##################################
# Heroku Toolbelt

exec {
  'wget -qO- https://toolbelt.heroku.com/install-ubuntu.sh | sh':
    creates => '/usr/local/heroku/bin/heroku'
}

##################################
# RUBY

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

file {
  '/home/vagrant/.rbenv/vars':
    content => "
RUBY_GC_MALLOC_LIMIT=60000000
RUBY_FREE_MIN=200000
LD_PRELOAD=/usr/lib/libtcmalloc_minimal.so.4.1.0
",
    require => Rbenv::Install['vagrant']
}

rbenv::compile { '1.9.3-p327-falcon':
  user   => 'vagrant',
  source => 'https://raw.github.com/gist/1688857/2-1.9.3-p327-patched.sh',
  global => true
}

rbenv::gem { ['foreman', 'rubygems-bundler', 'tmuxinator']:
  user   => 'vagrant',
  ruby   => '1.9.3-p327-falcon',
  require => Rbenv::Compile['1.9.3-p327-falcon']
}

exec { 'gem regenerate_binstubs"':
  unless  => 'gem list | grep -q rubygems-bundler',
  path    => "/home/vagrant/.rbenv/bin:/home/vagrant/.rbenv/versions/1.9.3-p327-falcon/bin:/bin:/usr/bin",
  user    => 'vagrant',
  require => Rbenv::Gem['rubygems-bundler']
}

file {
  "/home/vagrant/.rbenv/versions/1.9.3-p327":
    ensure  => "/home/vagrant/.rbenv/versions/1.9.3-p327-falcon",
    require => Rbenv::Compile['1.9.3-p327-falcon'];
}

##################################
# PhantomJS
exec { 'install-phantomjs':
  command => 'curl http://phantomjs.googlecode.com/files/phantomjs-1.7.0-linux-x86_64.tar.bz2 | sudo tar xjfv - &&
              sudo ln -s /usr/local/share/phantomjs-1.7.0-linux-x86_64/bin/phantomjs /usr/local/bin/phantomjs',
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
