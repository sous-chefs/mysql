require 'spec_helper'

describe 'mysql_test_custom::server on omnios-151006' do
  let(:omnios_151006_supported_run) do
    ChefSpec::Runner.new(
      :platform => 'omnios',
      :version => '151006'
      ) do |node|
      node.set['mysql']['service_name'] = 'omnios_151006_supported'
      node.set['mysql']['version'] = '5.6'
      node.set['mysql']['port'] = '3308'
      node.set['mysql']['data_dir'] = '/data'
    end.converge('mysql_test_custom::server')
  end

  context 'when using an supported version' do
    it 'creates the resource with the correct parameters' do
      expect(omnios_151006_supported_run).to create_mysql_service('omnios_151006_supported').with(
        :version => '5.6',
        :package_name => 'database/mysql-56',
        :port => '3308',
        :data_dir => '/data'
        )
    end
  end
end
