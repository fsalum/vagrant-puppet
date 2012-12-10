Puppet environment for Vagrant
==============================

This Vagrant environment automatically install a Puppet 3 master in load balance mode, PuppetDB and Puppet Dashboard.

Setup
-----

1. Install VirtualBox: https://www.virtualbox.org

1. Download VirtualBox Guest Additions

    ```bash
    mkdir -p ~/vagrant/VBoxGuestAdditions && cd ~/vagrant/VBoxGuestAdditions
    wget http://dlc.sun.com.edgesuite.net/virtualbox/4.2.4/VBoxGuestAdditions_4.2.4.iso 
    ```

1. Install Vagrant: http://vagrantup.com 
If you are on Vagrant 1.0.5 apply this fix https://github.com/mitchellh/vagrant/issues/1169)

1. Clone the repository and install Vagrant plugins

    ```bash
    git clone git@github.com:fsalum/vagrant-puppet.git ~/vagrant/puppet
    vagrant gem install vagrant-hostmaster  
    vagrant gem install vagrant-vbguest
    ```

1. Add the Base Boxes
I'm not providing the basebox at this time, but you can find them online.  
Just use the same name as I'm listing below when adding them.

    ```bash
    vagrant box add 'squeeze64' squeeze64.box  
    vagrant box add 'centos63' centos63.box  
    ```

1. Start the Puppet VM

    ```bash
    cd ~/vagrant/puppet  
    git submodule update --init  
    vagrant up
    ```

1. Connect to the VM. (user/password: vagrant/vagrant)

    ```bash
    ssh vagrant@puppet1.puppet.test
    sudo tail -f /var/log/daemon.log
    ```

URLs
----

Dashboard: http://puppet1.puppet.test:8080  
PuppetDB: http://puppetdb1.puppet.test:8080

Author
------

Felipe Salum <fsalum@gmail.com>
