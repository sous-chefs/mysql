# require 'spec_helper'

# describe 'mysql_test::mysql_service_attribues' do

#   let(:omnios_r151006c_unsupported_run) do
#     ChefSpec::Runner.new(
#       :platform => 'omnios',
#       :version => 'r151006c'
#       ) do |node|
#       node.set['mysql']['service_name'] = 'omnios_r151006c_unsupported'
#       node.set['mysql']['version'] = '4.2'
#     end.converge('mysql_test::mysql_service_attributes')
#   end

#   context 'when using an unsupported version' do
#     it 'creates raises an error' do
#       # FIXME: should raise error
#       expect(omnios_r151006c_unsupported_run).to_not raise_error
#     end

#     # FIXME delete this
#     it 'creates mysql_service[omnios_r151006c_unsupported]' do
#       expect(omnios_r151006c_unsupported_run).to create_mysql_service('omnios_r151006c_unsupported').with(
#         :version => '4.2',
#         :port => '3306',
#         :data_dir => '/var/lib/mysql'
#         )
#     end
#   end
# end
