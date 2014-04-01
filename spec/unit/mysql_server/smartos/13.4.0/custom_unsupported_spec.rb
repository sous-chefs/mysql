require 'spec_helper'

describe 'unsupported mysql_test_custom::server on omnios-151006' do
  let(:smartos_5_11_unsupported_run) do
    ChefSpec::Runner.new(
      :platform => 'smartos',
      :version => '5.11'
      ) do |node|
      node.set['mysql']['service_name'] = 'smartos_5_11_unsupported'
      node.set['mysql']['version'] = '4.2'
    end.converge('mysql_test_custom::server')
  end

  context 'when using an unsupported version' do
    it 'creates raises an error' do
      expect { smartos_5_11_unsupported_run }.to raise_error(Chef::Exceptions::ValidationFailed)
    end
  end
end
