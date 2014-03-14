require 'spec_helper'

describe 'mysql_test::mysql_service_attribues' do

  let(:omnios_r151006c_unsupported_run) do
    ChefSpec::Runner.new(
      :platform => 'omnios',
      :version => 'r151006c'
      ) do |node|
      node.set['mysql']['service_name'] = 'omnios_r151006c_unsupported'
      node.set['mysql']['version'] = '4.2'
    end.converge('mysql_test::mysql_service_attributes')
  end

  context 'when using an unsupported version' do
    it 'creates raises an error' do
      expect(omnios_r151006c_unsupported_run).to raise_error
    end
  end
end
