# Setting up a puppet master via 'puppet apply'
# Run: puppet apply puppetmaster_centos_setup.pp

$puppet_server = hiera('puppet_server')

package { 'epel-release':
  ensure   => present,
  source   => 'http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm',
  provider => rpm,
}

package { 'facter':
  ensure  => latest,
}

package { 'redhat-lsb':
  ensure  => installed,
  require => Package['facter'],
}

class { 'apache':
  purge_configs => false,
  manage_user   => false,
  manage_group  => false,
}

class { [ 'apache::mod::passenger',
          'apache::mod::proxy',
          'apache::mod::proxy_balancer',
          'apache::mod::proxy_http',
          'apache::mod::ssl',
          'apache::mod::headers',
]:
  require => [ Ini_setting['puppet_server'], Ini_setting['puppet_dns_alt_names'], Class['puppetmaster'] ],
}

package { 'puppet':
  ensure  => latest,
  before  => [ Ini_setting['puppet_default'], Ini_setting['puppet_server'], Ini_setting['puppet_dns_alt_names'], Ini_setting['puppet_ca_server'], Class['puppetmaster'] ],
}

service { 'puppet':
  ensure     => running,
  enable     => true,
  hasrestart => true,
  hasstatus  => true,
  require    => Class['apache::mod::passenger'],
}

ini_setting { 'puppet_server':
  ensure  => present,
  path    => '/etc/puppet/puppet.conf',
  section => 'main',
  setting => 'server',
  value   => hiera('puppet_server'),
}

ini_setting { 'puppet_dns_alt_names':
  ensure  => present,
  path    => '/etc/puppet/puppet.conf',
  section => 'main',
  setting => 'dns_alt_names',
  value   => "${puppet_server},puppet,${::fqdn}",
}

ini_setting { 'puppet_ca_server':
  ensure  => present,
  path    => '/etc/puppet/puppet.conf',
  section => 'main',
  setting => 'ca_server',
  value   => hiera('puppet_server'),
}

ini_setting { 'puppet_default':
  ensure            => present,
  path              => '/etc/default/puppet',
  section           => '',
  setting           => 'START',
  value             => 'yes',
  key_val_separator => '=',
}

class { 'puppetmaster':
  puppetmaster_service_ensure => running,
  puppetmaster_service_enable => 'false',
  puppetmaster_report         => 'true',
  puppetmaster_autosign       => 'true',
  puppetmaster_modulepath     => '$confdir/environments/$environment/modules:$confdir/modules:$confdir/modules-0',
}

#class { 'passenger':
#  require => [ Ini_setting['puppet_server'], Ini_setting['puppet_dns_alt_names'], Class['puppetmaster'] ],
#}

## Vagrant Part
if ($domain =~ /test/ and $hostname =~ /ops-puppet-ca|puppet1/) {
  host { 'puppet host':
    ensure       => present,
    name         => $fqdn,
    host_aliases => [ hiera('puppet_server'), $hostname, 'puppet' ],
    ip           => '127.0.1.1',
  }
}
