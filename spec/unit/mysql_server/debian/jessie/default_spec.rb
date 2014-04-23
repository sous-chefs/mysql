require 'spec_helper'

describe 'mysql_test_default::server on debian-jessie' do
  let(:debian_jessie_default_run) do
    ChefSpec::Runner.new(
      :platform => 'debian',
      :version => 'jessie/sid'
      ) do |node|
      node.set['mysql']['service_name'] = 'debian_jessie_default'
    end.converge('mysql_test_default::server')
  end

  context 'when using default parameters' do
    it 'creates mysql_service[debian_jessie_default]' do
      expect(debian_jessie_default_run).to create_mysql_service('debian_jessie_default').with(
        :version => '5.5',
        :port => '3306',
        :data_dir => '/var/lib/mysql'
        )
    end
  end
end
