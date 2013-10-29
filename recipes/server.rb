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

if platform_family?('debian')
  include_recipe "mysql::sever_debian"
end

if platform_family?('windows')
  include_recipe "mysql::server:windows"
end

unless platform_family?('mac_os_x')
  [
    File.dirname(node['mysql']['pid_file']),
    File.dirname(node['mysql']['tunable']['slow_query_log']),
    node['mysql']['conf_dir'],
    node['mysql']['confd_dir'],
    node['mysql']['log_dir'],
    node['mysql']['data_dir']
  ].each do |path|
    directory path do
      owner     'mysql' unless platform?('windows')
      group     'mysql' unless platform?('windows')
      action    :create
      recursive true
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

  template 'initial-my.cnf' do
    path "#{node['mysql']['conf_dir']}/my.cnf"
    source 'my.cnf.erb'
    owner 'root' unless platform? 'windows'
    group node['mysql']['root_group'] unless platform?('windows')
    mode '0644'
    case node['mysql']['reload_action']
    when 'restart'
      notifies :restart, 'service[mysql]', :delayed
    when 'reload'
      notifies :reload, 'service[mysql]', :delayed
    else
      Chef::Log.info "my.cnf updated but mysql.reload_action is #{node['mysql']['reload_action']}. No action taken."
    end
    variables :skip_federated => skip_federated
  end
end

if platform_family?('windows')

end

# Homebrew has its own way to do databases
if platform_family?('mac_os_x')
  execute 'mysql-install-db' do
    command     "mysql_install_db --verbose --user=`whoami` --basedir=\"$(brew --prefix mysql)\" --datadir=#{node['mysql']['data_dir']} --tmpdir=/tmp"
    environment('TMPDIR' => nil)
    action      :run
    creates     "#{node['mysql']['data_dir']}/mysql"
  end

  # set the root password for situations that don't support pre-seeding.
  # (eg. platforms other than debian/ubuntu & drop-in mysql replacements)
  execute 'assign-root-password mac_os_x' do
    command %Q["#{node['mysql']['mysqladmin_bin']}" -u root password '#{node['mysql']['server_root_password']}']
    action :run
    only_if %Q["#{node['mysql']['mysql_bin']}" -u root -e 'show databases;']
  end
else

  # The installer brings its own databases with him, so we might move them
  if platform_family?(%w{windows})
    src_dir = win_friendly_path("#{node['mysql']['basedir']}\\data")
    target_dir = win_friendly_path(node['mysql']['data_dir'])

    %w{mysql performance_schema}.each do |db|
      execute 'mysql-move-db' do
        command %Q[move "#{src_dir}\\#{db}" "#{target_dir}"]
        action :run
        not_if { File.exists?(node['mysql']['data_dir'] + '/mysql/user.frm') }
      end
    end
  end

  execute 'mysql-install-db' do
    command 'mysql_install_db'
    action :run
    not_if { File.exists?(node['mysql']['data_dir'] + '/mysql/user.frm') }
  end

  service 'mysql' do
    service_name node['mysql']['service_name']
    provider     Chef::Provider::Service::Upstart if node['mysql']['use_upstart']
    supports     :status => true, :restart => true, :reload => true
    action       :enable
  end

  unless platform_family?('mac_os_x')
  template 'final-my.cnf' do
    path "#{node['mysql']['conf_dir']}/my.cnf"
    source 'my.cnf.erb'
    owner 'root' unless platform? 'windows'
    group node['mysql']['root_group'] unless platform? 'windows'
    mode '0644'
    case node['mysql']['reload_action']
    when 'restart'
      notifies :restart, 'service[mysql]', :immediately
    when 'reload'
      notifies :reload, 'service[mysql]', :immediately
    else
      Chef::Log.info "my.cnf updated but mysql.reload_action is #{node['mysql']['reload_action']}. No action taken."
    end
    variables :skip_federated => skip_federated unless platform? 'windows'
  end

  # set the root password for situations that don't support pre-seeding.
  # (eg. platforms other than debian/ubuntu & drop-in mysql replacements)
  unless platform_family?('debian')

  end
    
    grants_path = node['mysql']['grants_path']
    
    begin
    resources("template[#{grants_path}]")
  rescue
    Chef::Log.info('Could not find previously defined grants.sql resource')
    template grants_path do
        source 'grants.sql.erb'
        owner  'root' unless platform_family? 'windows'
        group  node['mysql']['root_group'] unless platform_family? 'windows'
        mode   '0600'
        action :create
      end
  end
    
    if platform_family?('windows')
    
  end
    
    service 'mysql-start' do
      service_name node['mysql']['service_name']
      action :start
    end
    
