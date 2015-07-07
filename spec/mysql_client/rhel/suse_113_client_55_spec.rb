require 'spec_helper'

describe 'mysql_client_test::default on suse-11.3' do
  cached(:suse_113_client_55) do
    ChefSpec::SoloRunner.new(
      platform: 'suse',
      version: '11.3',
      step_into: 'mysql_client'
    ) do |node|
      node.set['mysql']['version'] = '5.5'
    end.converge('mysql_client_test::default')
  end

  # Resource in mysql_client_test::default
  context 'compiling the test recipe' do
    it 'creates mysql_client[default]' do
      expect(suse_113_client_55).to create_mysql_client('default')
    end
  end

  # mysql_service resource internal implementation
  context 'stepping into mysql_client[default] resource' do
    it 'installs package[default :create mysql-client]' do
      expect(suse_113_client_55).to install_package('default :create mysql-client')
        .with(package_name: 'mysql-client')
    end
  end
end
