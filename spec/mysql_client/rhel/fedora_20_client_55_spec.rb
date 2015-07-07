require 'spec_helper'

describe 'mysql_client_test::default on fedora-20' do
  cached(:fedora_20_client_55) do
    ChefSpec::SoloRunner.new(
      platform: 'fedora',
      version: '20',
      step_into: 'mysql_client'
    ) do |node|
      node.set['mysql']['version'] = '5.5'
    end.converge('mysql_client_test::default')
  end

  # Resource in mysql_client_test::default
  context 'compiling the test recipe' do
    it 'creates mysql_client[default]' do
      expect(fedora_20_client_55).to create_mysql_client('default')
    end
  end

  # mysql_service resource internal implementation
  context 'stepping into mysql_client[default] resource' do
    it 'installs package[default :create community-mysql]' do
      expect(fedora_20_client_55).to install_package('default :create community-mysql')
        .with(package_name: 'community-mysql')
    end

    it 'installs package[default :create community-mysql-devel]' do
      expect(fedora_20_client_55).to install_package('default :create community-mysql-devel')
        .with(package_name: 'community-mysql-devel')
    end
  end
end
