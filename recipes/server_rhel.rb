
#----

group 'mysql' do
  action :create
end

user 'mysql' do
  comment 'MySQL Server'
  gid     'mysql'
  system  true
  home    node['mysql']['data_dir']
  shell   '/sbin/nologin'
end

node['mysql']['server']['packages'].each do |name|
  package name do
    action   :install
    notifies :start, 'service[mysql]', :immediately
  end
end

#----

[
  File.dirname(node['mysql']['pid_file']),
  File.dirname(node['mysql']['tunable']['slow_query_log']),
  node['mysql']['conf_dir'],
  node['mysql']['confd_dir'],
  node['mysql']['log_dir'],
  node['mysql']['data_dir']].each do |path|
  directory path do
    owner     'mysql' 
    group     'mysql'
    action    :create
    recursive true
  end
end

#----

node['platform_version'].to_f < 6.0 ? skip_federated = false : skip_federated = true
log "DEBUG: skip_federated: #{skip_federated}"

template 'initial-my.cnf' do
  path "#{node['mysql']['conf_dir']}/my.cnf"
  source 'my.cnf.erb'
  owner 'root'
  group node['mysql']['root_group']
  mode '0644'
  notifies :restart, 'service[mysql]', :delayed
  variables :skip_federated => skip_federated
end

#----

execute 'mysql-install-db' do
  command 'mysql_install_db'
  action :run
  creates node['mysql']['data_dir'] + '/mysql/user.frm'
end

service 'mysql' do
  service_name node['mysql']['service_name']
  supports     :status => true, :restart => true, :reload => true
  action       :enable
end

template 'final-my.cnf' do
  path "#{node['mysql']['conf_dir']}/my.cnf"
  source 'my.cnf.erb'
  owner 'root'
  group node['mysql']['root_group']
  mode '0644'
  notifies :reload, 'service[mysql]', :immediately
  variables :skip_federated => skip_federated
end

#----

execute 'assign-root-password' do
  command %Q["#{node['mysql']['mysqladmin_bin']}" -u root password '#{node['mysql']['server_root_password']}']
  action :run
  only_if %Q["#{node['mysql']['mysql_bin']}" -u root -e 'show databases;']
end

template node['mysql']['grants_path'] do
  source 'grants.sql.erb'
  owner  'root'
  group  node['mysql']['root_group']
  mode   '0600'
  action :create
end

#----

execute 'mysql-install-privileges' do
  command %Q["#{node['mysql']['mysql_bin']}" -u root #{node['mysql']['server_root_password'].empty? ? '' : '-p' }"#{node['mysql']['server_root_password']}" < "#{node['mysql']['grants_path']}"]
  action :nothing
  subscribes :run, "template[#{node['mysql']['grants_path']}]", :immediately
end

service 'mysql-start' do
  service_name node['mysql']['service_name']
  action :start
end

