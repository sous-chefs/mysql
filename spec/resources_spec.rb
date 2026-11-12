# frozen_string_literal: true

require 'spec_helper'

describe 'test::default' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '24.04') do |node|
      node.default['mysql_test']['installation'] = 'package'
    end.converge(described_recipe)
  end

  it 'requires an explicit sensitive bootstrap password and selects MySQL 8.4' do
    resource = chef_run.find_resource(:mysql_service, 'primary')
    expect(resource.version).to eq('8.4')
    expect(resource.class.properties[:initial_root_password].options[:sensitive]).to be(true)
    expect(resource.class.properties[:initial_root_password].options).not_to have_key(:default)
  end

  it 'keeps current server authentication as the default' do
    expect(chef_run.find_resource(:mysql_user, 'application').use_native_auth).to be(false)
  end

  it 'preserves array package inputs through the server installation alias' do
    expect(chef_run.find_resource(:mysql_service, 'primary').class.properties[:package_name].options[:is]).to include(Array)
    installer = Chef::Resource.resource_for_node(:mysql_server_installation, chef_run.node).new('packages')
    expect { installer.package_name(%w(mysql-community-server mysql-community-client)) }.not_to raise_error
  end

  it 'declares real service, database, account, grants and config resources' do
    expect(chef_run).to create_mysql_service('primary')
    expect(chef_run).to start_mysql_service('primary')
    expect(chef_run).to create_mysql_database('application')
    expect(chef_run).to create_mysql_user('application')
    expect(chef_run).to grant_mysql_user('application grants')
    expect(chef_run).to create_mysql_config('primary')
  end
end
