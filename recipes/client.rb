#
# Cookbook Name:: rackspace_mysql
# Recipe:: client
#
# Copyright 2008-2013, Opscode, Inc.
# Copyright 2014, Rackspace, US Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Include Opscode helper in Recipe class to get access
# to debian_before_squeeze? and ubuntu_before_lucid?
::Chef::Recipe.send(:include, Opscode::Mysql::Helpers)

include_recipe 'rackspace_apt'

node['rackspace_mysql']['client']['packages'].each do |name|
  package name
end

template '/root/.my.cnf' do
  cookbook node['rackspace_mysql']['templates']['user_mycnf']
  source 'user-my.cnf.erb'
  owner 'root'
  group 'root'
  mode '0600'
  variables(
    user: node['rackspace_mysql']['config']['user_mycnf']['user'],
    pass: node['rackspace_mysql']['config']['user_mycnf']['pass']
  )
  only_if { node['rackspace_mysql']['install_root_my_cnf'] }
end
