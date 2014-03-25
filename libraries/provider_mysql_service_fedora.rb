require 'chef/provider/lwrp_base'

class Chef::Provider::MysqlService::Fedora < Chef::Provider::MysqlService
  use_inline_resources if defined?(use_inline_resources)

  def whyrun_supported?
    true
  end

  action :create do
    converge_by 'fedora pattern' do

      prefix_dir = '/usr'
      include_dir = '/etc/my.cnf.d'
      lc_messages_dir = '/usr/share/mysql'
      run_dir = '/var/run/mysqld'
      pid_file = '/var/run/mysqld/mysqld.pid'
      socket_file = '/var/run/mysqld/mysql.sock'
      package_name = 'community-mysql-server'

      package package_name do
        action :install
      end

      directory '/etc/my.cnf.d/' do
        owner 'mysql'
        group 'mysql'
        mode '0750'
        action :create
        recursive true
      end

      directory run_dir do
        owner 'mysql'
        group 'mysql'
        mode '0755'
        action :create
        recursive true
      end

      directory new_resource.data_dir do
        owner 'mysql'
        group 'mysql'
        mode '0750'
        action :create
        recursive true
      end

      service 'mysqld' do
        action [:start, :enable]
      end

      execute 'assign-root-password' do
        cmd = "#{prefix_dir}/bin/mysqladmin"
        cmd << ' -u root password '
        cmd << node['mysql']['server_root_password']
        command cmd
        action :run
        only_if "#{prefix_dir}/bin/mysql -u root -e 'show databases;'"
      end

      template '/etc/mysql_grants.sql' do
        source 'grants/grants.sql.erb'
        owner  'root'
        group  'root'
        mode   '0600'
        action :create
        notifies :run, 'execute[install-grants]'
      end

      if node['mysql']['server_root_password'].empty?
        pass_string = ''
      else
        pass_string = "-p#{node['mysql']['server_root_password']}"
      end

      execute 'install-grants' do
        cmd = "#{prefix_dir}/bin/mysql"
        cmd << ' -u root '
        cmd << "#{pass_string} < /etc/mysql_grants.sql"
        command cmd
        action :nothing
      end

      template '/etc/my.cnf' do
        source "#{new_resource.version}/my.cnf.erb"
        cookbook 'mysql'
        owner 'mysql'
        group 'mysql'
        mode '0600'
        variables(
          :prefix_dir => prefix_dir,
          :lc_messages_dir => lc_messages_dir,
          :data_dir => new_resource.data_dir,
          :pid_file => pid_file,
          :socket_file => socket_file,
          :port => new_resource.port,
          :include_dir => include_dir
          )
        action :create
        notifies :run, 'bash[move mysql data to datadir]'
        notifies :restart, 'service[mysqld]'
      end

      bash 'move mysql data to datadir' do
        user 'root'
        code <<-EOH
        service mysqld stop \
        && mv /var/lib/mysql/* #{new_resource.data_dir}
        EOH
        action :nothing
        only_if "[ '/var/lib/mysql' != #{new_resource.data_dir} ]"
        only_if "[ `stat -c %h #{new_resource.data_dir}` -eq 2 ]"
        not_if '[ `stat -c %h /var/lib/mysql/` -eq 2 ]'
      end
    end
  end
end

Chef::Platform.set :platform => :fedora, :resource => :mysql_service, :provider => Chef::Provider::MysqlService::Fedora
