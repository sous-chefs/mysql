require 'spec_helper'

describe 'mysql_test_default::server on suse-11.3' do
  let(:suse_11_3_default_stepinto_run) do
    ChefSpec::Runner.new(
      :step_into => 'mysql_service',
      :platform => 'suse',
      :version => '11.3'
      ) do |node|
      node.set['mysql']['service_name'] = 'suse_11_3_default_stepinto'
    end.converge('mysql_test_default::server')
  end

  let(:my_cnf_5_5_content_suse_11_3) do
    '[client]
port                           = 3306
socket                         = /var/lib/mysql/mysql.sock

[mysqld_safe]
socket                         = /var/lib/mysql/mysql.sock

[mysqld]
user                           = mysql
pid-file                       = /var/run/mysql/mysql.pid
socket                         = /var/lib/mysql/mysql.sock
port                           = 3306
datadir                        = /var/lib/mysql

[mysql]
!includedir /etc/mysql/conf.d
'
  end

  let(:grants_sql_content_default_suse_11_3) do
    "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
UPDATE mysql.user SET Password=PASSWORD('ilikerandompasswords') WHERE User='root';
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('ilikerandompasswords');
SET PASSWORD FOR 'root'@'127.0.0.1' = PASSWORD('ilikerandompasswords');"
  end

  before do
    stub_command("/usr/bin/mysql -u root -e 'show databases;'").and_return(true)
  end

  context 'when using default parameters' do
    it 'creates mysql_service[suse_11_3_default_stepinto]' do
      expect(suse_11_3_default_stepinto_run).to create_mysql_service('suse_11_3_default_stepinto')
    end

    it 'steps into mysql_service and installs the package' do
      expect(suse_11_3_default_stepinto_run).to install_package('mysql')
    end

    it 'steps into mysql_service and deletes /etc/mysqlaccess.conf' do
      expect(suse_11_3_default_stepinto_run).to delete_file('/etc/mysqlaccess.conf')
    end

    it 'steps into mysql_service and deletes /etc/mysql/default_plugins.cnf' do
      expect(suse_11_3_default_stepinto_run).to delete_file('/etc/mysql/default_plugins.cnf')
    end

    it 'steps into mysql_service and deletes /etc/mysql/secure_file_priv.conf' do
      expect(suse_11_3_default_stepinto_run).to delete_file('/etc/mysql/secure_file_priv.conf')
    end

    it 'steps into mysql_service and creates the include directory' do
      expect(suse_11_3_default_stepinto_run).to create_directory('/etc/mysql/conf.d').with(
        :owner => 'mysql',
        :group => 'mysql',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'steps into mysql_service and creates the run directory' do
      expect(suse_11_3_default_stepinto_run).to create_directory('/var/run/mysql').with(
        :owner => 'mysql',
        :group => 'mysql',
        :mode => '0755',
        :recursive => true
        )
    end

    it 'steps into mysql_service and creates the data directory' do
      expect(suse_11_3_default_stepinto_run).to create_directory('/var/lib/mysql').with(
        :owner => 'mysql',
        :group => 'mysql',
        :mode => '0755',
        :recursive => true
        )
    end

    it 'steps into mysql_service and creates my.conf' do
      expect(suse_11_3_default_stepinto_run).to create_template('/etc/my.cnf').with(
        :cookbook => 'mysql',
        :owner => 'mysql',
        :group => 'mysql',
        :mode => '0600'
      )
    end

    it 'steps into mysql_service and creates my.conf' do
      expect(suse_11_3_default_stepinto_run).to render_file('/etc/my.cnf').with_content(my_cnf_5_5_content_suse_11_3)
    end

    it 'steps into mysql_service and initializes the mysql database' do
      expect(suse_11_3_default_stepinto_run).to run_execute('initialize mysql database').with(
        :command => '/usr/bin/mysql_install_db --user=mysql'
        )
    end

    it 'steps into mysql_service and manages the mysql service' do
      expect(suse_11_3_default_stepinto_run).to start_service('mysql')
      expect(suse_11_3_default_stepinto_run).to enable_service('mysql')
    end

    it 'steps into mysql_service and waits for mysql to start' do
      expect(suse_11_3_default_stepinto_run).to_not run_execute('wait for mysql').with(
        :command => 'until [ -S /var/lib/mysql/mysql.sock ] ; do sleep 1 ; done',
        :timeout => 10
        )
    end

    it 'steps into mysql_service and assigns root password' do
      expect(suse_11_3_default_stepinto_run).to run_execute('assign-root-password').with(
        :command => '/usr/bin/mysqladmin -u root password ilikerandompasswords'
        )
    end

    it 'steps into mysql_service and creates /etc/mysql_grants.sql' do
      expect(suse_11_3_default_stepinto_run).to create_template('/etc/mysql_grants.sql').with(
        :cookbook => 'mysql',
        :owner => 'root',
        :group => 'root',
        :mode => '0600'
        )
    end

    it 'steps into mysql_service and renders file[/etc/mysql_grants.sql]' do
      expect(suse_11_3_default_stepinto_run).to render_file('/etc/mysql_grants.sql').with_content(
        grants_sql_content_default_suse_11_3
        )
    end

    it 'steps into mysql_service and installs grants' do
      expect(suse_11_3_default_stepinto_run).to_not run_execute('install-grants').with(
        :command => '/usr/bin/mysql -u root -pilikerandompasswords < /etc/mysql_grants.sql'
        )
    end
  end
end
