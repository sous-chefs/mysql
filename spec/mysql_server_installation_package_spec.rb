require 'spec_helper'

describe 'test::installation_server' do
  let(:installation_server_package_centos_8) { ChefSpec::ServerRunner.new(platform: 'centos', version: '8') }
  let(:installation_server_package_fedora) { ChefSpec::ServerRunner.new(platform: 'fedora') }
  let(:installation_server_package_ubuntu_2204) { ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '18.04') }

  context 'using el8' do
    it 'installs mysql_server_installation_package[default] when version is 8.0' do
      installation_server_package_centos_8.node.default['mysql_test']['version'] = '8.0'
      installation_server_package_centos_8.converge(described_recipe)
      expect(installation_server_package_centos_8).to install_mysql_server_installation_package('default').with(
        version: '8.0',
        package_name: 'mysql-server'
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
end
