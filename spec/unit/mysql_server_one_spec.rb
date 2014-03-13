require 'spec_helper'

describe 'mysql_test::mysql_service_one on omnios-r151006c' do

  before do
    stub_command("/opt/mysql55/bin/mysql -u root -e 'show databases;'").and_return(true)
  end

  let(:mysql_service_one_run) do
    ChefSpec::Runner.new(
      :step_into => 'mysql_service',
      :platform => 'omnios',
      :version => 'r151006c'
      ).converge('mysql_test::mysql_service_one')
  end

  let(:my_cnf_content_omnios_r151006c) do
    '[client]
port                           = 3308
socket                         = /tmp/mysql.sock

[mysqld_safe]
socket                         = /tmp/mysql.sock
nice                           = 0

[mysqld]
user                           = mysql
pid-file                       = /var/run/mysql/mysql.pid
socket                         = /tmp/mysql.sock
port                           = 3308
datadir                        = /var/lib/mysql
tmpdir                         = /tmp
lc-messages-dir                =

[mysql]
!includedir /opt/mysql55/etc/mysql/conf.d'
  end

  context 'when using default parameters' do
    it 'creates mysql_service[default]' do
      expect(mysql_service_one_run).to create_mysql_service('default')
    end

    it 'steps into mysql_service and installs the package' do
      expect(mysql_service_one_run).to install_package('database/mysql-55')
    end

    it 'steps into mysql_service and creates the include directory' do
      expect(mysql_service_one_run).to create_directory('/opt/mysql55/etc/mysql/conf.d').with(
        :owner => 'mysql',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'steps into mysql_service and creates the run directory' do
      expect(mysql_service_one_run).to create_directory('/var/run/mysql').with(
        :owner => 'mysql',
        :mode => '0755',
        :recursive => true
        )
    end

    it 'steps into mysql_service and creates the data directory' do
      expect(mysql_service_one_run).to create_directory('/var/lib/mysql').with(
        :owner => 'mysql',
        :mode => '0750',
        :recursive => true
        )
    end

    # FIXME: add render_file
    it 'steps into mysql_service and creates my.conf' do
      expect(mysql_service_one_run).to create_template('/opt/mysql55/etc/my.cnf').with(
        :owner => 'mysql',
        :mode => '0600'
      )
    end

    # it 'steps into mysql_service and creates my.conf' do
    #   expect(mysql_service_one_run).to render_file('/opt/mysql55/etc/my.cnf').with_content(my_cnf_content_omnios_r151006c)
    # end

    it 'steps into mysql_service and creates a bash resource' do
      expect(mysql_service_one_run).to_not run_bash('move mysql data to datadir')
    end

    it 'steps into mysql_service and initializes the mysql database' do
      expect(mysql_service_one_run).to run_execute('initialize mysql database').with(
        :command => '/opt/mysql55/scripts/mysql_install_db --basedir=/opt/mysql55'
        )
    end

    # FIXME: add render_file
    it 'steps into mysql_service and creates my.conf' do
      expect(mysql_service_one_run).to create_template('/lib/svc/method/mysqld').with(
        :owner => 'root',
        :mode => '0555'
        )
    end

    # FIXME - add render_file
    it 'steps into mysql_service and creates /tmp/mysql.xml' do
      expect(mysql_service_one_run).to create_template('/tmp/mysql.xml').with(
        :owner => 'root',
        :mode => '0644'
        )
    end

    it 'steps into mysql_service and imports the mysql service manifest' do
      expect(mysql_service_one_run).to_not run_execute('import mysql manifest').with(
        :command => 'svccfg import /tmp/mysql.xml'
        )
    end

    it 'steps into mysql_service and manages the mysql service' do
      expect(mysql_service_one_run).to start_service('mysql')
      expect(mysql_service_one_run).to enable_service('mysql')
    end

    it 'steps into mysql_service and waits for mysql to start' do
      expect(mysql_service_one_run).to run_execute('wait for mysql').with(
        :command => 'until [ -S /tmp/mysql.sock ] ; do sleep 1 ; done',
        :timeout => 10
        )
    end

    it 'steps into mysql_service and assigns root password' do
      expect(mysql_service_one_run).to run_execute('assign-root-password').with(
        :command => '/opt/mysql55/bin/mysqladmin -u root password ilikerandompasswords'
        )
    end

    # FIXME: add render_file
    it 'steps into mysql_service and creates /etc/mysql_grants.sql' do
      expect(mysql_service_one_run).to create_template('/etc/mysql_grants.sql').with(
        :owner => 'root',
        :group => 'root',
        :mode => '0600'
        )
    end

    it 'steps into mysql_service and installs grants' do
      expect(mysql_service_one_run).to_not run_execute('install-grants').with(
        :command => '/opt/mysql55/bin/mysql -u root -pilikerandompasswords < /etc/mysql_grants.sql'
        )
    end
    
  end
end
