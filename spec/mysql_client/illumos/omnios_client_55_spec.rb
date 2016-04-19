require 'spec_helper'

describe 'mysql_client_test::default on omnios-151014' do
  cached(:omnios_client_55) do
    ChefSpec::SoloRunner.new(
      platform: 'omnios',
      version: '151014',
      step_into: 'mysql_client'
    ) do |node|
      node.set['mysql']['version'] = '5.5'
    end.converge('mysql_client_test::default')
  end

  # Resource in mysql_client_test::default
  context 'compiling the test recipe' do
    it 'creates mysql_client[default]' do
      expect(omnios_client_55).to create_mysql_client('default')
    end
  end

  # mysql_service resource internal implementation
  context 'stepping into mysql_client[default] resource' do
    it 'installs package[default :create database/mysql-55/library]' do
      expect(omnios_client_55).to install_package('default :create database/mysql-55/library')
        .with(package_name: 'database/mysql-55/library')
    end
  end
end
