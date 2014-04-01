require 'spec_helper'

describe 'mysql_test_default::server on centos-5.8' do
  let(:centos_5_8_default_run) do
    ChefSpec::Runner.new(
      :platform => 'centos',
      :version => '5.8'
      ) do |node|
      node.set['mysql']['service_name'] = 'centos_5_8_default'
    end.converge('mysql_test_default::server')
  end

  context 'when using default parameters' do
    it 'creates mysql_service[centos_5_8_default]' do
      expect(centos_5_8_default_run).to create_mysql_service('centos_5_8_default').with(
        :version => '5.0',
        :port => '3306',
        :data_dir => '/var/lib/mysql'
        )
    end
  end
end
