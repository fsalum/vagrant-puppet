# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|

config.vbguest.iso_path = "~/vagrant/VBoxGuestAdditions/VBoxGuestAdditions_4.2.4.iso"
config.vbguest.auto_update = true

  config.vm.define :puppet1 do |n|
      n.vm.customize ["modifyvm", :id, "--cpus", 2]
      n.vm.customize ["modifyvm", :id, "--memory", 1024]
      n.vm.network :hostonly, "192.168.168.9"
      n.vm.box  = "squeeze64"
      n.vm.host_name  = "puppet1.puppet.test"
      n.hosts.aliases = ["puppet.puppet.test","puppet"]
      n.vm.share_folder "hieradata", "/etc/puppet/hieradata", "~/vagrant/puppet/puppetmaster/hieradata"
      n.vm.share_folder "files", "/etc/puppet/files", "~/vagrant/puppet/puppetmaster/files"
      n.vm.share_folder "templates", "/etc/puppet/templates", "~/vagrant/puppet/puppetmaster/templates"
      n.vm.provision  :shell, :inline => "dpkg -l | grep puppetlabs-release 1>/dev/null ; if [ $? == 1 ];then wget https://apt.puppetlabs.com/puppetlabs-release-squeeze.deb && dpkg -i puppetlabs-release-squeeze.deb && apt-get update && apt-get install -y puppet facter -t puppetlabs;fi"
      n.vm.provision  :shell, :inline => "if [ ! -d /etc/puppet ];then mkdir /etc/puppet;fi; cp /etc/puppet/files/fileserver.conf /etc/puppet/files/hiera.yaml /etc/puppet"
      n.vm.provision  :puppet do  |puppet|
        puppet.manifests_path = "puppetmaster/manifests"
        puppet.manifest_file  = "puppetmaster_setup.pp"
        puppet.module_path    = "puppetmaster/modules"
        puppet.pp_path        = "/etc/puppet"
        puppet.facter         = { "domain" => "puppet.test" }
      end
      n.vm.provision :shell, :inline => "chown -R puppet:puppet /var/lib/puppet/reports"
  end

#  config.vm.define :puppet2 do |n|
#      n.vm.network :hostonly, "192.168.168.10"
#      n.vm.box  = "squeeze64"
#      n.vm.host_name  = "puppet2.puppet.test"
#      n.vm.provision  :puppet_server do  |puppet|
#        puppet.puppet_server = "puppet.puppet.test"
#        puppet.puppet_node   = "puppet2.puppet.test"
#        puppet.facter        = { "domain" => "puppet.test" }
#      end
#  end

#  config.vm.define :puppetdashboard do |n|
#      n.vm.network :hostonly, "192.168.168.11"
#      n.vm.box  = "squeeze64"
#      n.vm.host_name  = "puppetdashboard1.puppet.test"
#      n.vm.provision  :puppet_server do  |puppet|
#        puppet.puppet_server = "puppet.puppet.test"
#        puppet.puppet_node   = "puppetdashboard1.puppet.test"
#        puppet.facter        = { "domain" => "puppet.test" }
#      end
#  end

  config.vm.define :puppetdb1 do |n|
      n.vm.customize ["modifyvm", :id, "--cpus", 2]
      n.vm.customize ["modifyvm", :id, "--memory", 1024]
      n.vm.network :hostonly, "192.168.168.12"
      n.vm.box  = "squeeze64"
      n.vm.host_name  = "puppetdb1.puppet.test"
      n.vm.provision  :shell, :inline => "dpkg -l | grep puppetlabs-release 1>/dev/null ; if [ $? == 1 ];then wget https://apt.puppetlabs.com/puppetlabs-release-squeeze.deb && dpkg -i puppetlabs-release-squeeze.deb && apt-get update && apt-get install -y puppet facter -t puppetlabs;fi"
      n.vm.provision  :puppet_server do  |puppet|
        puppet.puppet_server = "puppet.puppet.test"
        puppet.puppet_node   = "puppetdb1.puppet.test"
        puppet.facter        = { "domain" => "puppet.test" }
	puppet.options       = "--report true"
      end
  end

  config.vm.define :centos63 do |n|
      n.vm.customize ["modifyvm", :id, "--memory", 360]
      n.vm.network :hostonly, "192.168.168.13"
      n.vm.box  = "centos63"
      n.vm.host_name  = "centos63.puppet.test"
      n.vm.provision  :puppet_server do  |puppet|
        puppet.puppet_server = "puppet.puppet.test"
        puppet.puppet_node   = "centos63.puppet.test"
        puppet.facter        = { "domain" => "puppet.test" }
	puppet.options       = "--report true"
      end
  end

  config.vm.define :debian6 do |n|
      n.vm.customize ["modifyvm", :id, "--memory", 360]
      n.vm.network :hostonly, "192.168.168.14"
      n.vm.box  = "squeeze64"
      n.vm.host_name  = "debian6.puppet.test"
      n.vm.provision  :shell, :inline => "dpkg -l | grep puppetlabs-release 1>/dev/null ; if [ $? == 1 ];then wget https://apt.puppetlabs.com/puppetlabs-release-squeeze.deb && dpkg -i puppetlabs-release-squeeze.deb && apt-get update && apt-get install -y puppet facter -t puppetlabs;fi"
      n.vm.provision  :puppet_server do  |puppet|
        puppet.puppet_server = "puppet.puppet.test"
        puppet.puppet_node   = "debian6.puppet.test"
        puppet.facter        = { "domain" => "puppet.test" }
	puppet.options       = "--report true"
      end
  end

end
