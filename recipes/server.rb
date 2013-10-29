#
# Cookbook Name:: mysql
# Recipe:: default
#
# Copyright 2008-2013, Opscode, Inc.
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

::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

include_recipe 'mysql::client'

if Chef::Config[:solo]
  missing_attrs = %w[
    server_debian_password
    server_root_password
    server_repl_password
  ].select { |attr| node['mysql'][attr].nil? }.map { |attr| %Q{node['mysql']['#{attr}']} }

  unless missing_attrs.empty?
    Chef::Application.fatal! "You must set #{missing_attrs.join(', ')} in chef-solo mode." \
    " For more information, see https://github.com/opscode-cookbooks/mysql#chef-solo-note"
  end
else
  # generate all passwords
  node.set_unless['mysql']['server_debian_password'] = secure_password
  node.set_unless['mysql']['server_root_password']   = secure_password
  node.set_unless['mysql']['server_repl_password']   = secure_password
  node.save
end

# go time

if platform_family?('rhel')
  include_recipe "mysql::server_rhel"
end

if platform_family?('debian')
  include_recipe "mysql::sever_debian"
end

if platform_family?('mac_os_x')
  include_recipe "mysql::server_mac_os_x"
end

if platform_family?('windows')
  include_recipe "mysql::server_windows"
end
