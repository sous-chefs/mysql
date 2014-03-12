require 'chef/provider/lwrp_base'

class Chef::Provider::MysqlService::Debian < Chef::Provider::MysqlService
  use_inline_resources

  def whyrun_supported?
    true
  end

  action :create do
    converge_by 'debian pattern' do

      base_dir = ''
      prefix_dir = '/usr'
      run_dir = '/var/run/mysql'
      pid_file = '/var/run/mysql/mysql.pid'
      socket_file = '/var/run/mysqld/mysqld.sock'

      template '/etc/apparmor.d/usr.sbin.mysqld' do
        source 'apparmor/usr.sbin.mysqld.erb'
        action :create
        notifies :reload, 'service[apparmor-mysql]', :immediately
        only_if { ::File.directory?('/etc/apparmor.d')  }
      end

      service 'apparmor-mysql' do
        service_name 'apparmor'
        action :nothing
        supports :reload => true
      end

      directory '/var/cache/local/preseeding' do
        owner 'root'
        group 'root'
        mode '0755'
        recursive true
      end

      template '/var/cache/local/preseeding/mysql-server.seed' do
        source 'debian/mysql-server.seed.erb'
        owner 'root'
        group 'root'
        mode '0600'
        notifies :run, 'execute[preseed mysql-server]', :immediately
      end

      execute 'preseed mysql-server' do
        command '/usr/bin/debconf-set-selections /var/cache/local/preseeding/mysql-server.seed'
        action  :nothing
      end

      package 'mysql-server-5.5' do
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

      template "#{base_dir}/etc/my.cnf" do
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
        notifies :restart, 'service[mysql]'
      end

      bash 'move mysql data to datadir' do
        user 'root'
        code <<-EOH
        service mysql stop \
        && mv /var/mysql/* #{new_resource.data_dir}
        EOH
        action :nothing
        only_if "[ '/var/lib/mysql' != #{new_resource.data_dir} ]"
        only_if "[ `stat -c %h #{new_resource.data_dir}` -eq 2 ]"
        not_if '[ `stat -c %h /var/lib/mysql/` -eq 2 ]'
      end

      execute 'initialize mysql database' do
        command "#{base_dir}/scripts/mysql_install_db --basedir=#{base_dir}"
        creates "#{new_resource.data_dir}/mysql/user.frm"
      end

      service 'mysql' do
        provider Chef::Provider::Service::Init::Debian
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
    converge_by 'configure mysql service resource' do
      service 'mysql' do
        action [:start, :enable]
      end
    end
  end
end

Chef::Platform.set :platform => :debian, :resource => :mysql_service, :provider => Chef::Provider::MysqlService::Debian
