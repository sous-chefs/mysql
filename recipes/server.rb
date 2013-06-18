#
# Cookbook Name:: mysql
# Recipe:: server
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

::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

include_recipe "mysql::client"

if Chef::Config[:solo]
  missing_attrs = %w{
    server_debian_password server_root_password server_repl_password
  }.select do |attr|
    node["mysql"][attr].nil?
  end.map { |attr| "node['mysql']['#{attr}']" }

  if !missing_attrs.empty?
    Chef::Application.fatal!([
        "You must set #{missing_attrs.join(', ')} in chef-solo mode.",
        "For more information, see https://github.com/opscode-cookbooks/mysql#chef-solo-note"
      ].join(' '))
  end
else
  # generate all passwords
  node.set_unless['mysql']['server_debian_password'] = secure_password
  node.set_unless['mysql']['server_root_password']   = secure_password
  node.set_unless['mysql']['server_repl_password']   = secure_password
  node.save
end

if platform_family?(%w{debian})
  template "#{node['mysql']['conf_dir']}/debian.cnf" do
    source "debian.cnf.erb"
    owner "root"
    group node['mysql']['root_group']
    mode "0600"
  end
end

if platform_family?('windows')
  package_file = node['mysql']['package_file']

  remote_file "#{Chef::Config[:file_cache_path]}/#{package_file}" do
    source node['mysql']['url']
    not_if { File.exists? "#{Chef::Config[:file_cache_path]}/#{package_file}" }
  end

  windows_package node['mysql']['server']['packages'].first do
    source "#{Chef::Config[:file_cache_path]}/#{package_file}"
  end

  def package(*args, &blk)
    windows_package(*args, &blk)
  end
end

node['mysql']['server']['packages'].each do |package_name|
  package package_name do
    action :install
    notifies :start, "service[mysql]", :immediately
  end
end

unless platform_family?(%w{mac_os_x})

  [File.dirname(node['mysql']['pid_file']),
    File.dirname(node['mysql']['tunable']['slow_query_log']),
    node['mysql']['conf_dir'],
    node['mysql']['confd_dir'],
    node['mysql']['log_dir'],
    node['mysql']['data_dir']].each do |directory_path|
    directory directory_path do
      owner "mysql" unless platform? 'windows'
      group "mysql" unless platform? 'windows'
      action :create
      recursive true
    end
  end

  if platform_family? 'windows'
    require 'win32/service'

    windows_path node['mysql']['bin_dir'] do
      action :add
    end

    windows_batch "install mysql service" do
      command "\"#{node['mysql']['bin_dir']}\\mysqld.exe\" --install #{node['mysql']['service_name']}"
      not_if { Win32::Service.exists?(node['mysql']['service_name']) }
    end
  end

  skip_federated = case node['platform']
                   when 'fedora', 'ubuntu', 'amazon'
                     true
                   when 'centos', 'redhat', 'scientific'
                     node['platform_version'].to_f < 6.0
                   else
                     false
                   end
end

# Homebrew has its own way to do databases
if platform_family?(%w{mac_os_x})
  execute "mysql-install-db" do
    command "mysql_install_db --verbose --user=`whoami` --basedir=\"$(brew --prefix mysql)\" --datadir=#{node['mysql']['data_dir']} --tmpdir=/tmp"
    environment('TMPDIR' => nil)
    action :run
    creates "#{node['mysql']['data_dir']}/mysql"
  end
else
  execute 'mysql-install-db' do
    command "mysql_install_db"
    action :run
    not_if { File.exists?(node['mysql']['data_dir'] + '/mysql/user.frm') }
  end

  service "mysql" do
    service_name node['mysql']['service_name']
    if node['mysql']['use_upstart']
      provider Chef::Provider::Service::Upstart
    end
    supports :status => true, :restart => true, :reload => true
    action :enable
  end
end

execute "assign-root-password" do
  command "\"#{node['mysql']['mysqladmin_bin']}\" -u root password \"#{node['mysql']['server_root_password']}\""
  action :run
  only_if "\"#{node['mysql']['mysql_bin']}\" -u root -e 'show databases;'"
end

unless platform_family?(%w{mac_os_x})
  include_recipe "mysql::_access_grants"

  template "#{node['mysql']['conf_dir']}/my.cnf" do
    source "my.cnf.erb"
    owner "root" unless platform? 'windows'
    group node['mysql']['root_group'] unless platform? 'windows'
    mode "0644"
    case node['mysql']['reload_action']
    when 'restart'
      notifies :restart, "service[mysql]", :immediately
    when 'reload'
      notifies :reload, "service[mysql]", :immediately
    else
      Chef::Log.info "my.cnf updated but mysql.reload_action is #{node['mysql']['reload_action']}. No action taken."
    end
    variables :skip_federated => skip_federated
  end

  service "mysql" do
    action :start
  end
end
