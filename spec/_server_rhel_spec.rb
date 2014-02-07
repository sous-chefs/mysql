require 'spec_helper'

describe 'rackspace_mysql::_server_rhel.rb' do
  let(:centos6_run) { ChefSpec::Runner.new(platform: 'centos', version: '6.4').converge(described_recipe) }
  let(:ubuntu_1204_run) { ChefSpec::Runner.new(platform: 'ubuntu', version: '12.04').converge(described_recipe) }
end
