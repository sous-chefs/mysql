require 'spec_helper'

describe 'mysql_test_custom::server on suse-11.3' do
  let(:suse_11_3_custom_stepinto_run) do
    ChefSpec::Runner.new(
      :step_into => 'mysql_service',
      :platform => 'suse',
      :version => '11.3'
      ) do |node|
      node.set['mysql']['service_name'] = 'suse_11_3_custom_stepinto'
      node.set['mysql']['version'] = '5.5'
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

  let(:my_cnf_5_5_content_custom_suse_11_3) do
    '# This my template. There are many like it but this one is mine'
  end

  let(:grants_sql_content_custom_suse_11_3) do
    "GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%' identified by 'syncmebabyonemoretime';
GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY 'YUNOSETPASSWORD' WITH GRANT OPTION;
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('YUNOSETPASSWORD');
SET PASSWORD FOR 'root'@'127.0.0.1' = PASSWORD('YUNOSETPASSWORD');
GRANT ALL PRIVILEGES ON *.* TO 'root'@'10.9.8.7/6' IDENTIFIED BY 'YUNOSETPASSWORD' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'1.2.3.4/5' IDENTIFIED BY 'YUNOSETPASSWORD' WITH GRANT OPTION;
"
  end

  before do
    stub_command("/usr/bin/mysql -u root -e 'show databases;'").and_return(true)
  end

  context 'when using default parameters' do
    it 'creates mysql_service[suse_11_3_custom_stepinto]' do
      expect(suse_11_3_custom_stepinto_run).to create_mysql_service('suse_11_3_custom_stepinto')
    end

    it 'steps into mysql_service and installs the package' do
      expect(suse_11_3_custom_stepinto_run).to install_package('mysql')
    end

    it 'steps into mysql_service and deletes /etc/mysqlaccess.conf' do
      expect(suse_11_3_custom_stepinto_run).to delete_file('/etc/mysqlaccess.conf')
    end

    it 'steps into mysql_service and deletes /etc/mysql/default_plugins.cnf' do
      expect(suse_11_3_custom_stepinto_run).to delete_file('/etc/mysql/default_plugins.cnf')
    end

    it 'steps into mysql_service and deletes /etc/mysql/secure_file_priv.conf' do
      expect(suse_11_3_custom_stepinto_run).to delete_file('/etc/mysql/secure_file_priv.conf')
    end

    it 'steps into mysql_service and creates the include directory' do
      expect(suse_11_3_custom_stepinto_run).to create_directory('/etc/mysql/conf.d').with(
        :owner => 'mysql',
        :group => 'mysql',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'steps into mysql_service and creates the run directory' do
      expect(suse_11_3_custom_stepinto_run).to create_directory('/var/run/mysql').with(
        :owner => 'mysql',
        :group => 'mysql',
        :mode => '0755',
        :recursive => true
        )
    end

    it 'steps into mysql_service and creates the data directory' do
      expect(suse_11_3_custom_stepinto_run).to create_directory('/data').with(
        :owner => 'mysql',
        :group => 'mysql',
        :mode => '0755',
        :recursive => true
        )
    end

    it 'steps into mysql_service and creates my.conf' do
      expect(suse_11_3_custom_stepinto_run).to create_template('/etc/my.cnf').with(
        :owner => 'mysql',
        :group => 'mysql',
        :mode => '0600'
      )
    end

    it 'steps into mysql_service and creates my.conf' do
      expect(suse_11_3_custom_stepinto_run).to render_file('/etc/my.cnf').with_content(my_cnf_5_5_content_custom_suse_11_3)
    end

    it 'steps into mysql_service and initializes the mysql database' do
      expect(suse_11_3_custom_stepinto_run).to run_execute('initialize mysql database').with(
        :command => '/usr/bin/mysql_install_db --user=mysql'
        )
    end

    it 'steps into mysql_service and manages the mysql service' do
      expect(suse_11_3_custom_stepinto_run).to start_service('mysql')
      expect(suse_11_3_custom_stepinto_run).to enable_service('mysql')
    end

    it 'steps into mysql_service and waits for mysql to start' do
      expect(suse_11_3_custom_stepinto_run).to_not run_execute('wait for mysql').with(
        :command => 'until [ -S /var/lib/mysql/mysql.sock ] ; do sleep 1 ; done',
        :timeout => 10
        )
    end

    it 'steps into mysql_service and assigns root password' do
      expect(suse_11_3_custom_stepinto_run).to run_execute('assign-root-password').with(
        :command => '/usr/bin/mysqladmin -u root password YUNOSETPASSWORD'
        )
    end

    it 'steps into mysql_service and creates /etc/mysql_grants.sql' do
      expect(suse_11_3_custom_stepinto_run).to create_template('/etc/mysql_grants.sql').with(
        :cookbook => 'mysql',
        :owner => 'root',
        :group => 'root',
        :mode => '0600'
        )
    end

    it 'steps into mysql_service and renders file[/etc/mysql_grants.sql]' do
      expect(suse_11_3_custom_stepinto_run).to render_file('/etc/mysql_grants.sql').with_content(
        grants_sql_content_custom_suse_11_3
        )
    end

    it 'steps into mysql_service and installs grants' do
      expect(suse_11_3_custom_stepinto_run).to_not run_execute('install-grants').with(
        :command => '/usr/bin/mysql -u root -pilikerandompasswords < /etc/mysql_grants.sql'
        )
    end
  end
end
