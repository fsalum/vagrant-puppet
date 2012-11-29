# Setting up a puppet master via 'puppet apply'
# Run: puppet apply puppetmaster_setup.pp

package { 'facter':
  ensure  => latest,
}

package { 'lsb-release':
  ensure  => installed,
  require => Package['facter'],
}

package { 'apache2':
  ensure => installed,
}

service { 'apache2':
  ensure     => running,
  enable     => true,
  hasrestart => true,
  hasstatus  => true,
  require    => Package['apache2'],
}

file { '/etc/apt/sources.list.d/puppetlabs.list':
  path    => '/etc/apt/sources.list.d/puppetlabs.list',
  content => "# puppetlabs\ndeb http://apt.puppetlabs.com squeeze main\n",
  notify  => Exec['import puppetlabs apt key'],
  require => Package['lsb-release'],
}

exec { 'import puppetlabs apt key':
  path      => '/bin:/usr/bin',
  command   => 'gpg --keyserver pgp.mit.edu --recv-keys 4BD6EC30 && gpg --export --armor 4BD6EC30 | apt-key add - && apt-get update',
  user      => 'root',
  group     => 'root',
  unless    => 'apt-key list | grep 4BD6EC30',
  logoutput => on_failure,
  require   => File['/etc/apt/sources.list.d/puppetlabs.list'],
}

package { 'puppet':
  ensure  => latest,
  require => Exec['import puppetlabs apt key'],
  before  => [ Ini_setting['puppet_default'], Ini_setting['puppet_server'], Ini_setting['puppet_ca_server'], Class['puppetmaster'] ],
}

service { 'puppet':
  ensure     => running,
  enable     => true,
  hasrestart => true,
  hasstatus  => true,
  require    => Package['puppetmaster-passenger'],
}

ini_setting { 'puppet_server':
  ensure  => present,
  path    => '/etc/puppet/puppet.conf',
  section => 'main',
  setting => 'server',
  value   => hiera('puppet_server'),
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
  puppetmaster_service_ensure => stopped,
  puppetmaster_service_enable => 'false',
  puppetmaster_report         => 'true',
  puppetmaster_autosign       => 'true',
  puppetmaster_modulepath     => '$confdir/modules:$confdir/modules-0',
}

package { 'puppetmaster-passenger':
  ensure  => installed,
  require => [ Ini_setting['puppet_server'], Class['puppetmaster'], Exec['import puppetlabs apt key'] ],
}

## Vagrant Part
if $domain == 'puppet.test' and $hostname == 'puppet1' {
  host { 'puppet host':
    ensure       => present,
    name         => $fqdn,
    host_aliases => [ hiera('puppet_server'), $hostname, 'puppet' ],
    ip           => '127.0.1.1',
  }
}
