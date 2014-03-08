# helper functions
# rewrite library to not need this?
::Chef::Recipe.send(:include, Opscode::Mysql::Helpers)

# non-attribute variables
base_dir = '/opt/mysql55'
run_dir = '/var/run/mysql'
pid_file = '/var/run/mysql/mysql.pid'
socket_file = '/tmp/mysql.sock'

# software
package 'database/mysql-55' do
  action :install
  version '5.5.31'
end

# directories
directory "#{base_dir}/etc/mysql/conf.d/" do
  owner 'mysql'
  mode '0750'
  recursive true
  action :create
end

directory run_dir do
  owner 'mysql'
  mode '0755'
  action :create
  recursive true
end

directory node['mysql']['data_dir'] do
  owner 'mysql'
  mode '0750'
  action :create
end

template "#{base_dir}/etc/my.cnf" do
  source 'omnios-r151006c/5.5/my.cnf.erb'
  owner 'mysql'
  mode '0600'
  variables(
    :base_dir => base_dir,
    :data_dir => node['mysql']['data_dir'],
    :pid_file => pid_file,
    :socket_file => socket_file,
    :port => node['mysql']['port']
    )
  action :create
  #  notifies :run, 'bash[move mysql data to datadir]', :immediately
  notifies :restart, 'service[mysql]'
end

# dragons!
bash 'move mysql data to datadir' do
  user 'root'
  code <<-EOH
  /usr/sbin/svcadm disable mysql \
  && mv /var/mysql/* #{node['mysql']['data_dir']}
  EOH
  action :nothing
  only_if "[ '/var/lib/mysql' != #{node['mysql']['data_dir']} ]"
  only_if "[ `stat -c %h #{node['mysql']['data_dir']}` -eq 2 ]"
  not_if '[ `stat -c %h /var/lib/mysql/` -eq 2 ]'
end

execute 'initialize mysql database' do
  command "#{base_dir}/scripts/mysql_install_db --basedir=#{base_dir}"
  creates "#{node['mysql']['data_dir']}/mysql/user.frm"
end

# service
template '/lib/svc/method/mysqld' do
  source 'omnios-r151006c/5.5/svc.method.mysqld.erb'
  mode '0555'
  variables(
    :base_dir => base_dir,
    :data_dir => node['mysql']['data_dir'],
    :pid_file => pid_file
    )
  action :create
end

template '/tmp/mysql.xml' do
  source 'omnios-r151006c/5.5/mysql.xml.erb'
  owner 'root'
  mode '0644'
  action :create
  notifies :run, 'execute[import mysql manifest]', :immediately
end

execute 'import mysql manifest' do
  command 'svccfg import /tmp/mysql.xml'
  action :nothing
end

service 'mysql' do
  supports :restart => true
  action [:start, :enable]
  notifies :run, 'execute[wait for mysql]', :immediately
end

execute 'wait for mysql' do
  command 'until [ -S /tmp/mysql.sock ] ; do sleep 1 ; done'
  timeout 10
end

# grants
cmd = assign_root_password_cmd
execute 'assign-root-password' do
  command cmd
  action :run
  only_if "#{base_dir}/bin/mysql -u root -e 'show databases;'"
end

template "#{base_dir}/etc/mysql_grants.sql" do
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
