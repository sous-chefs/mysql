require 'spec_helper'

describe 'test::installation_client' do
  let(:installation_client_package_centos_7) { ChefSpec::ServerRunner.new(platform: 'centos', version: '7') }
  let(:installation_client_package_centos_8) { ChefSpec::ServerRunner.new(platform: 'centos', version: '8') }
  let(:installation_client_package_fedora) { ChefSpec::ServerRunner.new(platform: 'fedora') }
  let(:installation_client_package_ubuntu_1804) { ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '18.04') }

  context 'using el7' do
    it 'installs mysql_client_installation_package[default] when version is 5.6' do
      installation_client_package_centos_7.node.default['mysql_test']['version'] = '5.6'
      installation_client_package_centos_7.converge(described_recipe)
      expect(installation_client_package_centos_7).to create_mysql_client_installation_package('default').with(
        version: '5.6',
        package_name: %w(mysql mysql-devel)
      )
    end

    it 'installs mysql_client_installation_package[default] when version is 5.7' do
      installation_client_package_centos_7.node.default['mysql_test']['version'] = '5.7'
      installation_client_package_centos_7.converge(described_recipe)
      expect(installation_client_package_centos_7).to create_mysql_client_installation_package('default').with(
        version: '5.7',
        package_name: %w(mysql mysql-devel)
      )
    end
  end

  context 'using el8' do
    it 'installs mysql_client_installation_package[default] when version is 5.7' do
      installation_client_package_centos_8.node.default['mysql_test']['version'] = '5.7'
      installation_client_package_centos_8.converge(described_recipe)
      expect(installation_client_package_centos_8).to create_mysql_client_installation_package('default').with(
        version: '5.7',
        package_name: %w(mysql-community-client mysql-community-devel)
      )
    end

    it 'installs mysql_client_installation_package[default] when version is 8.0' do
      installation_client_package_centos_8.node.default['mysql_test']['version'] = '8.0'
      installation_client_package_centos_8.converge(described_recipe)
      expect(installation_client_package_centos_8).to create_mysql_client_installation_package('default').with(
        version: '8.0',
        package_name: %w(mysql-community-client mysql-community-devel)
      )
    end
  end

  context 'using fedora' do
    it 'installs mysql_client_installation_package[default] when version is 5.7' do
      installation_client_package_fedora.node.default['mysql_test']['version'] = '5.7'
      installation_client_package_fedora.converge(described_recipe)
      expect(installation_client_package_fedora).to create_mysql_client_installation_package('default').with(
        version: '5.7',
        package_name: %w(mysql-community-client mysql-community-devel)
      )
    end
  end

  context 'using ubuntu 18.04' do
    it 'installs mysql_client_installation_package[default] when version is 5.7' do
      installation_client_package_ubuntu_1804.node.default['mysql_test']['version'] = '5.7'
      installation_client_package_ubuntu_1804.converge(described_recipe)
      expect(installation_client_package_ubuntu_1804).to create_mysql_client_installation_package('default').with(
        version: '5.7',
        package_name: ['mysql-client-5.7', 'libmysqlclient-dev']
      )
    end
  end
end
