require 'spec_helper'

describe 'mysql_test_default::server on smartos-5.11' do
  let(:smartos_13_4_0_default_run) do
    ChefSpec::Runner.new(
      :platform => 'smartos',
      :version => '5.11' # Do this for now until Ohai can identify SmartMachines
      ) do |node|
      node.set['mysql']['service_name'] = 'smartos_13_4_0_default'
    end.converge('mysql_test_default::server')
  end

  context 'when using default parameters' do
    it 'creates mysql_service[smartos_13_4_0_default]' do
      expect(smartos_13_4_0_default_run).to create_mysql_service('smartos_13_4_0_default').with(
        :version => '5.5',
        :port => '3306',
        :package_name => 'mysql-server',
        :data_dir => '/opt/local/lib/mysql'
        )
    end
  end
end
