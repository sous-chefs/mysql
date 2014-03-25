require 'spec_helper'

describe 'mysql_test_default::server on ubuntu-10.04' do
  let(:ubuntu_10_04_default_run) do
    ChefSpec::Runner.new(
      :platform => 'ubuntu',
      :version => '10.04'
      ) do |node|
      node.set['mysql']['service_name'] = 'ubuntu_10_04_default'
    end.converge('mysql_test_default::server')
  end

  context 'when using default parameters' do
    it 'creates mysql_service[ubuntu_10_04_default]' do
      expect(ubuntu_10_04_default_run).to create_mysql_service('ubuntu_10_04_default').with(
        :version => '5.1',
        :port => '3306',
        :data_dir => '/var/lib/mysql'
        )
    end
  end
end
