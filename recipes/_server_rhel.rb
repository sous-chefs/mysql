# require 'pry'

node['mysql']['server']['packages'].each do |name|
  package name do
    action :install
  end
end

#----
node['mysql']['server']['directories'].each do |key, value|
  directory value do
    owner     'mysql'
    group     'mysql'
    mode      '0755'
    action    :create
    recursive true
  end
end

directory node['mysql']['data_dir'] do
  owner     'mysql'
  group     'mysql'
  action    :create
  recursive true
end

#There are probably a few ways to detect initial installation.  This should work
#unless this file (which is created below) is manually deleted at a later point.
unless File.file?('/etc/mysql_grants.sql')
  #Initial server setup, so start mysql daemon immediately
  template 'initial-my.cnf' do
    path '/etc/my.cnf'
    source 'my.cnf.erb'
    owner 'root'
    group 'root'
    mode '0644'
    notifies :start, 'service[mysql-start]', :immediately
  end
end

# hax
service 'mysql-start' do
  service_name node['mysql']['server']['service_name']
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
  notifies :restart, 'service[mysql]', :delayed
end

service 'mysql' do
  service_name node['mysql']['server']['service_name']
  supports     :status => true, :restart => true
  action       [:enable, :start]
end
