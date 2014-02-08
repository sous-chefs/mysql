# require 'pry'

if node['mysql']['server']['selinux_enabled'] == true
  %w{policycoreutils policycoreutils-python}.each do |pkg|
    package pkg do
      action :install
    end
  end
end

# => Make sure the MySQL Directories are Constructed Appropriately
node['mysql']['server']['directories'].each do |key, value|

# =>  Create file to store previously executed SELinux Operations
# =>  This is a first-run resource, you really do not want this to run again unless you change directory values.
# =>  It doesn't hurt anything but cookbook execution time if this runs again. It's OK if this file is lost.
# =>  Also, a text file makes this function with Chef-Solo.
  if node['mysql']['server']['selinux_enabled'] == true
    file 'MySQL SELinux Tags' do
      path "#{Chef::Config[:file_cache_path]}/.selinuxed_mysql"
      owner 'root'
      group 'root'
      mode '0644'
      action :create_if_missing
    end

    bash "Set SELinux Context - #{value}" do
      user 'root'
      code <<-EOF
      semanage fcontext -a -t mysqld_db_t "#{value}(/.*)?"
      echo "#{key} #{value}" >> #{Chef::Config[:file_cache_path]}/.selinuxed_mysql
      EOF
      action :run
      only_if { !File.open("#{Chef::Config[:file_cache_path]}/.selinuxed_mysql").grep(/#{key} #{value}/).any? }
    end
  end

# => Create Each Directory
  directory value do
    owner     'mysql'
    group     'mysql'
    mode      '0755'
    action    :create
    recursive true
  end
end

#----
template 'initial-my.cnf' do
  path '/etc/my.cnf'
  source 'my.cnf.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

# => Install Packages AFTER directories and my.cnf have been created.
node['mysql']['server']['packages'].each do |name|
  package name do
    action :install
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
  notifies :reload, 'service[mysql]', :immediately
end

service 'mysql' do
  service_name node['mysql']['server']['service_name']
  supports     :status => true, :restart => true, :reload => true
  action       [:enable, :start]
end
