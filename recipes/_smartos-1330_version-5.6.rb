#

::Chef::Recipe.send(:include, Opscode::Mysql::Helpers)

package 'mysql-server' do
  version '5.6'
  action :install
end

directory '/opt/local/etc/mysql/conf.d/' do
  owner 'root'
  recursive true
  action :create
end

template '/opt/local/lib/svc/method/mysqld' do
  source 'smartos-1303/5.6/svc.method.mysqld.erb'
  variables(
    :data_dir => node['mysql']['data_dir']
    )
  action :create
end

directory node['mysql']['data_dir'] do
  owner     'mysql'
  group     'mysql'
  recursive true
  action    :create
end

template '/opt/local/etc/my.cnf' do
  source 'smartos-1303/5.6/my.cnf.erb'
  mode '0600'
  variables(
    :port => node['mysql']['port'],
    :data_dir => node['mysql']['data_dir']
    )
  action :create
  notifies :run, 'bash[move mysql data to datadir]'
  notifies :reload, 'service[mysql]'
end

# dragons!
bash 'move mysql data to datadir' do
  user 'root'
  code <<-EOH
  /usr/sbin/svcadm disable mysql \
  && mv /var/mysql/* #{node['mysql']['data_dir']} \
  && /usr/sbin/svcadm enable mysql
  EOH
  action :nothing
  only_if "[ '/var/mysql' != #{node['mysql']['data_dir']} ]"
  only_if "[ `stat -c %h #{node['mysql']['data_dir']}` -eq 2 ]"
  not_if '[ `stat -c %h /var/mysql/` -eq 2 ]'
end

service 'mysql' do
  supports :reload => true
  action [:start, :enable]
  notifies :run, 'execute[wait for mysql]', :immediately
end

execute 'wait for mysql' do
  command 'until [ -S /tmp/mysql.sock ] ; do sleep 1 ; done'
  action :nothing
end

cmd = assign_root_password_cmd
execute 'assign-root-password' do
  command cmd
  action :run
  only_if "mysql -u root -e 'show databases;'"
end

template '/etc/mysql_grants.sql' do
  source 'grants/grants.sql.erb'
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
