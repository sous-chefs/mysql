require 'spec_helper'

describe 'mysql_test::server' do

  let(:mysql_service_run) do
    ChefSpec::Runner.new.converge('mysql_test::server')
  end

  context 'when using default parameters' do
    it 'creates mysql_service[default]' do
      expect(mysql_service_run).to create_mysql_service('default').with(
        :version => nil,
        :port => '3306',
        :data_dir => '/var/lib/mysql'
        )
    end
  end
end
