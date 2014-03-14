require 'spec_helper'

describe 'mysql_test::mysql_service_attribues' do

  let(:omnios_r151006c_default_run) do
    ChefSpec::Runner.new(
      :platform => 'omnios',
      :version => 'r151006c'
      ) do |node|
      node.set['mysql']['service_name'] = 'omnios_r151006c_default'
    end.converge('mysql_test::mysql_service_attributes')
  end

  context 'when using default parameters' do
    it 'creates mysql_service[omnios_r151006c_default]' do
#      binding.pry
      expect(omnios_r151006c_default_run).to create_mysql_service('omnios_r151006c_default').with(
#        :version => '5.6',
#        :package_name => 'mysql-65',
        :port => '3306',
        :data_dir => '/var/lib/mysql',
        )
    end
  end
end
