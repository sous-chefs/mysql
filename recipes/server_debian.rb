
directory '/var/cache/local/preseeding' do
  owner 'root'
  group node['mysql']['root_group']
  mode '0755'
  recursive true
end

execute 'preseed mysql-server' do
  command 'debconf-set-selections /var/cache/local/preseeding/mysql-server.seed'
  action :nothing
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
  owner  'root'
  group  node['mysql']['root_group']
  mode   '0600'
end

service 'mysql-start' do
  service_name node['mysql']['service_name']
  action :start
end
