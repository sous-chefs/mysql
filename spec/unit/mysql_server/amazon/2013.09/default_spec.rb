require 'spec_helper'

describe 'mysql_test_default::server on amazon-2013.09' do
  let(:amazon_2013_09_default_run) do
    ChefSpec::Runner.new(
      :platform => 'amazon',
      :version => '2013.09'
      ) do |node|
      node.set['mysql']['service_name'] = 'amazon_2013_09_default'
    end.converge('mysql_test_default::server')
  end

  context 'when using default parameters' do
    it 'creates mysql_service[amazon_2013_09_default]' do
      expect(amazon_2013_09_default_run).to create_mysql_service('amazon_2013_09_default').with(
        :version => '5.1',
        :port => '3306',
        :data_dir => '/var/lib/mysql'
        )
    end
  end
end
