require 'spec_helper'

describe 'mysql_test_default::server on ubuntu-13.10' do
  let(:ubuntu_13_10_default_run) do
    ChefSpec::Runner.new(
      :platform => 'ubuntu',
      :version => '13.10'
      ) do |node|
      node.set['mysql']['service_name'] = 'ubuntu_13_10_default'
    end.converge('mysql_test_default::server')
  end

  context 'when using default parameters' do
    it 'creates mysql_service[ubuntu_13_10_default]' do
      expect(ubuntu_13_10_default_run).to create_mysql_service('ubuntu_13_10_default').with(
        :version => '5.5',
        :port => '3306',
        :data_dir => '/var/lib/mysql'
        )
    end
  end
end
