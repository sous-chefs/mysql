require 'spec_helper'

describe 'mysql_test::mysql_service_one on omnios-r151006c' do

  before do
    stub_command("/opt/mysql55/bin/mysql -u root -e 'show databases;'").and_return(true)
  end

  let(:mysql_service_one_run) do
    ChefSpec::Runner.new(
      :platform => 'omnios',
      :version => 'r151006c',
      :step_into => 'mysql_service'
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

    it 'steps into mysql_service and creates my.conf' do
      expect(mysql_service_one_run).to create_template('/opt/mysql55/etc/my.cnf').with(
        :owner => 'mysql',
        :mode => '0600',
        )
    end

    it 'steps into mysql_service and creates my.conf' do
      expect(mysql_service_one_run).to render_file('/opt/mysql55/etc/my.cnf').with_content(my_cnf_content_omnios_r151006c)
    end

  end
end
