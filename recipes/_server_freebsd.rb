node['mysql']['server']['packages'].each do |name|
  package name do
    action   :install
    notifies :start, 'service[mysql]', :immediately
  end
end

node['mysql']['server']['directories'].each do |name, path|
  directory path do
    owner     'mysql'
    group     'mysql'
    action    :create
    recursive true
  end
end

template 'my.cnf' do
  path "#{node['mysql']['conf_dir']}/my.cnf"
  source 'my.cnf.erb'
  owner 'root'
  group node['root_group']
  mode '0644'
  notifies :restart, 'service[mysql]', :delayed
end

execute 'mysql-install-db' do
  command "mysql_install_db --basedir=#{node['mysql']['server']['basedir']}"
  action :run
  not_if { File.exists?(node['mysql']['data_dir'] + '/mysql/user.frm') }
end

service 'mysql' do
  service_name node['mysql']['server']['service_name']
  supports     :status => true, :restart => true, :reload => false
  action       :enable
end

execute 'assign-root-password' do
  command %Q["#{node['mysql']['server']['mysqladmin_bin']}" -u root password '#{node['mysql']['server_root_password']}']
  action :run
  only_if %Q["#{node['mysql']['server']['mysql_bin']}" -u root -e 'show databases;']
end

grants_path = node['mysql']['server']['grants_path']

begin
  resources("template[#{grants_path}]")
rescue
  Chef::Log.info('Could not find previously defined grants.sql resource')
  template grants_path do
    source 'grants.sql.erb'
    owner  'root'
    group  node['root_group']
    mode   '0600'
    action :create
  end
end

execute 'mysql-install-privileges' do
  command %Q["#{node['mysql']['server']['mysql_bin']}" -u root #{node['mysql']['server_root_password'].empty? ? '' : '-p' }"#{node['mysql']['server_root_password']}" < "#{grants_path}"]
  action :nothing
  subscribes :run, resources("template[#{grants_path}]"), :immediately
end

service 'mysql-start' do
  service_name node['mysql']['server']['service_name']
  action :start
end
