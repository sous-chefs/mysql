require 'win32/service'

package_file = File.join(Chef::Config[:file_cache_path], node['mysql']['package_file'])
ENV['PATH'] += ";#{node['mysql']['bin_dir']}"
install_dir = win_friendly_path(node['mysql']['basedir'])

def package(*args, &blk)
  windows_package(*args, &blk)
end

windows_path node['mysql']['bin_dir'] do
  action :add
end

windows_batch 'install mysql service' do
  command "\"#{node['mysql']['bin_dir']}\\mysqld.exe\" --install #{node['mysql']['service_name']}"
  not_if  { Win32::Service.exists?(node['mysql']['service_name']) }
end

remote_file package_file do
  source node['mysql']['url']
  not_if { File.exists?(package_file) }
end

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

windows_package node['mysql']['server']['packages'].first do
  source package_file
  options "INSTALLDIR=\"#{install_dir}\""
  notifies :run, "execute[install mysql service]", :immediately
end
  
windows_path node['mysql']['bin_dir'] do
  action :add
end

execute "install mysql service" do
  command %Q["#{node['mysql']['bin_dir']}\\mysqld.exe" --install "#{node['mysql']['service_name']}"]
  not_if { ::Win32::Service.exists?(node['mysql']['service_name']) }
end

windows_batch 'mysql-install-privileges' do
  command "\"#{node['mysql']['mysql_bin']}\" -u root #{node['mysql']['server_root_password'].empty? ? '' : '-p' }\"#{node['mysql']['server_root_password']}\" < \"#{grants_path}\""
  action :nothing
  subscribes :run, resources("template[#{grants_path}]"), :immediately
end

execute 'mysql-install-privileges' do
  command %Q["#{node['mysql']['mysql_bin']}" -u root #{node['mysql']['server_root_password'].empty? ? '' : '-p' }"#{node['mysql']['server_root_password']}" < "#{grants_path}"]
  action :nothing
  subscribes :run, resources("template[#{grants_path}]"), :immediately
end

execute 'assign-root-password' do
  command %Q["#{node['mysql']['mysqladmin_bin']}" -u root password '#{node['mysql']['server_root_password']}']
  action :run
  only_if %Q["#{node['mysql']['mysql_bin']}" -u root -e 'show databases;']
end

service 'mysql-start' do
  service_name node['mysql']['service_name']
  action :start
end

