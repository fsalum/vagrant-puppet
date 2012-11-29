class puppet_slave {

  ini_setting { 'puppet_ca':
    ensure  => present,
    path    => '/etc/puppet/puppet.conf',
    section => 'master',
    setting => 'ca',
    value   => 'false',
  }

}
