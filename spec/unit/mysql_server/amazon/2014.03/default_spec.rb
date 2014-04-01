require 'spec_helper'

describe 'mysql_test_default::server on amazon-2014.03' do
  let(:amazon_2014_03_default_run) do
    ChefSpec::Runner.new(
      :platform => 'amazon',
      :version => '2014.03'
      ) do |node|
      node.set['mysql']['service_name'] = 'amazon_2014_03_default'
    end.converge('mysql_test_default::server')
  end

  context 'when using default parameters' do
    it 'creates mysql_service[amazon_2014_03_default]' do
      expect(amazon_2014_03_default_run).to create_mysql_service('amazon_2014_03_default').with(
        :version => '5.5',
        :port => '3306',
        :data_dir => '/var/lib/mysql'
        )
    end
  end
end
