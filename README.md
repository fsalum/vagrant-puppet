Puppet environment for Vagrant
==============================

This Vagrant environment automatically install a Puppet 3 master in load balance mode, PuppetDB, Puppet Dashboard and MCollective.

Setup
-----

1. Install VirtualBox: https://www.virtualbox.org

1. Download VirtualBox Guest Additions

1. Install Vagrant: http://vagrantup.com 

1. Install Vagrant plugins

1. Install Baseboxes
Download them from [vagrant-basebox](https://github.com/fsalum/vagrant-basebox).

    ```bash
    vagrant box add 'squeeze64' squeeze64.box  
    vagrant box add 'centos63' centos63.box  
    ```

1. Install Puppet modules

    ```bash
    gem install librarian-puppet --no-ri --no-rdoc
    cd puppetmaster
    librarian-puppet install
    ```

1. Start the Puppet VM

    ```bash
    vagrant up
    ```

1. Connect to the VM. (user/password: vagrant/vagrant)

    ```bash
    ssh vagrant@puppet1.puppet.test
    sudo tail -f /var/log/daemon.log
    ```

URLs
----

Dashboard: http://puppet1.puppet.local:8080  
PuppetDB: http://puppetdb1.puppet.local:8080

Author
------

Felipe Salum <fsalum@gmail.com>
