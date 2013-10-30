#----

directory '/var/cache/local/preseeding' do
  owner 'root'
  group node['mysql']['root_group']
  mode '0755'
  recursive true
end

execute 'preseed mysql-server' do
  command 'debconf-set-selections /var/cache/local/preseeding/mysql-server.seed'
  action  :nothing
end

template '/var/cache/local/preseeding/mysql-server.seed' do
  source 'mysql-server.seed.erb'
  owner 'root'
  group node['mysql']['root_group']
  mode '0600'
  notifies :run, 'execute[preseed mysql-server]', :immediately
end

template "#{node['mysql']['conf_dir']}/debian.cnf" do
  source 'debian.cnf.erb'
  owner 'root'
  group node['mysql']['root_group']
  mode '0600'
end

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
  owner 'root'
  group node['mysql']['root_group']
  mode '0644'
  notifies :reload, 'service[mysql]', :delayed
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
  provider     Chef::Provider::Service::Upstart if node['mysql']['use_upstart']
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
template node['mysql']['grants_path'] do
  source 'grants.sql.erb'
  owner 'root'
  group node['mysql']['root_group']
  mode '0600'
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
