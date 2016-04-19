require 'spec_helper'

describe 'mysql_service_test::multi on omnios-151006' do
  cached(:omnios_151006_service_56_multi) do
    ChefSpec::SoloRunner.new(
      platform: 'omnios',
      version: '151006',
      step_into: 'mysql_service'
    ) do |node|
      node.set['mysql']['version'] = '5.6'
      node.set['mysql']['port'] = '3308'
      node.set['mysql']['data_dir'] = '/data/instance-2'
      node.set['mysql']['run_user'] = 'bob'
      node.set['mysql']['run_group'] = 'bob'
      node.set['mysql']['initial_root_password'] = 'string with spaces'
    end.converge('mysql_service_test::multi')
  end

  before do
    stub_command('/usr/bin/test -f /data/instance-1/mysql/user.frm').and_return(true)
  end

  before do
    stub_command('/usr/bin/test -f /data/instance-2/mysql/user.frm').and_return(true)
  end

  before do
    stub_command('/usr/bin/test -f /var/lib/mysql/mysql/user.frm').and_return(true)
  end

  context 'compiling the test recipe' do
    it 'creates user[alice]' do
      expect(omnios_151006_service_56_multi).to create_user('alice')
    end

    it 'creates group[alice]' do
      expect(omnios_151006_service_56_multi).to create_group('alice')
    end

    it 'creates user[bob]' do
      expect(omnios_151006_service_56_multi).to create_user('bob')
    end

    it 'creates group[bob]' do
      expect(omnios_151006_service_56_multi).to create_group('bob')
    end

    it 'deletes mysql_service[default]' do
      expect(omnios_151006_service_56_multi).to delete_mysql_service('default')
    end

    it 'creates mysql_service[instance-1]' do
      expect(omnios_151006_service_56_multi).to create_mysql_service('instance-1')
    end

    it 'creates mysql_service[instance-2]' do
      expect(omnios_151006_service_56_multi).to create_mysql_service('instance-2')
    end
  end

  #
  # mysql_service resource action implementations
  #

  # mysql_service action :delete mysql-default
  context 'stepping into mysql_service[default] resource' do
    it 'stops service[default :delete mysql-default]' do
      expect(omnios_151006_service_56_multi).to stop_service('default :delete mysql-default')
        .with(
          service_name: 'mysql-default',
          provider: Chef::Provider::Service::Solaris
        )
    end

    it 'deletes directory[default :delete /opt/mysql55/etc/mysql-default]' do
      expect(omnios_151006_service_56_multi).to delete_directory('default :delete /opt/mysql55/etc/mysql-default')
        .with(
          path: '/opt/mysql55/etc/mysql-default'
        )
    end

    it 'deletes directory[default :delete /var/run/mysql-default]' do
      expect(omnios_151006_service_56_multi).to delete_directory('default :delete /var/run/mysql-default')
        .with(
          path: '/var/run/mysql-default'
        )
    end

    it 'deletes directory[default :delete /var/adm/log/mysql-default]' do
      expect(omnios_151006_service_56_multi).to delete_directory('default :delete /var/adm/log/mysql-default')
        .with(
          path: '/var/adm/log/mysql-default'
        )
    end
  end

  # mysql_service resource internal implementation
  context 'stepping into mysql_service[instance-1] resource' do
    it 'installs package[instance-1 :create database/mysql-56]' do
      expect(omnios_151006_service_56_multi).to install_package('instance-1 :create database/mysql-56')
        .with(package_name: 'database/mysql-56', version: nil)
    end

    it 'starts service[instance-1 :start mysql-instance-1]' do
      expect(omnios_151006_service_56_multi).to enable_service('instance-1 :start mysql-instance-1')
        .with(
          service_name: 'mysql-instance-1',
          provider: Chef::Provider::Service::Solaris
        )
    end

    it 'creates group[instance-1 :create mysql]' do
      expect(omnios_151006_service_56_multi).to create_group('instance-1 :create mysql')
        .with(group_name: 'mysql')
    end

    it 'creates user[instance-1 :create mysql]' do
      expect(omnios_151006_service_56_multi).to create_user('instance-1 :create mysql')
        .with(username: 'mysql')
    end

    it 'deletes file[instance-1 :create /opt/mysql56/etc/mysql/my.cnf]' do
      expect(omnios_151006_service_56_multi).to delete_file('instance-1 :create /opt/mysql56/etc/mysql/my.cnf')
        .with(path: '/opt/mysql56/etc/mysql/my.cnf')
    end

    it 'deletes file[instance-1 :create /opt/mysql56/etc/my.cnf]' do
      expect(omnios_151006_service_56_multi).to delete_file('instance-1 :create /opt/mysql56/etc/my.cnf')
        .with(path: '/opt/mysql56/etc/my.cnf')
    end

    it 'creates link[instance-1 :create /opt/mysql56/usr/share/my-default.cnf]' do
      expect(omnios_151006_service_56_multi).to create_link('instance-1 :create /opt/mysql56/usr/share/my-default.cnf')
        .with(
          target_file: '/opt/mysql56/usr/share/my-default.cnf',
          to: '/opt/mysql56/etc/mysql-instance-1/my.cnf'
        )
    end

    it 'creates directory[instance-1 :create /opt/mysql56/etc/mysql-instance-1]' do
      expect(omnios_151006_service_56_multi).to create_directory('instance-1 :create /opt/mysql56/etc/mysql-instance-1')
        .with(
          path: '/opt/mysql56/etc/mysql-instance-1',
          owner: 'alice',
          group: 'alice',
          mode: '0750',
          recursive: true
        )
    end

    it 'creates directory[instance-1 :create /opt/mysql56/etc/mysql-instance-1/conf.d]' do
      expect(omnios_151006_service_56_multi).to create_directory('instance-1 :create /opt/mysql56/etc/mysql-instance-1/conf.d')
        .with(
          path: '/opt/mysql56/etc/mysql-instance-1/conf.d',
          owner: 'alice',
          group: 'alice',
          mode: '0750',
          recursive: true
        )
    end

    it 'creates directory[instance-1 :create /var/run/mysql-instance-1]' do
      expect(omnios_151006_service_56_multi).to create_directory('instance-1 :create /var/run/mysql-instance-1')
        .with(
          path: '/var/run/mysql-instance-1',
          owner: 'alice',
          group: 'alice',
          mode: '0755',
          recursive: true
        )
    end

    it 'creates directory[instance-1 :create /var/adm/log/mysql-instance-1]' do
      expect(omnios_151006_service_56_multi).to create_directory('instance-1 :create /var/adm/log/mysql-instance-1')
        .with(
          path: '/var/adm/log/mysql-instance-1',
          owner: 'alice',
          group: 'alice',
          mode: '0750',
          recursive: true
        )
    end

    it 'creates directory[instance-1 :create /data/instance-1]' do
      expect(omnios_151006_service_56_multi).to create_directory('instance-1 :create /data/instance-1')
        .with(
          path: '/data/instance-1',
          owner: 'alice',
          group: 'alice',
          mode: '0750',
          recursive: true
        )
    end

    it 'creates template[instance-1 :create /opt/mysql56/etc/mysql-instance-1/my.cnf]' do
      expect(omnios_151006_service_56_multi).to create_template('instance-1 :create /opt/mysql56/etc/mysql-instance-1/my.cnf')
        .with(
          path: '/opt/mysql56/etc/mysql-instance-1/my.cnf',
          owner: 'alice',
          group: 'alice',
          mode: '0600'
        )
    end

    it 'runs bash[instance-1 :create initialize mysql database]' do
      expect(omnios_151006_service_56_multi).to_not run_bash('instance-1 :create initialize mysql database')
        .with(
          cwd: '/opt/local/lib/mysql-instance-1'
        )
    end

    it 'runs bash[instance-1 :create initial records]' do
      expect(omnios_151006_service_56_multi).to_not run_bash('instance-1 :create initial records')
    end

    it 'create template[instance-1 :start /lib/svc/method/mysql-instance-1]' do
      expect(omnios_151006_service_56_multi).to create_template('instance-1 :start /lib/svc/method/mysql-instance-1')
        .with(
          path: '/lib/svc/method/mysql-instance-1',
          source: 'smf/svc.method.mysqld.erb',
          owner: 'root',
          group: 'root',
          mode: '0555',
          cookbook: 'mysql'
        )
    end

    it 'create template[instance-1 :start /lib/svc/method/mysql-instance-1]' do
      expect(omnios_151006_service_56_multi).to install_smf('mysql-instance-1')
        .with(
          name: 'mysql-instance-1',
          user: 'alice',
          group: 'alice',
          start_command: '/lib/svc/method/mysql-instance-1 start'
        )
    end

    it 'starts service[instance-1 :start mysql-instance-1]' do
      expect(omnios_151006_service_56_multi).to enable_service('instance-1 :start mysql-instance-1')
        .with(
          service_name: 'mysql-instance-1',
          provider: Chef::Provider::Service::Solaris
        )
    end
  end

  # mysql_service resource internal implementation
  context 'stepping into mysql_service[instance-2] resource' do
    it 'installs package[instance-2 :create database/mysql-56]' do
      expect(omnios_151006_service_56_multi).to install_package('instance-2 :create database/mysql-56')
        .with(package_name: 'database/mysql-56', version: nil)
    end

    it 'creates group[instance-2 :create mysql]' do
      expect(omnios_151006_service_56_multi).to create_group('instance-2 :create mysql')
        .with(group_name: 'mysql')
    end

    it 'creates user[instance-2 :create mysql]' do
      expect(omnios_151006_service_56_multi).to create_user('instance-2 :create mysql')
        .with(username: 'mysql')
    end

    it 'deletes file[instance-2 :create /opt/mysql56/etc/mysql/my.cnf]' do
      expect(omnios_151006_service_56_multi).to delete_file('instance-2 :create /opt/mysql56/etc/mysql/my.cnf')
        .with(path: '/opt/mysql56/etc/mysql/my.cnf')
    end

    it 'deletes file[instance-2 :create /opt/mysql56/etc/my.cnf]' do
      expect(omnios_151006_service_56_multi).to delete_file('instance-2 :create /opt/mysql56/etc/my.cnf')
        .with(path: '/opt/mysql56/etc/my.cnf')
    end

    it 'creates link[instance-2 :create /opt/mysql56/usr/share/my-default.cnf]' do
      expect(omnios_151006_service_56_multi).to create_link('instance-2 :create /opt/mysql56/usr/share/my-default.cnf')
        .with(
          target_file: '/opt/mysql56/usr/share/my-default.cnf',
          to: '/opt/mysql56/etc/mysql-instance-2/my.cnf'
        )
    end

    it 'creates directory[instance-2 :create /opt/mysql56/etc/mysql-instance-2]' do
      expect(omnios_151006_service_56_multi).to create_directory('instance-2 :create /opt/mysql56/etc/mysql-instance-2')
        .with(
          path: '/opt/mysql56/etc/mysql-instance-2',
          owner: 'bob',
          group: 'bob',
          mode: '0750',
          recursive: true
        )
    end

    it 'creates directory[instance-2 :create /opt/mysql56/etc/mysql-instance-2/conf.d]' do
      expect(omnios_151006_service_56_multi).to create_directory('instance-2 :create /opt/mysql56/etc/mysql-instance-2/conf.d')
        .with(
          path: '/opt/mysql56/etc/mysql-instance-2/conf.d',
          owner: 'bob',
          group: 'bob',
          mode: '0750',
          recursive: true
        )
    end

    it 'creates directory[instance-2 :create /var/run/mysql-instance-2]' do
      expect(omnios_151006_service_56_multi).to create_directory('instance-2 :create /var/run/mysql-instance-2')
        .with(
          path: '/var/run/mysql-instance-2',
          owner: 'bob',
          group: 'bob',
          mode: '0755',
          recursive: true
        )
    end

    it 'creates directory[instance-2 :create /var/adm/log/mysql-instance-2]' do
      expect(omnios_151006_service_56_multi).to create_directory('instance-2 :create /var/adm/log/mysql-instance-2')
        .with(
          path: '/var/adm/log/mysql-instance-2',
          owner: 'bob',
          group: 'bob',
          mode: '0750',
          recursive: true
        )
    end

    it 'creates directory[instance-2 :create /data/instance-2]' do
      expect(omnios_151006_service_56_multi).to create_directory('instance-2 :create /data/instance-2')
        .with(
          path: '/data/instance-2',
          owner: 'bob',
          group: 'bob',
          mode: '0750',
          recursive: true
        )
    end

    it 'creates template[instance-2 :create /opt/mysql56/etc/mysql-instance-2/my.cnf]' do
      expect(omnios_151006_service_56_multi).to create_template('instance-2 :create /opt/mysql56/etc/mysql-instance-2/my.cnf')
        .with(
          path: '/opt/mysql56/etc/mysql-instance-2/my.cnf',
          owner: 'bob',
          group: 'bob',
          mode: '0600'
        )
    end

    it 'runs bash[instance-2 :create initialize mysql database]' do
      expect(omnios_151006_service_56_multi).to_not run_bash('instance-2 :create initialize mysql database')
        .with(
          cwd: '/opt/local/lib/mysql-instance-2'
        )
    end

    it 'runs bash[instance-2 :create initial records]' do
      expect(omnios_151006_service_56_multi).to_not run_bash('instance-2 :create initial records')
    end

    it 'create template[instance-2 :start /lib/svc/method/mysql-instance-2]' do
      expect(omnios_151006_service_56_multi).to create_template('instance-2 :start /lib/svc/method/mysql-instance-2')
        .with(
          path: '/lib/svc/method/mysql-instance-2',
          source: 'smf/svc.method.mysqld.erb',
          owner: 'root',
          group: 'root',
          mode: '0555',
          cookbook: 'mysql'
        )
    end

    it 'create template[instance-2 :start /lib/svc/method/mysql-instance-2]' do
      expect(omnios_151006_service_56_multi).to install_smf('mysql-instance-2')
        .with(
          name: 'mysql-instance-2',
          user: 'bob',
          group: 'bob',
          start_command: '/lib/svc/method/mysql-instance-2 start'
        )
    end

    it 'starts service[instance-2 :start mysql-instance-2]' do
      expect(omnios_151006_service_56_multi).to enable_service('instance-2 :start mysql-instance-2')
        .with(
          service_name: 'mysql-instance-2',
          provider: Chef::Provider::Service::Solaris
        )
    end
  end
end
