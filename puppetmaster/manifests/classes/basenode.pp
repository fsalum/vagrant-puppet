class basenode {

  package { 'curl': ensure => latest }
  package { 'strace': ensure => latest, }
  package { 'tcpdump': ensure => latest, }
  package { 'facter': ensure => latest, }
  package { 'screen': ensure => latest, }
  package { 'puppet': ensure => installed, }

  case $::operatingsystem {
    'Debian','Ubuntu': {
      package { 'git-core': ensure => latest, }
    }
    'RedHat','CentOS': {
      package { 'git': ensure => latest, }
    }
    default: {
    }
  }

  ini_setting { 'puppet_default':
    ensure            => present,
    path              => '/etc/default/puppet',
    section           => '',
    setting           => 'START',
    value             => 'yes',
    key_val_separator => '=',
  }

  ini_setting { 'puppet_report':
    ensure            => present,
    path              => '/etc/puppet/puppet.conf',
    section           => 'agent',
    setting           => 'report',
    value             => 'true',
    key_val_separator => ' = ',
  }

  ini_setting { 'puppet_server':
    ensure            => present,
    path              => '/etc/puppet/puppet.conf',
    section           => 'main',
    setting           => 'server',
    value             => hiera('puppet_server'),
    key_val_separator => ' = ',
  }

  ini_setting { 'puppet_pluginsync':
    ensure            => present,
    path              => '/etc/puppet/puppet.conf',
    section           => 'main',
    setting           => 'pluginsync',
    value             => 'true',
    key_val_separator => ' = ',
  }

  service { 'puppet':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => [ Ini_setting['puppet_pluginsync'], Ini_setting['puppet_server'], Ini_setting['puppet_report'], Ini_setting['puppet_default'] ],
  }

  class { 'mcollective':
    mc_security_psk => hiera('mcollective::mc_security_psk'),
    stomp_server    => hiera('puppet_server'),
    stomp_user      => hiera('activemq::stomp_user'),
    stomp_passwd    => hiera('activemq::stomp_passwd'),
    manage_plugins  => true,
    server          => true,
    client          => true,
  }

}
