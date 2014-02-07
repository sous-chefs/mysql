def rackspace_cookbook(name, version = '>= 0.0.0', options = {})  
  cookbook(name, version, {
    git: "git@github.com:rackspace-cookbooks/#{name}.git"
  }.merge(options))
end 

site :opscode
metadata

cookbook 'openssl', '~> 1.1'
rackspace_cookbook 'rackspace_database', '~> 2.0'
rackspace_cookbook 'rackspace_postgresql', '~> 4.0', branch: 'rackspace-rebuild'
rackspace_cookbook 'rackspace_apt', '~> 3.0'
rackspace_cookbook 'rackspace_yum', '~> 4.0'
rackspace_cookbook 'rackspace_build_essential', '~> 2.0'

group :integration do
  cookbook 'minitest-handler'
  cookbook 'mysql_test', :path => 'test/cookbooks/mysql_test'
end
