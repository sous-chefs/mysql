require 'spec_helper'

describe 'mysql_test_default::server on debian-7.2' do
  let(:debian_7_2_default_run) do
    ChefSpec::Runner.new(
      :platform => 'debian',
      :version => '7.2'
      ) do |node|
      node.set['mysql']['service_name'] = 'debian_7_2_default'
    end.converge('mysql_test_default::server')
  end

  context 'when using default parameters' do
    it 'creates mysql_service[debian_7_2_default]' do
      expect(debian_7_2_default_run).to create_mysql_service('debian_7_2_default').with(
        :version => '5.5',
        :port => '3306',
        :data_dir => '/var/lib/mysql'
        )
    end
  end
end
