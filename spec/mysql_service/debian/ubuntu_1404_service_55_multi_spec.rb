require 'spec_helper'

describe 'mysql_service_test::single on ubuntu-14.04' do
  cached(:ubuntu_1404_service_55_multi) do
    ChefSpec::SoloRunner.new(
      platform: 'ubuntu',
      version: '14.04',
      step_into: 'mysql_service'
    ) do |node|
      node.set['mysql']['version'] = '5.5'
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

  #
  # Resource in mysql_service_test::single
  #
  context 'compiling the test recipe' do
    it 'creates user[alice]' do
      expect(ubuntu_1404_service_55_multi).to create_user('alice')
    end

    it 'creates group[alice]' do
      expect(ubuntu_1404_service_55_multi).to create_group('alice')
    end

    it 'creates user[bob]' do
      expect(ubuntu_1404_service_55_multi).to create_user('bob')
    end

    it 'creates group[bob]' do
      expect(ubuntu_1404_service_55_multi).to create_group('bob')
    end

    it 'deletes mysql_service[default]' do
      expect(ubuntu_1404_service_55_multi).to delete_mysql_service('default')
    end

    it 'creates mysql_service[instance-1]' do
      expect(ubuntu_1404_service_55_multi).to create_mysql_service('instance-1')
    end

    it 'creates mysql_service[instance-2]' do
      expect(ubuntu_1404_service_55_multi).to create_mysql_service('instance-2')
    end
  end

  #
  # mysql_service resource action implementations
  #

  # mysql_service action :delete mysql-default
  context 'stepping into mysql_service[default] resource' do
    it 'stops service[default :delete mysql-default]' do
      expect(ubuntu_1404_service_55_multi).to_not disable_service('default :delete mysql-default')
      expect(ubuntu_1404_service_55_multi).to_not stop_service('default :delete mysql-default')
    end

    it 'deletes directory[default :delete /etc/mysql-default]' do
      expect(ubuntu_1404_service_55_multi).to delete_directory('default :delete /etc/mysql-default')
    end

    it 'deletes directory[default :delete /run/mysql-default]' do
      expect(ubuntu_1404_service_55_multi).to delete_directory('default :delete /run/mysql-default')
    end

    it 'deletes directory[default :delete /var/log/mysql-default]' do
      expect(ubuntu_1404_service_55_multi).to delete_directory('default :delete /var/log/mysql-default')
    end
  end

  # mysql_service[instance-1] with action [:create, :start]
  context 'stepping into mysql_service[instance-1] resource' do
    it 'installs package[instance-1 :create mysql-server-5.5]' do
      expect(ubuntu_1404_service_55_multi).to install_package('instance-1 :create mysql-server-5.5')
        .with(package_name: 'mysql-server-5.5', version: nil)
    end

    it 'stops service[instance-1 :create mysql]' do
      expect(ubuntu_1404_service_55_multi).to disable_service('instance-1 :create mysql')
      expect(ubuntu_1404_service_55_multi).to stop_service('instance-1 :create mysql')
    end

    it 'installs package[instance-1 :create apparmor]' do
      expect(ubuntu_1404_service_55_multi).to install_package('instance-1 :create apparmor')
        .with(package_name: 'apparmor', version: nil)
    end

    it 'creates directory[instance-1 :create /etc/apparmor.d/local/mysql]' do
      expect(ubuntu_1404_service_55_multi).to create_directory('instance-1 :create /etc/apparmor.d/local/mysql')
        .with(
          path: '/etc/apparmor.d/local/mysql',
          owner: 'root',
          group: 'root',
          mode: '0755',
          recursive: true
        )
    end

    it 'creates template[instance-1 :create /etc/apparmor.d/local/usr.sbin.mysqld]' do
      expect(ubuntu_1404_service_55_multi).to create_template('instance-1 :create /etc/apparmor.d/local/usr.sbin.mysqld')
        .with(
          path: '/etc/apparmor.d/local/usr.sbin.mysqld',
          cookbook: 'mysql',
          source: 'apparmor/usr.sbin.mysqld-local.erb',
          owner: 'root',
          group: 'root',
          mode: '0644'
        )
    end

    it 'creates template[instance-1 :create /etc/apparmor.d/usr.sbin.mysqld]' do
      expect(ubuntu_1404_service_55_multi).to create_template('instance-1 :create /etc/apparmor.d/usr.sbin.mysqld')
        .with(
          path: '/etc/apparmor.d/usr.sbin.mysqld',
          cookbook: 'mysql',
          source: 'apparmor/usr.sbin.mysqld.erb',
          owner: 'root',
          group: 'root',
          mode: '0644'
        )
    end

    it 'creates template[instance-1 :create /etc/apparmor.d/local/mysql/instance-1]' do
      expect(ubuntu_1404_service_55_multi).to create_template('instance-1 :create /etc/apparmor.d/local/mysql/instance-1')
        .with(
          path: '/etc/apparmor.d/local/mysql/instance-1',
          cookbook: 'mysql',
          source: 'apparmor/usr.sbin.mysqld-instance.erb',
          owner: 'root',
          group: 'root',
          mode: '0644'
        )
    end

    it 'creates service[instance-1 :create apparmor]' do
      expect(ubuntu_1404_service_55_multi).to_not start_service('instance-1 :create apparmor').with(
        service_name: 'apparmor'
      )
    end

    it 'creates group[instance-1 :create mysql]' do
      expect(ubuntu_1404_service_55_multi).to create_group('instance-1 :create mysql')
        .with(group_name: 'mysql')
    end

    it 'creates user[instance-1 :create mysql]' do
      expect(ubuntu_1404_service_55_multi).to create_user('instance-1 :create mysql')
        .with(username: 'mysql')
    end

    it 'deletes file[instance-1 :create /etc/mysql/my.cnf]' do
      expect(ubuntu_1404_service_55_multi).to delete_file('instance-1 :create /etc/mysql/my.cnf')
        .with(path: '/etc/mysql/my.cnf')
    end

    it 'deletes file[instance-1 :create /etc/my.cnf]' do
      expect(ubuntu_1404_service_55_multi).to delete_file('instance-1 :create /etc/my.cnf')
        .with(path: '/etc/my.cnf')
    end

    it 'creates link[instance-1 :create /usr/share/my-default.cnf]' do
      expect(ubuntu_1404_service_55_multi).to create_link('instance-1 :create /usr/share/my-default.cnf')
        .with(
          target_file: '/usr/share/my-default.cnf',
          to: '/etc/mysql-instance-1/my.cnf'
        )
    end

    it 'creates directory[instance-1 :create /etc/mysql-instance-1]' do
      expect(ubuntu_1404_service_55_multi).to create_directory('instance-1 :create /etc/mysql-instance-1')
        .with(
          path: '/etc/mysql-instance-1',
          owner: 'alice',
          group: 'alice',
          mode: '0750',
          recursive: true
        )
    end

    it 'creates directory[instance-1 :create /etc/mysql-instance-1/conf.d]' do
      expect(ubuntu_1404_service_55_multi).to create_directory('instance-1 :create /etc/mysql-instance-1/conf.d')
        .with(
          path: '/etc/mysql-instance-1/conf.d',
          owner: 'alice',
          group: 'alice',
          mode: '0750',
          recursive: true
        )
    end

    it 'creates directory[instance-1 :create /run/mysql-instance-1]' do
      expect(ubuntu_1404_service_55_multi).to create_directory('instance-1 :create /run/mysql-instance-1')
        .with(
          path: '/run/mysql-instance-1',
          owner: 'alice',
          group: 'alice',
          mode: '0755',
          recursive: true
        )
    end

    it 'creates directory[instance-1 :create /var/log/mysql-instance-1]' do
      expect(ubuntu_1404_service_55_multi).to create_directory('instance-1 :create /var/log/mysql-instance-1')
        .with(
          path: '/var/log/mysql-instance-1',
          owner: 'alice',
          group: 'alice',
          mode: '0750',
          recursive: true
        )
    end

    it 'creates directory[instance-1 :create /data/instance-1]' do
      expect(ubuntu_1404_service_55_multi).to create_directory('instance-1 :create /data/instance-1')
        .with(
          path: '/data/instance-1',
          owner: 'alice',
          group: 'alice',
          mode: '0750',
          recursive: true
        )
    end

    it 'creates template[instance-1 :create /etc/mysql-instance-1/my.cnf]' do
      expect(ubuntu_1404_service_55_multi).to create_template('instance-1 :create /etc/mysql-instance-1/my.cnf')
        .with(
          path: '/etc/mysql-instance-1/my.cnf',
          owner: 'alice',
          group: 'alice',
          mode: '0600'
        )
    end

    it 'runs bash[instance-1 :create initialize mysql database]' do
      expect(ubuntu_1404_service_55_multi).to_not run_bash('instance-1 :create initialize mysql database')
        .with(
          cwd: '/data/instance-1'
        )
    end

    it 'runs bash[instance-1 :create initial records]' do
      expect(ubuntu_1404_service_55_multi).to_not run_bash('instance-1 :create initial records')
    end

    it 'creates template[instance-1 :create /usr/sbin/mysql-instance-1-wait-ready]' do
      expect(ubuntu_1404_service_55_multi).to create_template('instance-1 :start /usr/sbin/mysql-instance-1-wait-ready')
        .with(
          path: '/usr/sbin/mysql-instance-1-wait-ready',
          source: 'upstart/mysqld-wait-ready.erb',
          owner: 'root',
          group: 'root',
          mode: '0755',
          cookbook: 'mysql'
        )
    end

    it 'creates template[instance-1 :create /etc/init/mysql-instance-1.conf]' do
      expect(ubuntu_1404_service_55_multi).to create_template('instance-1 :start /etc/init/mysql-instance-1.conf')
        .with(
          path: '/etc/init/mysql-instance-1.conf',
          source: 'upstart/mysqld.erb',
          owner: 'root',
          group: 'root',
          mode: '0644',
          cookbook: 'mysql'
        )
    end

    it 'starts service[instance-1 :start mysql-instance-1]' do
      expect(ubuntu_1404_service_55_multi).to start_service('instance-1 :start mysql-instance-1')
        .with(
          service_name: 'mysql-instance-1',
          provider: Chef::Provider::Service::Upstart
        )
    end
  end

  # mysql_service[instance-2] with action [:create, :start]
  context 'stepping into mysql_service[instance-2] resource' do
    it 'installs package[instance-2 :create mysql-server-5.5]' do
      expect(ubuntu_1404_service_55_multi).to install_package('instance-2 :create mysql-server-5.5')
        .with(package_name: 'mysql-server-5.5', version: nil)
    end

    it 'stops service[instance-2 :create mysql]' do
      expect(ubuntu_1404_service_55_multi).to disable_service('instance-2 :create mysql')
      expect(ubuntu_1404_service_55_multi).to stop_service('instance-2 :create mysql')
    end

    it 'installs package[instance-2 :create apparmor]' do
      expect(ubuntu_1404_service_55_multi).to install_package('instance-2 :create apparmor')
        .with(package_name: 'apparmor', version: nil)
    end

    it 'creates directory[instance-2 :create /etc/apparmor.d/local/mysql]' do
      expect(ubuntu_1404_service_55_multi).to create_directory('instance-2 :create /etc/apparmor.d/local/mysql')
        .with(
          path: '/etc/apparmor.d/local/mysql',
          owner: 'root',
          group: 'root',
          mode: '0755',
          recursive: true
        )
    end

    it 'creates template[instance-2 :create /etc/apparmor.d/local/usr.sbin.mysqld]' do
      expect(ubuntu_1404_service_55_multi).to create_template('instance-2 :create /etc/apparmor.d/local/usr.sbin.mysqld')
        .with(
          path: '/etc/apparmor.d/local/usr.sbin.mysqld',
          cookbook: 'mysql',
          source: 'apparmor/usr.sbin.mysqld-local.erb',
          owner: 'root',
          group: 'root',
          mode: '0644'
        )
    end

    it 'creates template[instance-2 :create /etc/apparmor.d/usr.sbin.mysqld]' do
      expect(ubuntu_1404_service_55_multi).to create_template('instance-2 :create /etc/apparmor.d/usr.sbin.mysqld')
        .with(
          path: '/etc/apparmor.d/usr.sbin.mysqld',
          cookbook: 'mysql',
          source: 'apparmor/usr.sbin.mysqld.erb',
          owner: 'root',
          group: 'root',
          mode: '0644'
        )
    end

    it 'creates template[instance-2 :create /etc/apparmor.d/local/mysql/instance-2]' do
      expect(ubuntu_1404_service_55_multi).to create_template('instance-2 :create /etc/apparmor.d/local/mysql/instance-2')
        .with(
          path: '/etc/apparmor.d/local/mysql/instance-2',
          cookbook: 'mysql',
          source: 'apparmor/usr.sbin.mysqld-instance.erb',
          owner: 'root',
          group: 'root',
          mode: '0644'
        )
    end

    it 'creates service[instance-2 :create apparmor]' do
      expect(ubuntu_1404_service_55_multi).to_not start_service('instance-2 :create apparmor').with(
        service_name: 'apparmor'
      )
    end

    it 'creates group[instance-2 :create mysql]' do
      expect(ubuntu_1404_service_55_multi).to create_group('instance-2 :create mysql')
        .with(group_name: 'mysql')
    end

    it 'creates user[instance-2 :create mysql]' do
      expect(ubuntu_1404_service_55_multi).to create_user('instance-2 :create mysql')
        .with(username: 'mysql')
    end

    it 'deletes file[instance-2 :create /etc/mysql/my.cnf]' do
      expect(ubuntu_1404_service_55_multi).to delete_file('instance-2 :create /etc/mysql/my.cnf')
        .with(path: '/etc/mysql/my.cnf')
    end

    it 'deletes file[instance-2 :create /etc/my.cnf]' do
      expect(ubuntu_1404_service_55_multi).to delete_file('instance-2 :create /etc/my.cnf')
        .with(path: '/etc/my.cnf')
    end

    it 'creates link[instance-2 :create /usr/share/my-default.cnf]' do
      expect(ubuntu_1404_service_55_multi).to create_link('instance-2 :create /usr/share/my-default.cnf')
        .with(
          target_file: '/usr/share/my-default.cnf',
          to: '/etc/mysql-instance-2/my.cnf'
        )
    end

    it 'creates directory[instance-2 :create /etc/mysql-instance-2]' do
      expect(ubuntu_1404_service_55_multi).to create_directory('instance-2 :create /etc/mysql-instance-2')
        .with(
          path: '/etc/mysql-instance-2',
          owner: 'bob',
          group: 'bob',
          mode: '0750',
          recursive: true
        )
    end

    it 'creates directory[instance-2 :create /etc/mysql-instance-2/conf.d]' do
      expect(ubuntu_1404_service_55_multi).to create_directory('instance-2 :create /etc/mysql-instance-2/conf.d')
        .with(
          path: '/etc/mysql-instance-2/conf.d',
          owner: 'bob',
          group: 'bob',
          mode: '0750',
          recursive: true
        )
    end

    it 'creates directory[instance-2 :create /run/mysql-instance-2]' do
      expect(ubuntu_1404_service_55_multi).to create_directory('instance-2 :create /run/mysql-instance-2')
        .with(
          path: '/run/mysql-instance-2',
          owner: 'bob',
          group: 'bob',
          mode: '0755',
          recursive: true
        )
    end

    it 'creates directory[instance-2 :create /var/log/mysql-instance-2]' do
      expect(ubuntu_1404_service_55_multi).to create_directory('instance-2 :create /var/log/mysql-instance-2')
        .with(
          path: '/var/log/mysql-instance-2',
          owner: 'bob',
          group: 'bob',
          mode: '0750',
          recursive: true
        )
    end

    it 'creates directory[instance-2 :create /data/instance-2]' do
      expect(ubuntu_1404_service_55_multi).to create_directory('instance-2 :create /data/instance-2')
        .with(
          path: '/data/instance-2',
          owner: 'bob',
          group: 'bob',
          mode: '0750',
          recursive: true
        )
    end

    it 'creates template[instance-2 :create /etc/mysql-instance-2/my.cnf]' do
      expect(ubuntu_1404_service_55_multi).to create_template('instance-2 :create /etc/mysql-instance-2/my.cnf')
        .with(
          path: '/etc/mysql-instance-2/my.cnf',
          owner: 'bob',
          group: 'bob',
          mode: '0600'
        )
    end

    it 'runs bash[instance-2 :create initialize mysql database]' do
      expect(ubuntu_1404_service_55_multi).to_not run_bash('instance-2 :create initialize mysql database')
        .with(
          cwd: '/data/instance-2'
        )
    end

    it 'runs bash[instance-2 :create initial records]' do
      expect(ubuntu_1404_service_55_multi).to_not run_bash('instance-2 :create initial records')
    end

    it 'creates template[instance-2 :create /usr/sbin/mysql-instance-2-wait-ready]' do
      expect(ubuntu_1404_service_55_multi).to create_template('instance-2 :start /usr/sbin/mysql-instance-2-wait-ready')
        .with(
          path: '/usr/sbin/mysql-instance-2-wait-ready',
          source: 'upstart/mysqld-wait-ready.erb',
          owner: 'root',
          group: 'root',
          mode: '0755',
          cookbook: 'mysql'
        )
    end

    it 'creates template[instance-2 :create /etc/init/mysql-instance-2.conf]' do
      expect(ubuntu_1404_service_55_multi).to create_template('instance-2 :start /etc/init/mysql-instance-2.conf')
        .with(
          path: '/etc/init/mysql-instance-2.conf',
          source: 'upstart/mysqld.erb',
          owner: 'root',
          group: 'root',
          mode: '0644',
          cookbook: 'mysql'
        )
    end

    it 'starts service[instance-2 :start mysql-instance-2]' do
      expect(ubuntu_1404_service_55_multi).to start_service('instance-2 :start mysql-instance-2')
        .with(
          service_name: 'mysql-instance-2',
          provider: Chef::Provider::Service::Upstart
        )
    end
  end
end
