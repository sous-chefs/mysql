require 'spec_helper'

describe 'mysql_client_test::default on smartos-511' do
  cached(:smartos_511_client_56) do
    ChefSpec::SoloRunner.new(
      platform: 'smartos',
      version: '5.11',
      step_into: 'mysql_client'
    ) do |node|
      node.set['mysql']['version'] = '5.6'
    end.converge('mysql_client_test::default')
  end

  # Resource in mysql_client_test::default
  context 'compiling the test recipe' do
    it 'creates mysql_client[default]' do
      expect(smartos_511_client_56).to create_mysql_client('default')
    end
  end

  # mysql_service resource internal implementation
  context 'stepping into mysql_client[default] resource' do
    it 'installs package[default :create mysql-client]' do
      expect(smartos_511_client_56).to install_package('default :create mysql-client')
        .with(
          package_name: 'mysql-client',
          version: '5.6'
        )
    end
  end
end
