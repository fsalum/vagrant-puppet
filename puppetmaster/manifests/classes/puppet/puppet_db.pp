class puppet_db {

  class { 'puppetdb::server':
    database_host      => hiera('puppetdb_server'),
    ssl_listen_address => '0.0.0.0',
  }

  class { 'puppetdb::database::postgresql':
    listen_addresses => hiera('puppetdb_server'),
  }

  ini_setting { 'puppetdb_jetty_http':
    ensure  => present,
    path    => '/etc/puppetdb/conf.d/jetty.ini',
    section => 'jetty',
    setting => 'host',
    value   => '0.0.0.0',
    require => Class['puppetdb::server::jetty_ini'],
    notify  => Service['puppetdb'],
  }

}
