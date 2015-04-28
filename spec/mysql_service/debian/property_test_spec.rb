require 'spec_helper'

describe 'mysql_service_test::property_test on ubuntu-14.04' do
  cached(:property_test) do
    ChefSpec::SoloRunner.new(
      platform: 'ubuntu',
      version: '14.04',
      step_into: 'mysql_service'
    ) do |node|
      node.set['mysql']['version'] = '5.5'
      node.set['mysql']['socket'] = '/var/run/mysqld/mysqld.sock'
    end.converge('mysql_service_test::property_test')
  end

  let(:my_cnf_content) do
    <<-EOF
# Chef generated my.cnf for instance mysql-default

[client]
default-character-set          = utf8
port                           = 3306
socket                         = /var/run/mysqld/mysqld.sock

[mysql]
default-character-set          = utf8

[mysqld]
user                           = mysql
pid-file                       = /run/mysql-default/mysqld.pid
socket                         = /var/run/mysqld/mysqld.sock
port                           = 3306
datadir                        = /var/lib/mysql-default
tmpdir                         = /tmp
log-error                      = /var/log/mysql-default/error.log
!includedir /etc/mysql-default/conf.d

[mysqld_safe]
socket                         = /var/run/mysqld/mysqld.sock
EOF
  end

  before do
    stub_command('/usr/bin/test -f /var/lib/mysql-default/mysql/user.frm').and_return(true)
  end

  # Resource in mysql_service_test::single
  context 'compiling the test recipe' do
    it 'creates mysql_service[default]' do
      expect(property_test).to create_mysql_service('default')
    end
  end

  # mysql_service resource internal implementation
  context 'stepping into mysql_service[default] resource' do
    it 'installs package[default :create mysql-server-5.5]' do
      expect(property_test).to install_package('default :create mysql-server-5.5')
        .with(package_name: 'mysql-server-5.5', version: nil)
    end

    it 'stops service[default :create mysql]' do
      expect(property_test).to disable_service('default :create mysql')
      expect(property_test).to stop_service('default :create mysql')
    end

    it 'installs package[default :create apparmor]' do
      expect(property_test).to install_package('default :create apparmor')
        .with(package_name: 'apparmor', version: nil)
    end

    it 'creates directory[default :create /etc/apparmor.d/local/mysql]' do
      expect(property_test).to create_directory('default :create /etc/apparmor.d/local/mysql')
        .with(
          path: '/etc/apparmor.d/local/mysql',
          owner: 'root',
          group: 'root',
          mode: '0755',
          recursive: true
        )
    end

    it 'creates template[default :create /etc/apparmor.d/local/usr.sbin.mysqld]' do
      expect(property_test).to create_template('default :create /etc/apparmor.d/local/usr.sbin.mysqld')
        .with(
          path: '/etc/apparmor.d/local/usr.sbin.mysqld',
          cookbook: 'mysql',
          source: 'apparmor/usr.sbin.mysqld-local.erb',
          owner: 'root',
          group: 'root',
          mode: '0644'
        )
    end

    it 'creates template[default :create /etc/apparmor.d/usr.sbin.mysqld]' do
      expect(property_test).to create_template('default :create /etc/apparmor.d/usr.sbin.mysqld')
        .with(
          path: '/etc/apparmor.d/usr.sbin.mysqld',
          cookbook: 'mysql',
          source: 'apparmor/usr.sbin.mysqld.erb',
          owner: 'root',
          group: 'root',
          mode: '0644'
        )
    end

    it 'creates template[default :create /etc/apparmor.d/local/mysql/default]' do
      expect(property_test).to create_template('default :create /etc/apparmor.d/local/mysql/default')
        .with(
          path: '/etc/apparmor.d/local/mysql/default',
          cookbook: 'mysql',
          source: 'apparmor/usr.sbin.mysqld-instance.erb',
          owner: 'root',
          group: 'root',
          mode: '0644'
        )
    end

    it 'creates service[default :create apparmor]' do
      expect(property_test).to_not start_service('default :create apparmor').with(
        service_name: 'apparmor'
      )
    end

    it 'creates group[default :create mysql]' do
      expect(property_test).to create_group('default :create mysql')
        .with(group_name: 'mysql')
    end

    it 'creates user[default :create mysql]' do
      expect(property_test).to create_user('default :create mysql')
        .with(username: 'mysql')
    end

    it 'deletes file[default :create /etc/mysql/my.cnf]' do
      expect(property_test).to delete_file('default :create /etc/mysql/my.cnf')
        .with(path: '/etc/mysql/my.cnf')
    end

    it 'deletes file[default :create /etc/my.cnf]' do
      expect(property_test).to delete_file('default :create /etc/my.cnf')
        .with(path: '/etc/my.cnf')
    end

    it 'creates link[default :create /usr/share/my-default.cnf]' do
      expect(property_test).to create_link('default :create /usr/share/my-default.cnf')
        .with(
          target_file: '/usr/share/my-default.cnf',
          to: '/etc/mysql-default/my.cnf'
        )
    end

    it 'creates directory[default :create /etc/mysql-default]' do
      expect(property_test).to create_directory('default :create /etc/mysql-default')
        .with(
          path: '/etc/mysql-default',
          owner: 'mysql',
          group: 'mysql',
          mode: '0750',
          recursive: true
        )
    end

    it 'creates directory[default :create /etc/mysql-default/conf.d]' do
      expect(property_test).to create_directory('default :create /etc/mysql-default/conf.d')
        .with(
          path: '/etc/mysql-default/conf.d',
          owner: 'mysql',
          group: 'mysql',
          mode: '0750',
          recursive: true
        )
    end

    it 'creates directory[default :create /run/mysql-default]' do
      expect(property_test).to create_directory('default :create /run/mysql-default')
        .with(
          path: '/run/mysql-default',
          owner: 'mysql',
          group: 'mysql',
          mode: '0755',
          recursive: true
        )
    end

    it 'creates directory[default :create /var/log/mysql-default]' do
      expect(property_test).to create_directory('default :create /var/log/mysql-default')
        .with(
          path: '/var/log/mysql-default',
          owner: 'mysql',
          group: 'mysql',
          mode: '0750',
          recursive: true
        )
    end

    it 'creates directory[default :create /var/lib/mysql-default]' do
      expect(property_test).to create_directory('default :create /var/lib/mysql-default')
        .with(
          path: '/var/lib/mysql-default',
          owner: 'mysql',
          group: 'mysql',
          mode: '0750',
          recursive: true
        )
    end

    it 'creates template[default :create /etc/mysql-default/my.cnf]' do
      expect(property_test).to create_template('default :create /etc/mysql-default/my.cnf')
        .with(
          path: '/etc/mysql-default/my.cnf',
          owner: 'mysql',
          group: 'mysql',
          mode: '0600'
        )
    end

    it 'renders file[default :create /etc/mysql-default/my.cnf]' do
      expect(property_test).to render_file('default :create /etc/mysql-default/my.cnf')
        .with_content(my_cnf_content)
    end

    it 'runs bash[default :create initialize mysql database]' do
      expect(property_test).to_not run_bash('default :create initialize mysql database')
        .with(
          cwd: '/var/lib/mysql-default'
        )
    end

    it 'runs bash[default :create initial records]' do
      expect(property_test).to_not run_bash('default :create initial records')
    end

    it 'creates template[default :create /usr/sbin/mysql-default-wait-ready]' do
      expect(property_test).to create_template('default :start /usr/sbin/mysql-default-wait-ready')
        .with(
          path: '/usr/sbin/mysql-default-wait-ready',
          source: 'upstart/mysqld-wait-ready.erb',
          owner: 'root',
          group: 'root',
          mode: '0755',
          cookbook: 'mysql'
        )
    end

    it 'creates template[default :create /etc/init/mysql-default.conf]' do
      expect(property_test).to create_template('default :start /etc/init/mysql-default.conf')
        .with(
          path: '/etc/init/mysql-default.conf',
          source: 'upstart/mysqld.erb',
          owner: 'root',
          group: 'root',
          mode: '0644',
          cookbook: 'mysql'
        )
    end

    it 'starts service[default :start mysql-default]' do
      expect(property_test).to start_service('default :start mysql-default')
        .with(
          service_name: 'mysql-default',
          provider: Chef::Provider::Service::Upstart
        )
    end
  end
end
