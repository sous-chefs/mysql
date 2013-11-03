require 'spec_helper'

describe 'mysql::server' do
  let(:centos5_run) { ChefSpec::Runner.new(platform: 'centos', version: '5.9').converge(described_recipe) }
  let(:centos6_run) { ChefSpec::Runner.new(platform: 'centos', version: '6.4').converge(described_recipe) }
  let(:ubuntu_1004_run) { ChefSpec::Runner.new(platform: 'ubuntu', version: '10.04').converge(described_recipe) }
  let(:ubuntu_1204_run) { ChefSpec::Runner.new(platform: 'ubuntu', version: '10.04').converge(described_recipe) }

  it 'includes _server_rhel on centos5' do
    expect(centos5_run).to include_recipe('mysql::_server_rhel')
  end

  it 'includes _server_rhel on centos6' do
    expect(centos6_run).to include_recipe('mysql::_server_rhel')
  end

  it 'includes _server_debian on ubuntu1004' do
    expect(ubuntu_1004_run).to include_recipe('mysql::_server_debian')
  end

  it 'includes _server_debian on ubuntu1204' do
    expect(ubuntu_1204_run).to include_recipe('mysql::_server_debian')
  end
end
