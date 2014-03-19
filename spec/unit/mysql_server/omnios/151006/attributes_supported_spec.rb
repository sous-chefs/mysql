require 'spec_helper'

describe 'mysql_test::mysql_service_attribues' do
  # let(:omnios_151006_supported_run) do
  #   ChefSpec::Runner.new(
  #     :platform => 'omnios',
  #     :version => '151006'
  #     ) do |node|
  #     node.set['mysql']['service_name'] = 'omnios_151006_supported'
  #     node.set['mysql']['version'] = '5.6'
  #     node.set['mysql']['port'] = '3306'
  #   end.converge('mysql_test::mysql_service_attributes')
  # end

  # context 'when using an supported version' do
  #   it 'creates raises an error' do
  #     expect(omnios_151006_supported_run).to create_mysql_service('omnios_151006_supported').with(
  #       :version => '5.6',
  #       :package_name => 'mysql-56',
  #       :port => '3306',
  #       :data_dir => '/var/lib/mysql'
  #       )
  #   end
  # end
end
