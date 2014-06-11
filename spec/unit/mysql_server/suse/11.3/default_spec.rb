require 'spec_helper'

describe 'mysql_test_default::server on suse-11.3' do
  let(:suse_151006_default_run) do
    ChefSpec::Runner.new(
      :platform => 'suse',
      :version => '11.3'
      ) do |node|
      node.set['mysql']['service_name'] = 'suse_11_3_default'
    end.converge('mysql_test_default::server')
  end

  context 'when using default parameters' do
    it 'creates mysql_service[suse_11_3_default]' do
      expect(suse_151006_default_run).to create_mysql_service('suse_11_3_default').with(
        :version => '5.5',
        :port => '3306',
        :data_dir => '/var/lib/mysql'
        )
    end
  end
end
