require 'spec_helper'

describe 'test::installation_server' do
  let(:installation_server_package_centos_6) { ChefSpec::ServerRunner.new(platform: 'centos', version: '6') }
  let(:installation_server_package_centos_7) { ChefSpec::ServerRunner.new(platform: 'centos', version: '7') }
  let(:installation_server_package_fedora) { ChefSpec::ServerRunner.new(platform: 'fedora', version: '31') }
  let(:installation_server_package_ubuntu_1804) { ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '18.04') }

  context 'using el6' do
    it 'installs mysql_server_installation_package[default] when version is 5.6' do
      installation_server_package_centos_6.node.default['mysql']['version'] = '5.6'
      installation_server_package_centos_6.converge(described_recipe)
      expect(installation_server_package_centos_6).to install_mysql_server_installation_package('default').with(
        version: '5.6',
        package_name: 'mysql-community-server'
      )
    end

    it 'installs mysql_server_installation_package[default] when version is 5.7' do
      installation_server_package_centos_6.node.default['mysql']['version'] = '5.7'
      installation_server_package_centos_6.converge(described_recipe)
      expect(installation_server_package_centos_6).to install_mysql_server_installation_package('default').with(
        version: '5.7',
        package_name: 'mysql-community-server'
      )
    end
  end

  context 'using el7' do
    it 'installs mysql_server_installation_package[default] when version is 5.6' do
      installation_server_package_centos_7.node.default['mysql']['version'] = '5.6'
      installation_server_package_centos_7.converge(described_recipe)
      expect(installation_server_package_centos_7).to install_mysql_server_installation_package('default').with(
        version: '5.6',
        package_name: 'mysql-community-server'
      )
    end

    it 'installs mysql_server_installation_package[default] when version is 5.7' do
      installation_server_package_centos_7.node.default['mysql']['version'] = '5.7'
      installation_server_package_centos_7.converge(described_recipe)
      expect(installation_server_package_centos_7).to install_mysql_server_installation_package('default').with(
        version: '5.7',
        package_name: 'mysql-community-server'
      )
    end
  end

  context 'using fedora' do
    it 'installs mysql_server_installation_package[default] when version is 5.6' do
      installation_server_package_fedora.node.default['mysql']['version'] = '5.6'
      installation_server_package_fedora.converge(described_recipe)
      expect(installation_server_package_fedora).to install_mysql_server_installation_package('default').with(
        version: '5.6',
        package_name: 'mysql-community-server'
      )
    end

    it 'installs mysql_server_installation_package[default] when version is 5.7' do
      installation_server_package_fedora.node.default['mysql']['version'] = '5.7'
      installation_server_package_fedora.converge(described_recipe)
      expect(installation_server_package_fedora).to install_mysql_server_installation_package('default').with(
        version: '5.7',
        package_name: 'mysql-community-server'
      )
    end
  end

  context 'using ubuntu 18.04' do
    it 'installs mysql_server_installation_package[default] when version is 5.7' do
      installation_server_package_ubuntu_1804.node.default['mysql']['version'] = '5.7'
      installation_server_package_ubuntu_1804.converge(described_recipe)
      expect(installation_server_package_ubuntu_1804).to install_mysql_server_installation_package('default').with(
        version: '5.7',
        package_name: 'mysql-server-5.7'
      )
    end
  end
end
