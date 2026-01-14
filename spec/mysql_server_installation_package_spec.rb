require 'spec_helper'

describe 'test::installation_server' do
  let(:installation_server_package_almalinux_8) { ChefSpec::ServerRunner.new(platform: 'almalinux', version: '8') }
  let(:installation_server_package_almalinux_9) { ChefSpec::ServerRunner.new(platform: 'almalinux', version: '9') }
  let(:installation_server_package_fedora) { ChefSpec::ServerRunner.new(platform: 'fedora') }
  let(:installation_server_package_ubuntu_2204) { ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '22.04') }
  let(:installation_server_package_ubuntu_2404) { ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '24.04') }

  context 'using almalinux 8' do
    it 'installs mysql_server_installation_package[default] when version is 8.0' do
      installation_server_package_almalinux_8.node.default['mysql_test']['version'] = '8.0'
      installation_server_package_almalinux_8.converge(described_recipe)
      expect(installation_server_package_almalinux_8).to install_mysql_server_installation_package('default').with(
        version: '8.0',
        package_name: 'mysql-community-server'
      )
    end
  end

  context 'using almalinux 9' do
    it 'installs mysql_server_installation_package[default] when version is 8.0' do
      installation_server_package_almalinux_9.node.default['mysql_test']['version'] = '8.0'
      installation_server_package_almalinux_9.converge(described_recipe)
      expect(installation_server_package_almalinux_9).to install_mysql_server_installation_package('default').with(
        version: '8.0',
        package_name: 'mysql-community-server'
      )
    end

    it 'installs mysql_server_installation_package[default] when version is 8.4' do
      installation_server_package_almalinux_9.node.default['mysql_test']['version'] = '8.4'
      installation_server_package_almalinux_9.converge(described_recipe)
      expect(installation_server_package_almalinux_9).to install_mysql_server_installation_package('default').with(
        version: '8.4',
        package_name: 'mysql-community-server'
      )
    end
  end

  context 'using fedora' do
    it 'installs mysql_server_installation_package[default] when version is 8.0' do
      installation_server_package_fedora.node.default['mysql_test']['version'] = '8.0'
      installation_server_package_fedora.converge(described_recipe)
      expect(installation_server_package_fedora).to install_mysql_server_installation_package('default').with(
        version: '8.0',
        package_name: 'mysql-community-server'
      )
    end

    it 'installs mysql_server_installation_package[default] when version is 8.4' do
      installation_server_package_fedora.node.default['mysql_test']['version'] = '8.4'
      installation_server_package_fedora.converge(described_recipe)
      expect(installation_server_package_fedora).to install_mysql_server_installation_package('default').with(
        version: '8.4',
        package_name: 'mysql-community-server'
      )
    end
  end

  context 'using ubuntu 22.04' do
    it 'installs mysql_server_installation_package[default] when version is 8.0' do
      installation_server_package_ubuntu_2204.node.default['mysql_test']['version'] = '8.0'
      installation_server_package_ubuntu_2204.converge(described_recipe)
      expect(installation_server_package_ubuntu_2204).to install_mysql_server_installation_package('default').with(
        version: '8.0',
        package_name: 'mysql-server-8.0'
      )
    end
  end

  context 'using ubuntu 24.04' do
    it 'installs mysql_server_installation_package[default] when version is 8.0' do
      installation_server_package_ubuntu_2404.node.default['mysql_test']['version'] = '8.0'
      installation_server_package_ubuntu_2404.converge(described_recipe)
      expect(installation_server_package_ubuntu_2404).to install_mysql_server_installation_package('default').with(
        version: '8.0',
        package_name: 'mysql-server-8.0'
      )
    end
  end
end
