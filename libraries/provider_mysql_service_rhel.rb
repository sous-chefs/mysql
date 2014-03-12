require 'chef/provider/lwrp_base'

class Chef::Provider::MysqlService::Rhel < Chef::Provider::MysqlService
  use_inline_resources

  def whyrun_supported?
    true
  end

  action :create do
    case new_resource.version
    when '5.0'
      base_dir = nil
      prefix_dir = '/usr'
      run_dir = '/var/run/mysqld'
      pid_file = '/var/run/mysql/mysql.pid'
      socket_file = '/var/lib/mysql/mysql.sock'
      package_name = 'mysql-server'
      service_name = 'mysqld'
    when '5.1'
      base_dir = '/opt/rh/mysql51/root'
      prefix_dir = '/opt/rh/mysql51/root/usr'
      run_dir = '/opt/rh/mysql51/root/var/run/mysqld/'
      pid_file = '/var/run/mysql/mysql.pid'
      socket_file = '/var/lib/mysql/mysql.sock'
      package_name = 'mysql51-mysql-server'
      service_name = 'mysql51-mysqld'
    when '5.5'
      base_dir = '/opt/rh/mysql55/root'
      prefix_dir = '/opt/rh/mysql55/root/usr'
      run_dir = '/opt/rh/mysql55/root/var/run/mysqld/'
      pid_file = '/var/run/mysql/mysql.pid'
      socket_file = '/var/lib/mysql/mysql.sock'
      package_name = 'mysql55-mysql-server'
      service_name = 'mysql55-mysqld'
    end

    converge_by 'rhel pattern' do

      package package_name do
        action :install
      end

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

      directory new_resource.data_dir do
        owner 'mysql'
        mode '0750'
        action :create
      end

      template "#{base_dir}/etc/my.cnf.erb" do
        source '5.5/my.cnf.erb'
        owner 'mysql'
        mode '0600'
        variables(
          :base_dir => base_dir,
          :data_dir => new_resource.data_dir,
          :pid_file => pid_file,
          :socket_file => socket_file,
          :port => new_resource.port
          )
        action :create
        notifies :run, 'bash[move mysql data to datadir]', :immediately
        notifies :restart, "service[#{service_name}]"
      end

      bash 'move mysql data to datadir' do
        user 'root'
        code <<-EOH
        service #{service_name} stop \
        && mv /var/mysql/* #{new_resource.data_dir}
        EOH
        action :nothing
        only_if "[ '/var/lib/mysql' != #{new_resource.data_dir} ]"
        only_if "[ `stat -c %h #{new_resource.data_dir}` -eq 2 ]"
        not_if '[ `stat -c %h /var/lib/mysql/` -eq 2 ]'
      end

      service service_name do
        supports :restart => true
        action [:start, :enable]
        notifies :run, 'execute[wait for mysql]', :immediately
      end

      execute 'wait for mysql' do
        command "until [ -S #{socket_file} ] ; do sleep 1 ; done"
        timeout 10
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
    end
  end

  action :enable do
    case new_resource.version
    when '5.0'
      service_name = 'mysqld'
    when '5.1'
      service_name = 'mysql51-mysqld'
    when '5.5'
      service_name = 'mysql55-mysqld'
    end

    converge_by 'configure mysql service resource' do
      service service_name do
        action [:start, :enable]
      end
    end
  end
end

Chef::Platform.set :platform => :amazon, :resource => :mysql_service, :provider => Chef::Provider::MysqlService::Rhel
Chef::Platform.set :platform => :redhat, :resource => :mysql_service, :provider => Chef::Provider::MysqlService::Rhel
Chef::Platform.set :platform => :centos, :resource => :mysql_service, :provider => Chef::Provider::MysqlService::Rhel
Chef::Platform.set :platform => :oracle, :resource => :mysql_service, :provider => Chef::Provider::MysqlService::Rhel
Chef::Platform.set :platform => :scientific, :resource => :mysql_service, :provider => Chef::Provider::MysqlService::Rhel
