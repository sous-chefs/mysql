# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  config.vm.hostname = "rackspace-mysql.cookbook-test.rackops.local"

  # Support CentOS and Debian for base recipe coverage
  config.vm.define "centos" do |vm_cfg|
    vm_cfg.vm.box = "opscode-centos-6.4"
    vm_cfg.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-6.4_chef-provisionerless.box"
    vm_cfg.vm.network :private_network, ip: "192.168.254.133"
  end

  config.vm.define "debian" do |vm_cfg|
    vm_cfg.vm.box = "opscode-debian-7.4"
    vm_cfg.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_debian-7.4_chef-provisionerless.box"
    vm_cfg.vm.network :private_network, ip: "192.168.254.133"
  end

  # Install latest Chef
  # https://github.com/schisamo/vagrant-omnibus
  config.omnibus.chef_version = :latest #'11.8.2'

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider :virtualbox do |vb|
  #   # Don't boot with headless mode
  #   vb.gui = true
  #
  #   # Use VBoxManage to customize the VM. For example to change memory:
  #   vb.customize ["modifyvm", :id, "--memory", "1024"]
  # end
  #
  # View the documentation for the provider you're using for more
  # information on available options.

#  config.ssh.max_tries = 40
#  config.ssh.timeout   = 120

  # The path to the Berksfile to use with Vagrant Berkshelf
  # config.berkshelf.berksfile_path = "./Berksfile"

  # Enabling the Berkshelf plugin. To enable this globally, add this configuration
  # option to your ~/.vagrant.d/Vagrantfile file
  config.berkshelf.enabled = true

  # An array of symbols representing groups of cookbook described in the Vagrantfile
  # to exclusively install and copy to Vagrant's shelf.
  # config.berkshelf.only = []

  # An array of symbols representing groups of cookbook described in the Vagrantfile
  # to skip installing and copying to Vagrant's shelf.
  # config.berkshelf.except = []

  config.vm.provision :chef_solo do |chef|
    chef.json = {
      :rackspace_mysql => {
        :server_debian_password => 'TestDebianPassword',
        :server_root_password   => 'TestRootPassword',
        :server_repl_password   => 'TestReplicationPassword',
      }
    }

    chef.run_list = [
                     "recipe[rackspace_mysql::server]",
                     "recipe[rackspace_mysql::client]",
                    ]
  end
end
