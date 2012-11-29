node vagrant inherits basenode {

  host { 'puppet host':
    ensure       => present,
    name         => 'puppet.puppet.test',
    host_aliases => ['puppet'],
    ip           => '192.168.168.9',
  }

}

node 'puppet1.puppet.test' inherits vagrant {

  include puppet_master

  # work-around for vagrant only because VeeWee install Rubygems in a different directory for the basebox
  #  file { '/var/lib/gems/1.8':
  #  ensure => link,
  #  target => '/usr/lib/ruby/gems/1.8',
  #  force  => true,
  #}

}

node 'puppet2.puppet.test' inherits vagrant {

  include puppet_master
  include puppet_slave

  # work-around for vagrant only because VeeWee install Rubygems in a different directory for the basebox
  #  file { '/var/lib/gems/1.8':
  #  ensure => link,
  #  target => '/usr/lib/ruby/gems/1.8',
  #  force  => true,
  #}

}

node 'puppetdb1.puppet.test' inherits vagrant {

  include puppet_db

}

node 'debian6.puppet.test' inherits vagrant {

  #class { newrelic:
  #  newrelic_license_key        => '2234567891234567891234567891234567891234',
  #  newrelic_php                => true,
  #  newrelic_php_package_ensure => 'latest',
  #  newrelic_php_service_ensure => 'running',
  #  newrelic_php_conf_appname   => 'Your PHP Application',
  #  stage                       => pre,
  #}

}

node 'centos63.puppet.test' inherits vagrant {

  #  class { newrelic:
  #  newrelic_license_key        => hiera('newrelic::newrelic_license_key'),
  #  newrelic_php                => hiera('newrelic::newrelic_php'),
  #  newrelic_php_package_ensure => hiera('newrelic::newrelic_php_package_ensure'),
  #  newrelic_php_service_ensure => hiera('newrelic::newrelic_php_service_ensure'),
  #  newrelic_php_conf_appname   => hiera('newrelic::newrelic_php_conf_appname'),
  #}

}
