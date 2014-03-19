require 'spec_helper'

describe 'mysql_test::mysql_service_attribtues' do
  let(:omnios_151006_unsupported_run) do
    ChefSpec::Runner.new(
      :platform => 'omnios',
      :version => '151006'
      ) do |node|
      node.set['mysql']['service_name'] = 'omnios_151006_unsupported'
      node.set['mysql']['version'] = '4.2'
      node.set['mysql']['port'] = '3306'
      node.set['mysql']['data_dir'] = '/data'
    end.converge('mysql_test::mysql_service_attributes')
  end

  context 'when using an unsupported version' do
    it 'creates raises an error' do
#      binding.pry
      expect(omnios_151006_unsupported_run).to create_mysql_service('omnios_151006_unsupported').with(
        :version => '4.2',
        :port => '3306',
        :data_dir => '/data'
        )      
    end
  end
end
