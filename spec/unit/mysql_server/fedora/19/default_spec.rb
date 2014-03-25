require 'spec_helper'

describe 'mysql_test::mysql_service_attribues' do
  let(:fedora_19_default_run) do
    ChefSpec::Runner.new(
      :platform => 'fedora',
      :version => '19'
      ) do |node|
      node.set['mysql']['service_name'] = 'fedora_19_default'
    end.converge('mysql_test::server')
  end

  context 'when using default parameters' do
    it 'creates mysql_service[fedora_19_default]' do
      expect(fedora_19_default_run).to create_mysql_service('fedora_19_default').with(
        :version => '5.5',
        :port => '3306',
        :data_dir => '/var/lib/mysql'
        )
    end
  end
end
