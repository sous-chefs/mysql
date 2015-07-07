require 'spec_helper'

describe 'mysql_service_test::single on centos-5.8' do
  cached(:centos_58_service_51_multi) do
    ChefSpec::SoloRunner.new(
      platform: 'centos',
      version: '5.8',
      step_into: 'mysql_service'
    ) do |node|
      node.set['mysql']['version'] = '5.1'
      node.set['mysql']['port'] = '3308'
      node.set['mysql']['data_dir'] = '/data/instance-2'
      node.set['mysql']['run_user'] = 'bob'
      node.set['mysql']['run_group'] = 'bob'
      node.set['mysql']['initial_root_password'] = 'string with spaces'
    end.converge('mysql_service_test::multi')
  end

  before do
    allow(Chef::Platform::ServiceHelpers).to receive(:service_resource_providers).and_return([:redhat])
    stub_command('/usr/bin/test -f /data/instance-1/mysql/user.frm').and_return(true)
    stub_command('/usr/bin/test -f /data/instance-2/mysql/user.frm').and_return(true)
  end

  #
  # Resource in mysql_service_test::single
  #
  context 'compiling the test recipe' do
    it 'creates user[alice]' do
      expect(centos_58_service_51_multi).to create_user('alice')
    end

    it 'creates group[alice]' do
      expect(centos_58_service_51_multi).to create_group('alice')
    end

    it 'creates user[bob]' do
      expect(centos_58_service_51_multi).to create_user('bob')
    end

    it 'creates group[bob]' do
      expect(centos_58_service_51_multi).to create_group('bob')
    end

    it 'deletes mysql_service[default]' do
      expect(centos_58_service_51_multi).to delete_mysql_service('default')
    end

    it 'creates mysql_service[instance-1]' do
      expect(centos_58_service_51_multi).to create_mysql_service('instance-1')
    end

    it 'creates mysql_service[instance-2]' do
      expect(centos_58_service_51_multi).to create_mysql_service('instance-2')
    end
  end

  #
  # mysql_service resource action implementations
  #

  # mysql_service action :delete mysql-default
  context 'stepping into mysql_service[default] resource' do
    it 'stops service[default :delete mysql-default]' do
      expect(centos_58_service_51_multi).to_not disable_service('default :delete mysql-default')
      expect(centos_58_service_51_multi).to_not stop_service('default :delete mysql-default')
    end

    it 'deletes directory[default :delete /etc/mysql-default]' do
      expect(centos_58_service_51_multi).to delete_directory('default :delete /etc/mysql-default')
    end

    it 'deletes directory[default :delete /var/run/mysql-default]' do
      expect(centos_58_service_51_multi).to delete_directory('default :delete /var/run/mysql-default')
    end

    it 'deletes directory[default :delete /var/log/mysql-default]' do
      expect(centos_58_service_51_multi).to delete_directory('default :delete /var/log/mysql-default')
    end
  end

  # mysql_service[instance-1] with action [:create, :start]
  context 'stepping into mysql_service[instance-1] resource' do
    it 'installs package[instance-1 :create mysqld51-mysql-server]' do
      expect(centos_58_service_51_multi).to install_package('instance-1 :create mysql51-mysql-server')
        .with(package_name: 'mysql51-mysql-server', version: nil)
    end

    it 'stops service[instance-1 :create mysql51-mysqld]' do
      expect(centos_58_service_51_multi).to disable_service('instance-1 :create mysql51-mysqld')
      expect(centos_58_service_51_multi).to stop_service('instance-1 :create mysql51-mysqld')
    end

    it 'creates group[instance-1 :create mysql]' do
      expect(centos_58_service_51_multi).to create_group('instance-1 :create mysql')
        .with(group_name: 'mysql')
    end

    it 'creates user[instance-1 :create mysql]' do
      expect(centos_58_service_51_multi).to create_user('instance-1 :create mysql')
        .with(username: 'mysql')
    end

    it 'deletes file[instance-1 :create /opt/rh/mysql51/root/etc/mysql/my.cnf]' do
      expect(centos_58_service_51_multi).to delete_file('instance-1 :create /opt/rh/mysql51/root/etc/mysql/my.cnf')
        .with(path: '/opt/rh/mysql51/root/etc/mysql/my.cnf')
    end

    it 'deletes file[instance-1 :create /opt/rh/mysql51/root/etc/my.cnf]' do
      expect(centos_58_service_51_multi).to delete_file('instance-1 :create /opt/rh/mysql51/root/etc/my.cnf')
        .with(path: '/opt/rh/mysql51/root/etc/my.cnf')
    end

    it 'creates link[instance-1 :create /opt/rh/mysql51/root/usr/share/my-default.cnf]' do
      expect(centos_58_service_51_multi).to create_link('instance-1 :create /opt/rh/mysql51/root/usr/share/my-default.cnf')
        .with(
          target_file: '/opt/rh/mysql51/root/usr/share/my-default.cnf',
          to: '/opt/rh/mysql51/root/etc/mysql-instance-1/my.cnf'
        )
    end

    it 'creates directory[instance-1 :create /opt/rh/mysql51/root/etc/mysql-instance-1]' do
      expect(centos_58_service_51_multi).to create_directory('instance-1 :create /opt/rh/mysql51/root/etc/mysql-instance-1')
        .with(
          path: '/opt/rh/mysql51/root/etc/mysql-instance-1',
          owner: 'alice',
          group: 'alice',
          mode: '0750',
          recursive: true
        )
    end

    it 'creates directory[instance-1 :create /opt/rh/mysql51/root/etc/mysql-instance-1/conf.d]' do
      expect(centos_58_service_51_multi).to create_directory('instance-1 :create /opt/rh/mysql51/root/etc/mysql-instance-1/conf.d')
        .with(
          path: '/opt/rh/mysql51/root/etc/mysql-instance-1/conf.d',
          owner: 'alice',
          group: 'alice',
          mode: '0750',
          recursive: true
        )
    end

    it 'creates directory[instance-1 :create /opt/rh/mysql51/root/var/run/mysql-instance-1]' do
      expect(centos_58_service_51_multi).to create_directory('instance-1 :create /opt/rh/mysql51/root/var/run/mysql-instance-1')
        .with(
          path: '/opt/rh/mysql51/root/var/run/mysql-instance-1',
          owner: 'alice',
          group: 'alice',
          mode: '0755',
          recursive: true
        )
    end

    it 'creates directory[instance-1 :create /opt/rh/mysql51/root/var/log/mysql-instance-1]' do
      expect(centos_58_service_51_multi).to create_directory('instance-1 :create /opt/rh/mysql51/root/var/log/mysql-instance-1')
        .with(
          path: '/opt/rh/mysql51/root/var/log/mysql-instance-1',
          owner: 'alice',
          group: 'alice',
          mode: '0750',
          recursive: true
        )
    end

    it 'creates directory[instance-1 :create /data/instance-1]' do
      expect(centos_58_service_51_multi).to create_directory('instance-1 :create /data/instance-1')
        .with(
          path: '/data/instance-1',
          owner: 'alice',
          group: 'alice',
          mode: '0750',
          recursive: true
        )
    end

    it 'creates template[instance-1 :create /opt/rh/mysql51/root/etc/mysql-instance-1/my.cnf]' do
      expect(centos_58_service_51_multi).to create_template('instance-1 :create /opt/rh/mysql51/root/etc/mysql-instance-1/my.cnf')
        .with(
          path: '/opt/rh/mysql51/root/etc/mysql-instance-1/my.cnf',
          owner: 'alice',
          group: 'alice',
          mode: '0600'
        )
    end

    it 'runs bash[instance-1 :create initialize mysql database]' do
      expect(centos_58_service_51_multi).to_not run_bash('instance-1 :create initialize mysql database')
        .with(
          cwd: '/data/instance-1'
        )
    end

    it 'runs bash[instance-1 :create initial records]' do
      expect(centos_58_service_51_multi).to_not run_bash('instance-1 :create initial records')
    end

    it 'create template[instance-1 :start /etc/init.d/mysql-instance-1]' do
      expect(centos_58_service_51_multi).to create_template('instance-1 :start /etc/init.d/mysql-instance-1')
        .with(
          path: '/etc/init.d/mysql-instance-1',
          source: 'sysvinit/mysqld.erb',
          owner: 'root',
          group: 'root',
          mode: '0755',
          cookbook: 'mysql'
        )
    end

    it 'starts service[instance-1 :start mysql-instance-1]' do
      expect(centos_58_service_51_multi).to start_service('instance-1 :start mysql-instance-1')
        .with(
          service_name: 'mysql-instance-1'
        )
    end
  end

  # mysql_service[instance-2] with action [:create, :start]
  context 'stepping into mysql_service[instance-2] resource' do
    it 'installs package[instance-2 :create mysqld51-mysql-server]' do
      expect(centos_58_service_51_multi).to install_package('instance-2 :create mysql51-mysql-server')
        .with(package_name: 'mysql51-mysql-server', version: nil)
    end

    it 'stops service[instance-2 :create mysql51-mysqld]' do
      expect(centos_58_service_51_multi).to disable_service('instance-2 :create mysql51-mysqld')
      expect(centos_58_service_51_multi).to stop_service('instance-2 :create mysql51-mysqld')
    end

    it 'creates group[instance-2 :create mysql]' do
      expect(centos_58_service_51_multi).to create_group('instance-2 :create mysql')
        .with(group_name: 'mysql')
    end

    it 'creates user[instance-2 :create mysql]' do
      expect(centos_58_service_51_multi).to create_user('instance-2 :create mysql')
        .with(username: 'mysql')
    end

    it 'deletes file[instance-2 :create /opt/rh/mysql51/root/etc/mysql/my.cnf]' do
      expect(centos_58_service_51_multi).to delete_file('instance-2 :create /opt/rh/mysql51/root/etc/mysql/my.cnf')
        .with(path: '/opt/rh/mysql51/root/etc/mysql/my.cnf')
    end

    it 'deletes file[instance-2 :create /opt/rh/mysql51/root/etc/my.cnf]' do
      expect(centos_58_service_51_multi).to delete_file('instance-2 :create /opt/rh/mysql51/root/etc/my.cnf')
        .with(path: '/opt/rh/mysql51/root/etc/my.cnf')
    end

    it 'creates link[instance-2 :create /opt/rh/mysql51/root/usr/share/my-default.cnf]' do
      expect(centos_58_service_51_multi).to create_link('instance-2 :create /opt/rh/mysql51/root/usr/share/my-default.cnf')
        .with(
          target_file: '/opt/rh/mysql51/root/usr/share/my-default.cnf',
          to: '/opt/rh/mysql51/root/etc/mysql-instance-2/my.cnf'
        )
    end

    it 'creates directory[instance-2 :create /opt/rh/mysql51/root/etc/mysql-instance-2]' do
      expect(centos_58_service_51_multi).to create_directory('instance-2 :create /opt/rh/mysql51/root/etc/mysql-instance-2')
        .with(
          path: '/opt/rh/mysql51/root/etc/mysql-instance-2',
          owner: 'bob',
          group: 'bob',
          mode: '0750',
          recursive: true
        )
    end

    it 'creates directory[instance-2 :create /opt/rh/mysql51/root/etc/mysql-instance-2/conf.d]' do
      expect(centos_58_service_51_multi).to create_directory('instance-2 :create /opt/rh/mysql51/root/etc/mysql-instance-2/conf.d')
        .with(
          path: '/opt/rh/mysql51/root/etc/mysql-instance-2/conf.d',
          owner: 'bob',
          group: 'bob',
          mode: '0750',
          recursive: true
        )
    end

    it 'creates directory[instance-2 :create /opt/rh/mysql51/root/var/run/mysql-instance-2]' do
      expect(centos_58_service_51_multi).to create_directory('instance-2 :create /opt/rh/mysql51/root/var/run/mysql-instance-2')
        .with(
          path: '/opt/rh/mysql51/root/var/run/mysql-instance-2',
          owner: 'bob',
          group: 'bob',
          mode: '0755',
          recursive: true
        )
    end

    it 'creates directory[instance-2 :create /opt/rh/mysql51/root/var/log/mysql-instance-2]' do
      expect(centos_58_service_51_multi).to create_directory('instance-2 :create /opt/rh/mysql51/root/var/log/mysql-instance-2')
        .with(
          path: '/opt/rh/mysql51/root/var/log/mysql-instance-2',
          owner: 'bob',
          group: 'bob',
          mode: '0750',
          recursive: true
        )
    end

    it 'creates directory[instance-2 :create /data/instance-2]' do
      expect(centos_58_service_51_multi).to create_directory('instance-2 :create /data/instance-2')
        .with(
          path: '/data/instance-2',
          owner: 'bob',
          group: 'bob',
          mode: '0750',
          recursive: true
        )
    end

    it 'creates template[instance-2 :create /opt/rh/mysql51/root/etc/mysql-instance-2/my.cnf]' do
      expect(centos_58_service_51_multi).to create_template('instance-2 :create /opt/rh/mysql51/root/etc/mysql-instance-2/my.cnf')
        .with(
          path: '/opt/rh/mysql51/root/etc/mysql-instance-2/my.cnf',
          owner: 'bob',
          group: 'bob',
          mode: '0600'
        )
    end

    it 'runs bash[instance-2 :create initialize mysql database]' do
      expect(centos_58_service_51_multi).to_not run_bash('instance-2 :create initialize mysql database')
        .with(
          cwd: '/data/instance-2'
        )
    end

    it 'runs bash[instance-2 :create initial records]' do
      expect(centos_58_service_51_multi).to_not run_bash('instance-2 :create initial records')
    end

    it 'create template[instance-2 :start /etc/init.d/mysql-instance-2]' do
      expect(centos_58_service_51_multi).to create_template('instance-2 :start /etc/init.d/mysql-instance-2')
        .with(
          path: '/etc/init.d/mysql-instance-2',
          source: 'sysvinit/mysqld.erb',
          owner: 'root',
          group: 'root',
          mode: '0755',
          cookbook: 'mysql'
        )
    end

    it 'starts service[instance-2 :start mysql-instance-2]' do
      expect(centos_58_service_51_multi).to start_service('instance-2 :start mysql-instance-2')
        .with(
          service_name: 'mysql-instance-2'
        )
    end
  end
end
