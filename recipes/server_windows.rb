
#----

package_file = File.join(Chef::Config[:file_cache_path], node['mysql']['package_file'])

remote_file package_file do
  source node['mysql']['url']
  not_if { File.exists?(package_file) }
end

install_dir = win_friendly_path(node['mysql']['basedir'])

windows_package node['mysql']['server']['packages'].first do
  source package_file
  options "INSTALLDIR=\"#{install_dir}\""
  notifies :run, 'execute[install mysql service]', :immediately
end

def package(*args, &blk)
  windows_package(*args, &blk)
end

#----
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

#----

require 'win32/service'

ENV['PATH'] += ";#{node['mysql']['bin_dir']}"
windows_path node['mysql']['bin_dir'] do
  action :add
end

execute 'install mysql service' do
  command %Q["#{node['mysql']['bin_dir']}\\mysqld.exe" --install "#{node['mysql']['service_name']}"]
  not_if { ::Win32::Service.exists?(node['mysql']['service_name']) }
end

#----

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

#----

require 'win32/service'

windows_path node['mysql']['bin_dir'] do
  action :add
end

windows_batch 'install mysql service' do
  command "\"#{node['mysql']['bin_dir']}\\mysqld.exe\" --install #{node['mysql']['service_name']}"
  not_if  { Win32::Service.exists?(node['mysql']['service_name']) }
end

#----

src_dir = win_friendly_path("#{node['mysql']['basedir']}\\data")
target_dir = win_friendly_path(node['mysql']['data_dir'])

%w{mysql performance_schema}.each do |db|
  execute 'mysql-move-db' do
    command %Q[move "#{src_dir}\\#{db}" "#{target_dir}"]
    action :run
    not_if { File.exists?(node['mysql']['data_dir'] + '/mysql/user.frm') }
  end
end

#----

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

#----

execute 'assign-root-password' do
  command %Q["#{node['mysql']['mysqladmin_bin']}" -u root password '#{node['mysql']['server_root_password']}']
  action :run
  only_if %Q["#{node['mysql']['mysql_bin']}" -u root -e 'show databases;']
end

#----

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

#----

windows_batch 'mysql-install-privileges' do
  command "\"#{node['mysql']['mysql_bin']}\" -u root #{node['mysql']['server_root_password'].empty? ? '' : '-p' }\"#{node['mysql']['server_root_password']}\" < \"#{grants_path}\""
  action :nothing
  subscribes :run, resources("template[#{grants_path}]"), :immediately
end

service 'mysql-start' do
  service_name node['mysql']['service_name']
  action :start
end

