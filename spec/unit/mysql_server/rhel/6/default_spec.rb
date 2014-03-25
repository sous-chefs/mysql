require 'spec_helper'

describe 'mysql_test_default::server on centos-6.4' do
  let(:centos_6_4_default_run) do
    ChefSpec::Runner.new(
      :platform => 'centos',
      :version => '6.4'
      ) do |node|
      node.set['mysql']['service_name'] = 'centos_6_4_default'
    end.converge('mysql_test_default::server')
  end

  context 'when using default parameters' do
    it 'creates mysql_service[centos_6_4_default]' do
      expect(centos_6_4_default_run).to create_mysql_service('centos_6_4_default').with(
        :version => '5.1',
        :port => '3306',
        :data_dir => '/var/lib/mysql'
        )
    end
  end
end
