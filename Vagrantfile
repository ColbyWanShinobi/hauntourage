# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  #config.vbguest.auto_update = false
  config.vm.define "hauntourage"
  config.vm.box = "ubuntu/jammy64"
  config.vm.network "private_network", ip: '192.168.56.187'
  config.vm.synced_folder ".", "/opt/hauntourage"
  config.ssh.insert_key = false
  config.vm.provision :shell, path: "vagrant-provision.sh"
  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--ioapic", "on"]
    v.customize ["modifyvm", :id, "--memory", "1024"]
    v.customize ["modifyvm", :id, "--cpus", "1"]
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    v.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/shared", "1"]
    v.gui = false
  end
end
