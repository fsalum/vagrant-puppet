class puppet_master {

  file { '/etc/puppet/hiera.yaml':
    path    => '/etc/puppet/hiera.yaml',
    source  => 'puppet:///files/hiera.yaml',
    owner   => root,
    group   => root,
    mode    => '0644',
  }

  file { '/etc/puppet/fileserver.conf':
    path    => '/etc/puppet/fileserver.conf',
    source  => 'puppet:///files/fileserver.conf',
    owner   => root,
    group   => root,
    mode    => '0644',
  }

ini_setting { 'puppet_ca_server':
  ensure  => present,
  path    => '/etc/puppet/puppet.conf',
  section => 'main',
  setting => 'ca_server',
  value   => hiera('puppet_server'),
  require => Package['puppet'],
}

  class { 'puppetdb::master::config':
    puppetdb_server => hiera('puppetdb_server'),
    restart_puppet  => false,
  }

  class {'dashboard':
    dashboard_ensure          => 'present',
    dashboard_user            => 'www-data',
    dashboard_group           => 'www-data',
    dashboard_password        => 'password',
    dashboard_db              => 'dashboard_prod',
    dashboard_charset         => 'utf8',
    dashboard_site            => hiera('puppet_server'),
    dashboard_port            => '8080',
    mysql_root_pw             => '',
    passenger                 => true,
    num_delayed_job_workers   => 3,
  }

  class { 'puppetmaster':
    puppetmaster_server               => hiera('puppet_server'),
    puppetmaster_certname             => hiera('puppet_server'),
    puppetmaster_service_ensure       => 'stopped',
    puppetmaster_service_enable       => 'false',
    puppetmaster_report               => 'true',
    puppetmaster_autosign             => 'true',
    puppetmaster_reports              => 'store,http',
    puppetmaster_reporturl            => hiera('puppet_reporturl'),
    puppetmaster_modulepath           => '$confdir/modules:$confdir/modules-0',
  }

package { 'puppetmaster-passenger':
  ensure  => installed,
  require => [ Ini_setting['puppet_server'], Class['puppetmaster'], Exec['import puppetlabs apt key'] ],
}

  # work-around if you don't manage the file via puppet the puppetlabs-apache module purge the sites-enabled content
  #file { '/etc/apache2/sites-enabled/puppetmaster':
  #  ensure => link,
  #  target => '/etc/apache2/sites-enabled/puppetmaster',
  #}

  # Puppetmaster Passenger using SSL
  ini_setting { 'puppet_ssl_client_header':
    ensure            => present,
    path              => '/etc/puppet/puppet.conf',
    section           => 'master',
    setting           => 'ssl_client_header',
    value             => 'HTTP_X_SSL_SUBJECT',
  }

  apache::mod { 'proxy_http': }
  apache::mod { 'proxy_balancer': }
  apache::mod { 'proxy': }

  # Puppetmaster Loabalancer
  $puppet_ips = hiera_hash('puppetmaster_ips')
  $puppet_server = hiera('puppet_server')
  file { '/etc/apache2/sites-enabled/puppetmaster_balancer':
    path    => '/etc/apache2/sites-enabled/puppetmaster_balancer',
    content => template('etc/apache2/sites-available/puppetmaster_balancer.erb'),
    owner   => root,
    group   => root,
    notify  => Service['httpd'],
    require => [ Package['puppetmaster-passenger'], Class['puppetmaster'], Ini_setting['puppet_ssl_client_header'] ],
  }

  # Puppetmaster Loabalancer Worker
  file { '/etc/apache2/sites-enabled/puppetmaster_worker':
    path    => '/etc/apache2/sites-enabled/puppetmaster_worker',
    source  => 'puppet:///files/etc/apache2/sites-available/puppetmaster_worker',
    owner   => root,
    group   => root,
    notify  => Service['httpd'],
    require => [ Package['puppetmaster-passenger'], Class['puppetmaster'], Ini_setting['puppet_ssl_client_header'] ],
  }

  # Puppetmaster Loabalancer Certificate Authority
  file { '/etc/apache2/sites-enabled/puppetmaster_ca':
    path    => '/etc/apache2/sites-enabled/puppetmaster_ca',
    source  => 'puppet:///files/etc/apache2/sites-available/puppetmaster_ca',
    owner   => root,
    group   => root,
    notify  => Service['httpd'],
    require => [ Package['puppetmaster-passenger'], Class['puppetmaster'], Ini_setting['puppet_ssl_client_header'] ],
  }

  class { 'java':
    distribution => 'jdk',
    version      => 'present',
  }

  class { 'activemq':
    webconsole              => true,
    stomp_user              => hiera('activemq::stomp_user'),
    stomp_passwd            => hiera('activemq::stomp_passwd'),
    stomp_admin             => hiera('activemq::stomp_admin'),
    stomp_adminpw           => hiera('activemq::stomp_adminpw'),
    activemq_mem_min        => hiera('activemq::activemq_mem_min'),
    activemq_mem_max        => hiera('activemq::activemq_mem_max'),
  }

}
