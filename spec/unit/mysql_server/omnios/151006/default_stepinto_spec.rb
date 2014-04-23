require 'spec_helper'

describe 'mysql_test_default::server on omnios-151006' do
  let(:omnios_151006_default_stepinto_run) do
    ChefSpec::Runner.new(
      :step_into => 'mysql_service',
      :platform => 'omnios',
      :version => '151006'
      ) do |node|
      node.set['mysql']['service_name'] = 'omnios_151006_default_stepinto'
    end.converge('mysql_test_default::server')
  end

  let(:my_cnf_5_5_content_omnios_151006) do
    '[client]
port                           = 3306
socket                         = /tmp/mysql.sock

[mysqld_safe]
socket                         = /tmp/mysql.sock

[mysqld]
user                           = mysql
pid-file                       = /var/run/mysql/mysql.pid
socket                         = /tmp/mysql.sock
port                           = 3306
datadir                        = /var/lib/mysql
lc-messages-dir                = /opt/mysql55/share

[mysql]
!includedir /opt/mysql55/etc/mysql/conf.d
'
  end

  let(:grants_sql_content_default_omnios_151006) do
    "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
UPDATE mysql.user SET Password=PASSWORD('ilikerandompasswords') WHERE User='root';
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('ilikerandompasswords');
SET PASSWORD FOR 'root'@'127.0.0.1' = PASSWORD('ilikerandompasswords');"
  end

  before do
    stub_command("/opt/mysql55/bin/mysql -u root -e 'show databases;'").and_return(true)
  end

  context 'when using default parameters' do
    it 'creates mysql_service[omnios_151006_default_stepinto]' do
      expect(omnios_151006_default_stepinto_run).to create_mysql_service('omnios_151006_default_stepinto')
    end

    it 'steps into mysql_service and installs the package' do
      expect(omnios_151006_default_stepinto_run).to install_package('database/mysql-55')
    end

    it 'steps into mysql_service and creates the include directory' do
      expect(omnios_151006_default_stepinto_run).to create_directory('/opt/mysql55/etc/mysql/conf.d').with(
        :owner => 'mysql',
        :group => 'mysql',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'steps into mysql_service and creates the run directory' do
      expect(omnios_151006_default_stepinto_run).to create_directory('/var/run/mysql').with(
        :owner => 'mysql',
        :group => 'mysql',
        :mode => '0755',
        :recursive => true
        )
    end

    it 'steps into mysql_service and creates the data directory' do
      expect(omnios_151006_default_stepinto_run).to create_directory('/var/lib/mysql').with(
        :owner => 'mysql',
        :group => 'mysql',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'steps into mysql_service and creates the data directory data subdirectory' do
      expect(omnios_151006_default_stepinto_run).to create_directory('/var/lib/mysql/data').with(
        :owner => 'mysql',
        :group => 'mysql',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'steps into mysql_service and creates the data directory data/mysql' do
      expect(omnios_151006_default_stepinto_run).to create_directory('/var/lib/mysql/data/mysql').with(
        :owner => 'mysql',
        :group => 'mysql',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'steps into mysql_service and creates the data directory data/test' do
      expect(omnios_151006_default_stepinto_run).to create_directory('/var/lib/mysql/data/test').with(
        :owner => 'mysql',
        :group => 'mysql',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'steps into mysql_service and creates my.conf' do
      expect(omnios_151006_default_stepinto_run).to create_template('/opt/mysql55/etc/my.cnf').with(
        :cookbook => 'mysql',
        :owner => 'mysql',
        :group => 'mysql',
        :mode => '0600'
      )
    end

    it 'steps into mysql_service and creates my.conf' do
      expect(omnios_151006_default_stepinto_run).to render_file('/opt/mysql55/etc/my.cnf').with_content(my_cnf_5_5_content_omnios_151006)
    end

    it 'steps into mysql_service and creates a bash resource' do
      expect(omnios_151006_default_stepinto_run).to_not run_bash('move mysql data to datadir')
    end

    it 'steps into mysql_service and initializes the mysql database' do
      expect(omnios_151006_default_stepinto_run).to run_execute('initialize mysql database').with(
        :command => '/opt/mysql55/scripts/mysql_install_db --basedir=/opt/mysql55 --user=mysql'
        )
    end

    it 'steps into mysql_service and creates my.conf' do
      expect(omnios_151006_default_stepinto_run).to create_template('/lib/svc/method/mysqld').with(
        :cookbook => 'mysql',
        :owner => 'root',
        :mode => '0555'
        )
    end

    it 'steps into mysql_service and creates /tmp/mysql.xml' do
      expect(omnios_151006_default_stepinto_run).to create_template('/tmp/mysql.xml').with(
        :cookbook => 'mysql',
        :owner => 'root',
        :mode => '0644'
        )
    end

    it 'steps into mysql_service and imports the mysql service manifest' do
      expect(omnios_151006_default_stepinto_run).to_not run_execute('import mysql manifest').with(
        :command => 'svccfg import /tmp/mysql.xml'
        )
    end

    it 'steps into mysql_service and manages the mysql service' do
      expect(omnios_151006_default_stepinto_run).to start_service('mysql')
      expect(omnios_151006_default_stepinto_run).to enable_service('mysql')
    end

    it 'steps into mysql_service and waits for mysql to start' do
      expect(omnios_151006_default_stepinto_run).to run_execute('wait for mysql').with(
        :command => 'until [ -S /tmp/mysql.sock ] ; do sleep 1 ; done',
        :timeout => 10
        )
    end

    it 'steps into mysql_service and assigns root password' do
      expect(omnios_151006_default_stepinto_run).to run_execute('assign-root-password').with(
        :command => '/opt/mysql55/bin/mysqladmin -u root password ilikerandompasswords'
        )
    end

    it 'steps into mysql_service and creates /etc/mysql_grants.sql' do
      expect(omnios_151006_default_stepinto_run).to create_template('/etc/mysql_grants.sql').with(
        :cookbook => 'mysql',
        :owner => 'root',
        :group => 'root',
        :mode => '0600'
        )
    end

    it 'steps into mysql_service and renders file[/etc/mysql_grants.sql]' do
      expect(omnios_151006_default_stepinto_run).to render_file('/etc/mysql_grants.sql').with_content(
        grants_sql_content_default_omnios_151006
        )
    end

    it 'steps into mysql_service and installs grants' do
      expect(omnios_151006_default_stepinto_run).to_not run_execute('install-grants').with(
        :command => '/opt/mysql55/bin/mysql -u root -pilikerandompasswords < /etc/mysql_grants.sql'
        )
    end
  end
end
