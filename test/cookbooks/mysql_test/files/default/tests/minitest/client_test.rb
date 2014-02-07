require File.expand_path('../support/helpers.rb', __FILE__)

describe 'rackspace_mysql::client' do
  include Helpers::Mysql

  it 'installs the mysql client package' do
    node['rackspace_mysql']['client']['packages'].each do |package_name|
      package(package_name).must_be_installed
    end
  end
end
