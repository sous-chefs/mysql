require 'spec_helper'

describe 'mysql_test::mysql_service_attribues' do

  let(:mysql_service_run) do
    ChefSpec::Runner.new.converge('mysql_test::mysql_service_attributes')
  end

  context 'when using default parameters' do
    it 'creates mysql_service[default]' do
      expect(mysql_service_run).to create_mysql_service('default').with(
        :version => nil,
        :package_name => nil,
        :port => '3306',
        :data_dir => '/var/lib/mysql'
        )
    end
  end
end
