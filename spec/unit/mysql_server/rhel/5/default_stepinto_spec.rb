require 'spec_helper'

describe 'mysql_test_default::server' do
  let(:centos_5_8_default_run) do
    ChefSpec::Runner.new(
      :step_into => 'mysql_service',
      :platform => 'centos',
      :version => '5.8'
      ) do |node|
      node.set['mysql']['service_name'] = 'centos_5_8_default'
    end.converge('mysql_test_default::server')
  end

  let(:my_cnf_5_5_content_centos_5_8) do
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
'
  end

  before do
    stub_command("/usr/bin/mysql -u root -e 'show databases;'").and_return(true)
  end

  context 'when using default parameters' do
    it 'creates mysql_service[centos_5_8_default]' do
      expect(centos_5_8_default_run).to create_mysql_service('centos_5_8_default').with(
        :version => '5.0',
        :port => '3306',
        :data_dir => '/var/lib/mysql'
        )
    end

    it 'steps into mysql_service and installs package[mysql-server]' do
      expect(centos_5_8_default_run).to install_package('mysql-server')
    end

    it 'steps into mysql_service and creates directory[/etc/mysql/conf.d]' do
      expect(centos_5_8_default_run).to create_directory('/etc/mysql/conf.d').with(
        :owner => 'mysql',
        :group => 'mysql',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'steps into mysql_service and creates directory[/var/run/mysqld]' do
      expect(centos_5_8_default_run).to create_directory('/var/run/mysqld').with(
        :owner => 'mysql',
        :group => 'mysql',
        :mode => '0755',
        :recursive => true
        )
    end

    it 'steps into mysql_service and creates directory[/var/lib/mysql]' do
      expect(centos_5_8_default_run).to create_directory('/var/lib/mysql').with(
        :owner => 'mysql',
        :group => 'mysql',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'steps into mysql_service and creates template[/etc/my.cnf]' do
      expect(centos_5_8_default_run).to create_template('/etc/my.cnf').with(
        :owner => 'mysql',
        :group => 'mysql',
        :mode => '0600'
        )
    end

    it 'steps into mysql_service and renders file[/etc/my.cnf]' do
      expect(centos_5_8_default_run).to render_file('/etc/my.cnf').with_content(my_cnf_5_5_content_centos_5_8)
    end

    it 'steps into mysql_service and creates bash[move mysql data to datadir]' do
      expect(centos_5_8_default_run).to_not run_bash('move mysql data to datadir')
    end

    it 'steps into mysql_service and creates service[mysqld]' do
      expect(centos_5_8_default_run).to start_service('mysqld')
      expect(centos_5_8_default_run).to enable_service('mysqld')
    end

    it 'steps into mysql_service and creates execute[assign-root-password]' do
      expect(centos_5_8_default_run).to run_execute('assign-root-password').with(
        :command => '/usr/bin/mysqladmin -u root password ilikerandompasswords'
        )
    end

    it 'steps into mysql_service and creates template[/etc/mysql_grants.sql]' do
      expect(centos_5_8_default_run).to create_template('/etc/mysql_grants.sql').with(
        :cookbook => 'mysql',
        :owner => 'root',
        :group => 'root',
        :mode => '0600'
        )
    end

    it 'steps into mysql_service and creates execute[install-grants]' do
      expect(centos_5_8_default_run).to_not run_execute('install-grants').with(
        :command => '/usr/bin/mysql -u root -pilikerandompasswords < /etc/mysql_grants.sql'
        )
    end
  end
end
