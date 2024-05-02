require 'spec_helper'

describe 'test::installation_client' do
  let(:installation_client_package_centos_8) { ChefSpec::ServerRunner.new(platform: 'centos', version: '8') }
  let(:installation_client_package_fedora) { ChefSpec::ServerRunner.new(platform: 'fedora') }
  let(:installation_client_package_ubuntu_2204) { ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '18.04') }

  context 'using el8' do
    it 'installs mysql_client_installation_package[default] when version is 8.0' do
      installation_client_package_centos_8.node.default['mysql_test']['version'] = '8.0'
      installation_client_package_centos_8.converge(described_recipe)
      expect(installation_client_package_centos_8).to create_mysql_client_installation_package('default').with(
        version: '8.0',
        package_name: %w(mysql-community-client mysql-community-devel)
      )
    end
  end

  context 'using ubuntu 22.04' do
    it 'installs mysql_client_installation_package[default] when version is 8.0' do
      installation_client_package_ubuntu_2204.node.default['mysql_test']['version'] = '8.0'
      installation_client_package_ubuntu_2204.converge(described_recipe)
      expect(installation_client_package_ubuntu_2204).to create_mysql_client_installation_package('default').with(
        version: '8.0',
        package_name: ['mysql-client-8.0', 'libmysqlclient-dev']
      )
    end
  end
end
