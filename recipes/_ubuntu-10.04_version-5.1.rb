# header

::Chef::Recipe.send(:include, Opscode::Mysql::Helpers)

#----
# Set up preseeding data for debian packages
#---
directory '/var/cache/local/preseeding' do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
end

template '/var/cache/local/preseeding/mysql-server.seed' do
  source 'debian-7/5.5/mysql-server.seed.erb'
  owner 'root'
  group 'root'
  mode '0600'
  notifies :run, 'execute[preseed mysql-server]', :immediately
end

execute 'preseed mysql-server' do
  command '/usr/bin/debconf-set-selections /var/cache/local/preseeding/mysql-server.seed'
  action  :nothing
end

package 'mysql-server-5.1' do
  action :install
end

#----
# Grants
#----
template '/etc/mysql_grants.sql' do
  source 'grants/grants.sql.erb'
  owner  'root'
  group  'root'
  mode   '0600'
  notifies :run, 'execute[install-grants]', :immediately
end

cmd = install_grants_cmd
execute 'install-grants' do
  command cmd
  action :nothing
end

template '/etc/mysql/debian.cnf' do
  source 'ubuntu-10.04/5.1/debian.cnf.erb'
  owner 'root'
  group 'root'
  mode '0600'
end

#----
# data_dir
#----

# DRAGONS!
# Setting up data_dir will only work on initial node converge...
# Data will NOT be moved around the filesystem when you change data_dir
# To do that, we'll need to stash the data_dir of the last chef-client
# run somewhere and read it. Implementing that will come in "The Future"

directory node['mysql']['data_dir'] do
  owner     'mysql'
  group     'mysql'
  action    :create
  recursive true
end

template '/etc/apparmor.d/usr.sbin.mysqld' do
  source 'ubuntu-10.04/5.1/usr.sbin.mysqld.erb'
  action :create
  notifies :reload, 'service[apparmor-mysql]', :immediately
  only_if { File.directory?('/etc/apparmor.d')  }
end

service 'apparmor-mysql' do
  service_name 'apparmor'
  action :nothing
  supports :reload => true
end

template '/etc/mysql/my.cnf' do
  source 'ubuntu-10.04/5.1/my.cnf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    :port => node['mysql']['port'],
    :data_dir => node['mysql']['data_dir']
    )
  notifies :run, 'bash[move mysql data to datadir]', :immediately
end

# Don't try this at home
# http://ubuntuforums.org/showthread.php?t=804126
bash 'move mysql data to datadir' do
  user 'root'
  code <<-EOH
  /usr/sbin/service mysql stop \
  && mv /var/lib/mysql/* #{node['mysql']['data_dir']} \
  && /usr/sbin/service mysql start
  EOH
  action :nothing
  only_if "[ '/var/lib/mysql' != #{node['mysql']['data_dir']} ]"
  only_if "[ `stat -c %h #{node['mysql']['data_dir']}` -eq 2 ]"
  not_if '[ `stat -c %h /var/lib/mysql/` -eq 2 ]'
end

service 'mysql' do
  provider Chef::Provider::Service::Upstart
  service_name 'mysql'
  supports     :status => true, :restart => true, :reload => true
  action       [:enable, :start]
end
