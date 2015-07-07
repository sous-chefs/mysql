require 'spec_helper'

describe 'mysql_service_test::single on smartos-5.11' do
  cached(:smartos_511_service_56_single) do
    ChefSpec::SoloRunner.new(
      platform: 'smartos',
      version: '5.11',
      step_into: 'mysql_service'
    ) do |node|
      node.set['mysql']['version'] = '5.6'
    end.converge('mysql_service_test::single')
  end

  before do
    stub_command('/usr/bin/test -f /opt/local/lib/mysql-default/mysql/user.frm').and_return(true)
  end

  # Resource in mysql_service_test::single
  context 'compiling the test recipe' do
    it 'creates mysql_service[default]' do
      expect(smartos_511_service_56_single).to create_mysql_service('default')
    end
  end

  # mysql_service resource internal implementation
  context 'stepping into mysql_service[default] resource' do
    it 'installs package[default :create mysql-server]' do
      expect(smartos_511_service_56_single).to install_package('default :create mysql-server')
        .with(
          package_name: 'mysql-server',
          version: '5.6'
        )
    end

    it 'creates group[default :create mysql]' do
      expect(smartos_511_service_56_single).to create_group('default :create mysql')
        .with(group_name: 'mysql')
    end

    it 'creates user[default :create mysql]' do
      expect(smartos_511_service_56_single).to create_user('default :create mysql')
        .with(username: 'mysql')
    end

    it 'deletes file[default :create /opt/local/etc/mysql/my.cnf]' do
      expect(smartos_511_service_56_single).to delete_file('default :create /opt/local/etc/mysql/my.cnf')
        .with(path: '/opt/local/etc/mysql/my.cnf')
    end

    it 'deletes file[default :create /opt/local/etc/my.cnf]' do
      expect(smartos_511_service_56_single).to delete_file('default :create /opt/local/etc/my.cnf')
        .with(path: '/opt/local/etc/my.cnf')
    end

    it 'creates link[default :create /opt/local/usr/share/my-default.cnf]' do
      expect(smartos_511_service_56_single).to create_link('default :create /opt/local/usr/share/my-default.cnf')
        .with(
          target_file: '/opt/local/usr/share/my-default.cnf',
          to: '/opt/local/etc/mysql-default/my.cnf'
        )
    end

    it 'creates directory[default :create /opt/local/etc/mysql-default]' do
      expect(smartos_511_service_56_single).to create_directory('default :create /opt/local/etc/mysql-default')
        .with(
          path: '/opt/local/etc/mysql-default',
          owner: 'mysql',
          group: 'mysql',
          mode: '0750',
          recursive: true
        )
    end

    it 'creates directory[default :create /opt/local/etc/mysql-default/conf.d]' do
      expect(smartos_511_service_56_single).to create_directory('default :create /opt/local/etc/mysql-default/conf.d')
        .with(
          path: '/opt/local/etc/mysql-default/conf.d',
          owner: 'mysql',
          group: 'mysql',
          mode: '0750',
          recursive: true
        )
    end

    it 'creates directory[default :create /var/run/mysql-default]' do
      expect(smartos_511_service_56_single).to create_directory('default :create /var/run/mysql-default')
        .with(
          path: '/var/run/mysql-default',
          owner: 'mysql',
          group: 'mysql',
          mode: '0755',
          recursive: true
        )
    end

    it 'creates directory[default :create /opt/local/var/log/mysql-default]' do
      expect(smartos_511_service_56_single).to create_directory('default :create /opt/local/var/log/mysql-default')
        .with(
          path: '/opt/local/var/log/mysql-default',
          owner: 'mysql',
          group: 'mysql',
          mode: '0750',
          recursive: true
        )
    end

    it 'creates directory[default :create /opt/local/lib/mysql-default]' do
      expect(smartos_511_service_56_single).to create_directory('default :create /opt/local/lib/mysql-default')
        .with(
          path: '/opt/local/lib/mysql-default',
          owner: 'mysql',
          group: 'mysql',
          mode: '0750',
          recursive: true
        )
    end

    it 'creates template[default :create /opt/local/etc/mysql-default/my.cnf]' do
      expect(smartos_511_service_56_single).to create_template('default :create /opt/local/etc/mysql-default/my.cnf')
        .with(
          path: '/opt/local/etc/mysql-default/my.cnf',
          owner: 'mysql',
          group: 'mysql',
          mode: '0600'
        )
    end

    it 'runs bash[default :create initialize mysql database]' do
      expect(smartos_511_service_56_single).to_not run_bash('default :create initialize mysql database')
        .with(
          cwd: '/opt/local/lib/mysql-default'
        )
    end

    it 'runs bash[default :create initial records]' do
      expect(smartos_511_service_56_single).to_not run_bash('default :create initial records')
    end

    it 'create template[default :start /opt/local/lib/svc/method/mysql-default]' do
      expect(smartos_511_service_56_single).to create_template('default :start /opt/local/lib/svc/method/mysql-default')
        .with(
          path: '/opt/local/lib/svc/method/mysql-default',
          source: 'smf/svc.method.mysqld.erb',
          owner: 'root',
          group: 'root',
          mode: '0555',
          cookbook: 'mysql'
        )
    end

    it 'create template[default :start /opt/local/lib/svc/method/mysql-default]' do
      expect(smartos_511_service_56_single).to install_smf('mysql-default')
        .with(
          name: 'mysql-default',
          user: 'mysql',
          group: 'mysql',
          start_command: '/opt/local/lib/svc/method/mysql-default start'
        )
    end

    it 'starts service[default :start mysql-default]' do
      expect(smartos_511_service_56_single).to enable_service('default :start mysql-default')
        .with(
          service_name: 'mysql-default',
          provider: Chef::Provider::Service::Solaris
        )
    end
  end
end
