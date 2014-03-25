require 'spec_helper'

describe 'mysql_test_default::server on omnios-151006' do
  let(:omnios_151006_default_run) do
    ChefSpec::Runner.new(
      :platform => 'omnios',
      :version => '151006'
      ) do |node|
      node.set['mysql']['service_name'] = 'omnios_151006_default'
    end.converge('mysql_test_default::server')
  end

  context 'when using default parameters' do
    it 'creates mysql_service[omnios_151006_default]' do
      expect(omnios_151006_default_run).to create_mysql_service('omnios_151006_default').with(
        :version => '5.5',
        :port => '3306',
        :data_dir => '/var/lib/mysql'
        )
    end
  end
end
