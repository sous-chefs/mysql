require 'spec_helper'

describe 'unsupported mysql_test_custom::server on omnios-151006' do
  let(:omnios_151006_unsupported_run) do
    ChefSpec::Runner.new(
      :platform => 'omnios',
      :version => '151006'
      ) do |node|
      node.set['mysql']['service_name'] = 'omnios_151006_unsupported'
      node.set['mysql']['version'] = '4.2'
    end.converge('mysql_test_custom::server')
  end

  context 'when using an unsupported version' do
    it 'creates raises an error' do
      expect { omnios_151006_unsupported_run }.to raise_error(Chef::Exceptions::ValidationFailed)
    end
  end
end
