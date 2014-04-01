require 'spec_helper'

describe 'mysql_client_test::default' do
  let(:mysql_client_run) do
    ChefSpec::Runner.new.converge('mysql_client_test::default')
  end

  context 'when using default parameters' do
    it 'creates mysql_client[default]' do
      expect(mysql_client_run).to create_mysql_client('default')
    end
  end
end
