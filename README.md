# Vagrant 1.2+ base box for working with Rails

Features:

* [rbenv](https://github.com/sstephenson/rbenv/) + Ruby 2.0.0-p195
* [rubygems-bundler](https://github.com/mpapis/rubygems-bundler)
* [Memcached](http://memcached.org/)
* [Redis](http://redis.io/)
* [Node.js](http://nodejs.org/) (for the asset pipeline)
* [heroku toolbelt](https://toolbelt.heroku.com/)
* [PhantomJS](http://phantomjs.org/)
* [Rake tasks completion](https://raw.github.com/calebthompson/dotfiles/master/rake/completion.sh)

## Building the box

```terminal
gem install librarian-puppet
rake rebuild
```

By default it will create a box for the default Vagrant provider set from
`VAGRANT_DEFAULT_PROVIDER` or VirtualBox which is Vagrant's default. In case
you want to build the box for a different provider, you can prepend `PROVIDER=lxc`
to `rake rebuild`.

This will output a box file to the project root that you can add to vagrant with
`vagrant box add`.

Please note that it takes ~20 minutes to rebuild the VM on my laptop using
a 15mb connection, so go grab a coffee while it runs ;)

I keep the latest releases on a public folder at my dropbox account, feel free to
use it:

```terminal
# For VirtualBox:
vagrant box add quantal64-rails http://dl.dropbox.com/u/13510779/quantal64-rails-2013-02-18.box
# For LXC:
vagrant box add quantal64-rails SOON
```
