require 'spec_helper'

describe 'rackspace_mysql::server' do
  let(:centos6_run) do
    ChefSpec::Runner.new(platform: 'centos', version: '6.4') do |node|
      node.set['rackspace_mysql']['server_debian_password'] = 'idontlikerandompasswords'
      node.set['rackspace_mysql']['server_root_password'] = 'idontlikerandompasswords'
      node.set['rackspace_mysql']['server_repl_password'] = 'idontlikerandompasswords'
    end.converge(described_recipe)
  end
  let(:ubuntu_1204_run) do
    ChefSpec::Runner.new(platform: 'ubuntu', version: '12.04') do |node|
      node.set['rackspace_mysql']['server_debian_password'] = 'idontlikerandompasswords'
      node.set['rackspace_mysql']['server_root_password'] = 'idontlikerandompasswords'
      node.set['rackspace_mysql']['server_repl_password'] = 'idontlikerandompasswords'
    end.converge(described_recipe)
  end

  before do
    stub_command("/usr/bin/mysql -u root -e 'show databases;'").and_return(true)
  end

  it 'includes _server_rhel on centos6' do
    expect(centos6_run).to include_recipe('rackspace_mysql::_server_rhel')
  end

  it 'includes _server_debian on ubuntu1204' do
    expect(ubuntu_1204_run).to include_recipe('rackspace_mysql::_server_debian')
  end
end
