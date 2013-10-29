#require 'pry'

# command assembly
assign_root_password_cmd = '/usr/bin/mysqladmin'
assign_root_password_cmd << '- u root password '
assign_root_password_cmd << node['mysql']['server_root_password']

install_grants_cmd = '/usr/bin/mysql'
install_grants_cmd << ' -u root '
if ! node['mysql']['server_root_password'].empty? then
  install_grants_cmd << ' -p '
  install_grants_cmd << node['mysql']['server_root_password']
end
install_grants_cmd << ' < /etc/mysql_grants.sql'

#----

group 'mysql' do
  action :create
end

user 'mysql' do
  comment 'MySQL Server'
  gid     'mysql'
  home    '/var/lib/mysql'
  shell   '/sbin/nologin'
  system  true
end

node['mysql']['server']['packages'].each do |name|
  package name do
    action   :install
  end
end

#----

node['mysql']['server']['directories'].each do |key,value|
  directory value do
    owner     'mysql' 
    group     'mysql'
    action    :create
    recursive true
  end
end

#----

template 'initial-my.cnf' do
  path "/etc/my.cnf"
  source 'my.cnf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, 'service[mysql]', :delayed
end

#----

execute '/usr/bin/mysql_install_db' do
  action :run
  creates '/var/lib/mysql/user.frm'
end

service 'mysql' do
  service_name 'mysqld'
  supports     :status => true, :restart => true, :reload => true
  action       :enable
end

template 'final-my.cnf' do
  path "/etc/my.cnf"
  source 'my.cnf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :reload, 'service[mysql]', :immediately
end

#----

execute 'assign-root-password' do
  command assign_root_password_cmd
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

#----

execute 'install-grants' do
  command install_grants_cmd
  action :nothing
end

service 'mysql-start' do
  service_name 'mysqld'
  action :start
end

