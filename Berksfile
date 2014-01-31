def rackspace_cookbook(name, version = '>= 0.0.0', options = {})  
  cookbook(name, version, {
    git: "git@github.com:rackspace-cookbooks/#{name}.git"
  }.merge(options))
end 

site :opscode
metadata

group :integration do
  cookbook 'minitest-handler'
  cookbook 'openssl', '~> 1.1'
  cookbook 'mysql_test', :path => 'test/cookbooks/mysql_test'
  rackspace_cookbook 'rackspace_database', '~> 2.0'
  rackspace_cookbook 'rackspace_apt', '~> 3.0'
  rackspace_cookbook 'rackspace_yum', '~> 4.0'
  rackspace_cookbook 'rackspace_build_essential', '~> 2.0'
end
