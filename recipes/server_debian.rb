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
node['mysql']['server']['packages'].each do |name|
  package name do
    action :install
  end
end

node['mysql']['server']['directories'].each do |key, value|
  directory value do
    owner     'mysql'
    group     'mysql'
    action    :create
    recursive true
  end
end

directory node['mysql']['datadir'] do
  owner     'mysql'
  group     'mysql'
  action    :create
  recursive true
end

# YOU ARE HERE
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
  service_name 'mysql'
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
  service_name 'mysql'
  supports     :status => true, :restart => true, :reload => true
  action       [:enable, :start]
end
