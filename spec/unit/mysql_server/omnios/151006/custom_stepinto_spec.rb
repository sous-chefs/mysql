require 'spec_helper'

describe 'stepped into mysql_test_custom::server on omnios-151006' do
  let(:omnios_151006_custom_stepinto_run) do
    ChefSpec::Runner.new(
      :step_into => 'mysql_service',
      :platform => 'omnios',
      :version => '151006'
      ) do |node|
      node.set['mysql']['service_name'] = 'omnios_151006_custom_stepinto'
      node.set['mysql']['version'] = '5.6'
      node.set['mysql']['port'] = '3308'
      node.set['mysql']['data_dir'] = '/data'
      node.set['mysql']['template_source'] = 'custom.erb'
      node.set['mysql']['allow_remote_root'] = true
      node.set['mysql']['remove_anonymous_users'] = false
      node.set['mysql']['remove_test_database'] = false
      node.set['mysql']['root_network_acl'] = ['10.9.8.7/6', '1.2.3.4/5']
      node.set['mysql']['server_root_password'] = 'YUNOSETPASSWORD'
      node.set['mysql']['server_debian_password'] = 'postinstallscriptsarestupid'
      node.set['mysql']['server_repl_password'] = 'syncmebabyonemoretime'
    end.converge('mysql_test_custom::server')
  end

  let(:my_cnf_5_6_content_omnios_151006) do
    'This my template. There are many like it but this one is mine.'
  end

  let(:grants_sql_content_custom_omnios_151006) do
    "GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%' identified by 'syncmebabyonemoretime';
GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY 'YUNOSETPASSWORD' WITH GRANT OPTION;
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('YUNOSETPASSWORD');
SET PASSWORD FOR 'root'@'127.0.0.1' = PASSWORD('YUNOSETPASSWORD');
GRANT ALL PRIVILEGES ON *.* TO 'root'@'10.9.8.7/6' IDENTIFIED BY 'YUNOSETPASSWORD' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'1.2.3.4/5' IDENTIFIED BY 'YUNOSETPASSWORD' WITH GRANT OPTION;"
  end

  before do
    stub_command("/opt/mysql56/bin/mysql -u root -e 'show databases;'").and_return(true)
  end

  context 'when using default parameters' do
    it 'creates mysql_service[omnios_151006_custom_stepinto]' do
      expect(omnios_151006_custom_stepinto_run).to create_mysql_service('omnios_151006_custom_stepinto').with(
        :version => '5.6',
        :port => '3308',
        :data_dir => '/data'
        )
    end

    it 'steps into mysql_service and installs the package' do
      expect(omnios_151006_custom_stepinto_run).to install_package('database/mysql-56')
    end

    it 'steps into mysql_service and creates the include directory' do
      expect(omnios_151006_custom_stepinto_run).to create_directory('/opt/mysql56/etc/mysql/conf.d').with(
        :owner => 'mysql',
        :group => 'mysql',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'steps into mysql_service and creates the run directory' do
      expect(omnios_151006_custom_stepinto_run).to create_directory('/var/run/mysql').with(
        :owner => 'mysql',
        :group => 'mysql',
        :mode => '0755',
        :recursive => true
        )
    end

    it 'steps into mysql_service and creates the data directory' do
      expect(omnios_151006_custom_stepinto_run).to create_directory('/data').with(
        :owner => 'mysql',
        :group => 'mysql',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'steps into mysql_service and creates the data directory data subdirectory' do
      expect(omnios_151006_custom_stepinto_run).to create_directory('/data/data').with(
        :owner => 'mysql',
        :group => 'mysql',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'steps into mysql_service and creates the data directory data/mysql' do
      expect(omnios_151006_custom_stepinto_run).to create_directory('/data/data/mysql').with(
        :owner => 'mysql',
        :group => 'mysql',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'steps into mysql_service and creates the data directory data/test' do
      expect(omnios_151006_custom_stepinto_run).to create_directory('/data/data/test').with(
        :owner => 'mysql',
        :group => 'mysql',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'steps into mysql_service and creates my.conf' do
      expect(omnios_151006_custom_stepinto_run).to create_template('/opt/mysql56/my.cnf').with(
        :owner => 'mysql',
        :group => 'mysql',
        :mode => '0600'
      )
    end

    it 'steps into mysql_service and creates my.conf' do
      expect(omnios_151006_custom_stepinto_run).to render_file('/opt/mysql56/my.cnf').with_content(my_cnf_5_6_content_omnios_151006)
    end

    it 'steps into mysql_service and creates a bash resource' do
      expect(omnios_151006_custom_stepinto_run).to_not run_bash('move mysql data to datadir')
    end

    it 'steps into mysql_service and initializes the mysql database' do
      expect(omnios_151006_custom_stepinto_run).to run_execute('initialize mysql database').with(
        :command => '/opt/mysql56/scripts/mysql_install_db --basedir=/opt/mysql56 --user=mysql'
        )
    end

    it 'steps into mysql_service and creates my.conf' do
      expect(omnios_151006_custom_stepinto_run).to create_template('/lib/svc/method/mysqld').with(
        :cookbook => 'mysql',
        :owner => 'root',
        :mode => '0555'
        )
    end

    it 'steps into mysql_service and creates /tmp/mysql.xml' do
      expect(omnios_151006_custom_stepinto_run).to create_template('/tmp/mysql.xml').with(
        :cookbook => 'mysql',
        :owner => 'root',
        :mode => '0644'
        )
    end

    it 'steps into mysql_service and imports the mysql service manifest' do
      expect(omnios_151006_custom_stepinto_run).to_not run_execute('import mysql manifest').with(
        :command => 'svccfg import /tmp/mysql.xml'
        )
    end

    it 'steps into mysql_service and manages the mysql service' do
      expect(omnios_151006_custom_stepinto_run).to start_service('mysql')
      expect(omnios_151006_custom_stepinto_run).to enable_service('mysql')
    end

    it 'steps into mysql_service and waits for mysql to start' do
      expect(omnios_151006_custom_stepinto_run).to run_execute('wait for mysql').with(
        :command => 'until [ -S /tmp/mysql.sock ] ; do sleep 1 ; done',
        :timeout => 10
        )
    end

    it 'steps into mysql_service and assigns root password' do
      expect(omnios_151006_custom_stepinto_run).to run_execute('assign-root-password').with(
        :command => '/opt/mysql56/bin/mysqladmin -u root password YUNOSETPASSWORD'
        )
    end

    it 'steps into mysql_service and creates /etc/mysql_grants.sql' do
      expect(omnios_151006_custom_stepinto_run).to create_template('/etc/mysql_grants.sql').with(
        :cookbook => 'mysql',
        :owner => 'root',
        :group => 'root',
        :mode => '0600'
        )
    end

    it 'steps into mysql_service and renders file[/etc/mysql_grants.sql]' do
      expect(omnios_151006_custom_stepinto_run).to render_file('/etc/mysql_grants.sql').with_content(
        grants_sql_content_custom_omnios_151006
        )
    end

    it 'steps into mysql_service and installs grants' do
      expect(omnios_151006_custom_stepinto_run).to_not run_execute('install-grants').with(
        :command => '/opt/mysql56/bin/mysql -u root -pYUNOSETPASSWORD < /etc/mysql_grants.sql'
        )
    end

    it 'steps into mysql_service and writes log[notify restart]' do
      expect(omnios_151006_custom_stepinto_run).to write_log('notify restart')
    end

    it 'steps into mysql_service and writes log[notify reload]' do
      expect(omnios_151006_custom_stepinto_run).to write_log('notify reload')
    end
  end
end
