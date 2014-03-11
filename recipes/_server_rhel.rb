#
# Cookbook Name:: rackspace_mysql
# Recipe:: server_rhel
#
# Copyright 2008-2009, Opscode, Inc.
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

# require 'pry'

node['rackspace_mysql']['server']['packages'].each do |name|
  package name do
    action :install
  end
end

ruby_block 'set_mysql_version' do
  block do
    cmd = Mixlib::ShellOut.new("#{node['rackspace_mysql']['server']['mysqld_bin']} --version | awk '{print $3}' | egrep -o '^[0-9].[0-9]'")
    node.default['mysql']['version'] = cmd.run_command.stdout.to_f
    cmd.error!
  end
end


#----
node['rackspace_mysql']['server']['directories'].each do |key, value|
  directory value do
    owner     'mysql'
    group     'mysql'
    mode      '0755'
    action    :create
    recursive true
  end
end

directory node['rackspace_mysql']['data_dir'] do
  owner     'mysql'
  group     'mysql'
  action    :create
  recursive true
end

#----
template 'initial-my.cnf' do
  path '/etc/my.cnf'
  source 'my.cnf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :start, 'service[mysql-start]', :immediately
end

# hax
service 'mysql-start' do
  service_name 'mysqld'
  action :nothing
end

execute '/usr/bin/mysql_install_db' do
  action :run
  creates '/var/lib/mysql/user.frm'
  only_if { node['platform_version'].to_i < 6 }
end

cmd = assign_root_password_cmd
execute 'assign-root-password' do
  command cmd
  action :run
  only_if "/usr/bin/mysql -u root -e 'show databases;'"
end

template '/etc/mysql_grants.sql' do
  source 'grants.sql.erb'
  owner  'root'
  group  'root'
  mode   '0600'
  action :create
  notifies :run, 'execute[install-grants]', :immediately
end

cmd = install_grants_cmd
execute 'install-grants' do
  command cmd
  action :nothing
  notifies :restart, 'service[mysql]', :immediately
end

#----
template 'final-my.cnf' do
  path '/etc/my.cnf'
  source 'my.cnf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :reload, 'service[mysql]', :immediately
end

service 'mysql' do
  service_name 'mysqld'
  supports     status: true, restart: true, reload: true
  action       [:enable, :start]
end
