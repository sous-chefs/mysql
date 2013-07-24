#
# Cookbook Name:: mysql
# Recipe:: _access_grants
#
# Copyright 2008-2011, Opscode, Inc.
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

unless platform_family?(%w{mac_os_x})
  grants_path = node['mysql']['grants_path']

  begin
    t = resources("template[#{grants_path}]")
  rescue
    Chef::Log.info("Could not find previously defined grants.sql resource")
    t = template grants_path do
      source "grants.sql.erb"
      owner "root" unless platform_family? 'windows'
      group node['mysql']['root_group'] unless platform_family? 'windows'
      mode "0600"
      action :create
    end
  end

  if platform_family? 'windows'
    windows_batch "mysql-install-privileges" do
      command "\"#{node['mysql']['mysql_bin']}\" -u root #{node['mysql']['server_root_password'].empty? ? '' : '-p' }\"#{node['mysql']['server_root_password']}\" < \"#{grants_path}\""
      action :nothing
      subscribes :run, resources("template[#{grants_path}]"), :immediately
    end
  else
    execute "mysql-install-privileges" do
      command %Q["#{node['mysql']['mysql_bin']}" -u root #{node['mysql']['server_root_password'].empty? ? '' : '-p' }"#{node['mysql']['server_root_password']}" < "#{grants_path}"]
      action :nothing
      subscribes :run, resources("template[#{grants_path}]"), :immediately
    end
  end
end
