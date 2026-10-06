# -*- mode: ruby -*-
# vi: set ft=ruby :

$install_puppet = <<-PUPPET
sudo apt-get update -y
sudo apt-get install -y puppet
PUPPET

Vagrant.configure("2") do |config|

  config.vm.define :servidor do |servidor|
    servidor.vm.box = "bento/ubuntu-22.04"
    servidor.vm.network :private_network, ip: "192.168.100.3"
    servidor.vm.hostname = "servidor"
    servidor.vm.provider "virtualbox" do |vb|
      vb.memory = "6144"
      vb.cpus = 4
    end
    servidor.vm.provision "shell", path: "script.sh"
  end

  config.vm.define :cliente do |cliente|
    cliente.vm.box = "bento/ubuntu-22.04"
    cliente.vm.network :private_network, ip: "192.168.100.2"
    cliente.vm.hostname = "cliente"
    cliente.vm.provision "shell", inline: $install_puppet
    cliente.vm.provision :puppet do |puppet|
      puppet.manifests_path = "puppet/manifests"
      puppet.manifest_file = "site.pp"
      puppet.module_path = "puppet/modules"
    end
    cliente.vm.provision "shell", path: "jupyter.sh"
  end

end