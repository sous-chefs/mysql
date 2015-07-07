require 'spec_helper'

describe 'mysql_client_test::default on ubuntu-10.04' do
  cached(:ubuntu_1004_client_51) do
    ChefSpec::SoloRunner.new(
      platform: 'ubuntu',
      version: '10.04',
      step_into: 'mysql_client'
    ) do |node|
      node.set['mysql']['version'] = '5.1'
    end.converge('mysql_client_test::default')
  end

  # Resource in mysql_client_test::default
  context 'compiling the test recipe' do
    it 'creates mysql_client[default]' do
      expect(ubuntu_1004_client_51).to create_mysql_client('default')
    end
  end

  # mysql_service resource internal implementation
  context 'stepping into mysql_client[default] resource' do
    it 'installs package[default :create mysql-client-5.1]' do
      expect(ubuntu_1004_client_51).to install_package('default :create mysql-client-5.1')
        .with(package_name: 'mysql-client-5.1')
    end

    it 'installs package[default :create libmysqlclient-dev]' do
      expect(ubuntu_1004_client_51).to install_package('default :create libmysqlclient-dev')
        .with(package_name: 'libmysqlclient-dev')
    end
  end
end
