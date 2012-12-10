class basenode_repo($stage=pre) {

  case $::operatingsystem {
    'Debian','Ubuntu': {

      package { 'lsb-release':
        ensure => installed,
        notify => File['/etc/apt/sources.list.d/puppetlabs.list'],
      }

      case $::lsbdistcodename {
        'lenny': {
          apt::source { 'backports':
            location   => 'http://archive.debian.org/debian-backports',
            repos      => "$::{lsbdistcodename} main",
          }
        }
        default: { }
      }

      file { '/etc/apt/sources.list.d/puppetlabs.list':
        path    => '/etc/apt/sources.list.d/puppetlabs.list',
        content => "# puppetlabs\ndeb http://apt.puppetlabs.com $::lsbdistcodename main\n",
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

    }
    'RedHat','CentOS': {
      package { 'puppetlabs-release-6-6.noarch':
        ensure   => present,
        source   => 'http://yum.puppetlabs.com/el/6/products/i386/puppetlabs-release-6-6.noarch.rpm',
        provider => rpm,
      }
    }
    default: {
        fail("Operating System ${::operatingsystem} not supported")
    }
  }
}
