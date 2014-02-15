# -*- mode: ruby -*-
# vi: set ft=ruby :

if ENV['VAGRANT_HOME'].nil?
    ENV['VAGRANT_HOME'] = '~/vagrant'
end

machines = {
    :'ops-puppet-db-001'        => { :memory => '360', :ip => '192.168.165.13', :box => 'centos64', :domain => 'puppet.local' },
    :'ops-puppet-dashboard-001' => { :memory => '360', :ip => '192.168.165.14', :box => 'centos64', :domain => 'puppet.local' },
    :'web-001'                  => { :memory => '360', :ip => '192.168.165.15', :box => 'centos64', :domain => 'puppet.local' },
}

master = {
    :'puppet1'               => { :cpus => '2', :memory => '1024', :ip => '192.168.165.10', :box => 'centos64', :domain => 'puppet.local' },
    :'ops-puppet-ca-001'     => { :cpus => '2', :memory => '1024', :ip => '192.168.165.11', :box => 'centos64', :domain => 'puppet.local' },
    :'ops-puppet-worker-001' => { :cpus => '2', :memory => '1024', :ip => '192.168.165.12', :box => 'centos64', :domain => 'puppet.local' },
}

Vagrant::Config.run("2") do |config|
    config.vbguest.auto_update = true
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = true
    config.hostmanager.ignore_private_ip = false
    config.hostmanager.include_offline = true

    master.each_pair do |name, opts|
        config.vm.define name do |n|
            vm_name = "#{name}" + "." + opts[:domain]
            n.vm.customize ["modifyvm", :id, "--cpus", opts[:cpus] ] if opts[:cpus]
            n.vm.customize ["modifyvm", :id, "--memory", opts[:memory] ] if opts[:memory]
            n.vm.network :private_network, ip: opts[:ip]
            n.vm.box  = opts[:box]
            n.vm.host_name  = vm_name
            if name == 'puppet1'
                n.hostmanager.aliases = %w(puppet.puppet.local puppet)
            else
                n.vm.provision  :shell, :inline => "cat /etc/hosts | grep puppet.puppet.local ; if [ $? == 1 ];then echo -e \"192.168.165.10\tpuppet.puppet.local\tpuppet\" >> /etc/hosts ;fi"
            end
            n.vm.synced_folder "/etc/puppet/hieradata", "~/vagrant/puppet/puppetmaster/hieradata"
            n.vm.synced_folder "/etc/puppet/files", "~/vagrant/puppet/puppetmaster/files"
            n.vm.synced_folder "/etc/puppet/templates", "~/vagrant/puppet/puppetmaster/templates"
            n.vm.provision  :shell, :inline => "rpm -qa | grep puppetlabs-release 1>/dev/null ; if [ $? == 1 ];then rpm -i http://yum.puppetlabs.com/el/6/products/x86_64/puppetlabs-release-6-7.noarch.rpm && yum install -y puppet facter;fi"
            n.vm.provision  :shell, :inline => "rpm -qa | grep git 1>/dev/null ; if [ $? == 1 ];then yum install -y git;fi"
            n.vm.provision  :shell, :inline => "if [ ! -d /etc/puppet ];then mkdir /etc/puppet;fi; cp /etc/puppet/files/fileserver.conf /etc/puppet/files/hiera.yaml /etc/puppet"
            n.vm.provision  :shell, :inline => "test -d /etc/puppet/environments ; if [ $? == 1 ];then mkdir -p /etc/puppet/environments/{testing,production} && ln -s /etc/puppet/hieradata /etc/puppet/environments/production && ln -s /etc/puppet/hieradata /etc/puppet/environments/testing ;fi"
            n.vm.provision  :puppet do  |puppet|
                puppet.manifests_path = "~/vagrant/puppet/puppetmaster/manifests"
                puppet.manifest_file  = "puppetmaster_centos_setup.pp"
                puppet.module_path    = "~/vagrant/puppet/puppetmaster/modules"
                puppet.pp_path        = "/etc/puppet"
            end
            n.vm.provision :shell, :inline => "chown -R puppet:puppet /var/lib/puppet/reports"
        end
    end

    machines.each_pair do |name, opts|
        config.vm.define name do |n|
            vm_name = "#{name}" + "." + opts[:domain]
            n.vm.customize ["modifyvm", :id, "--memory", opts[:memory] ] if opts[:memory]
            n.vm.network :private_network, ip: opts[:ip]
            n.vm.box  = opts[:box]
            n.vm.host_name  = vm_name
            n.vm.provision  :shell, :inline => "cat /etc/hosts | grep puppet.puppet.local ; if [ $? == 1 ];then echo -e \"192.168.165.10\tpuppet.puppet.local\tpuppet\" >> /etc/hosts ;fi"
            n.vm.provision  :shell, :inline => "rpm -qa | grep puppetlabs-release 1>/dev/null ; if [ $? == 1 ];then rpm -i http://yum.puppetlabs.com/el/6/products/x86_64/puppetlabs-release-6-7.noarch.rpm && yum install -y puppet facter;fi"
            n.vm.provision  :shell, :inline => "echo -e \"#!/bin/bash\nexport FACTERLIB=/vagrant/facter\n\" > /etc/profile.d/facter.sh"
            n.vm.provision  :puppet_server do  |puppet|
                puppet.puppet_server = "puppet.puppet.local"
                puppet.puppet_node   = vm_name
                puppet.options       = "--report true"
            end
        end
    end
end
