# interface
# data_dir = '/var/lib/mysql'
data_dir = '/data'
port = '3306'

::Chef::Recipe.send(:include, Opscode::Mysql::Helpers)

# implementation

group 'mysql' do
  gid '27'
  action :create
end

user 'mysql' do
  uid '27'
  group 'mysql'
  action :create
end

package 'mysql51-mysql-server' do
  action :install
end

directory data_dir do
  owner     'mysql'
  group     'mysql'
  action    :create
  recursive true
end

template '/opt/rh/mysql51/root/etc/my.cnf.erb' do
  source 'centos-5/5.1/my.cnf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    :port => port,
    :data_dir => data_dir
    )
end

service 'mysql51-mysqld' do
  action [:start, :enable]
end

cmd = assign_root_password_cmd
execute 'assign-root-password' do
  command cmd
  action :run
  only_if "/usr/bin/mysql -u root -e 'show databases;'"
end

template '/etc/mysql_grants.sql' do
  source 'grants/grants.sql.erb'
  owner  'root'
  group  'root'
  mode   '0600'
  action :create
  notifies :run, 'execute[install-grants]'
end

cmd = install_grants_cmd
execute 'install-grants' do
  command cmd
  action :nothing
end
