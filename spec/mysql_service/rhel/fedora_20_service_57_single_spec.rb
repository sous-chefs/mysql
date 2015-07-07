require 'spec_helper'

describe 'mysql_service_test::single on fedora-20' do
  cached(:fedora_20_service_57_single) do
    ChefSpec::SoloRunner.new(
      platform: 'fedora',
      version: '20',
      step_into: 'mysql_service'
    ) do |node|
      node.set['mysql']['version'] = '5.7'
    end.converge('mysql_service_test::single')
  end

  before do
    allow(Chef::Platform::ServiceHelpers).to receive(:service_resource_providers).and_return([:redhat, :systemd])
    stub_command('/usr/bin/test -f /var/lib/mysql-default/mysql/user.frm').and_return(true)
  end

  # Resource in mysql_service_test::single
  context 'compiling the test recipe' do
    it 'creates mysql_service[default]' do
      expect(fedora_20_service_57_single).to create_mysql_service('default')
    end
  end

  # mysql_service resource internal implementation
  context 'stepping into mysql_service[default] resource' do
    it 'installs package[default :create mysql-community-server]' do
      expect(fedora_20_service_57_single).to install_package('default :create mysql-community-server')
        .with(package_name: 'mysql-community-server', version: nil)
    end

    it 'stops service[default :create mysql]' do
      expect(fedora_20_service_57_single).to disable_service('default :create mysql')
      expect(fedora_20_service_57_single).to stop_service('default :create mysql')
    end

    it 'creates group[default :create mysql]' do
      expect(fedora_20_service_57_single).to create_group('default :create mysql')
        .with(group_name: 'mysql')
    end

    it 'creates user[default :create mysql]' do
      expect(fedora_20_service_57_single).to create_user('default :create mysql')
        .with(username: 'mysql')
    end

    it 'deletes file[default :create /etc/mysql/my.cnf]' do
      expect(fedora_20_service_57_single).to delete_file('default :create /etc/mysql/my.cnf')
        .with(path: '/etc/mysql/my.cnf')
    end

    it 'deletes file[default :create /etc/my.cnf]' do
      expect(fedora_20_service_57_single).to delete_file('default :create /etc/my.cnf')
        .with(path: '/etc/my.cnf')
    end

    it 'creates link[default :create /usr/share/my-default.cnf]' do
      expect(fedora_20_service_57_single).to create_link('default :create /usr/share/my-default.cnf')
        .with(
          target_file: '/usr/share/my-default.cnf',
          to: '/etc/mysql-default/my.cnf'
        )
    end

    it 'creates directory[default :create /etc/mysql-default]' do
      expect(fedora_20_service_57_single).to create_directory('default :create /etc/mysql-default')
        .with(
          path: '/etc/mysql-default',
          owner: 'mysql',
          group: 'mysql',
          mode: '0750',
          recursive: true
        )
    end

    it 'creates directory[default :create /etc/mysql-default/conf.d]' do
      expect(fedora_20_service_57_single).to create_directory('default :create /etc/mysql-default/conf.d')
        .with(
          path: '/etc/mysql-default/conf.d',
          owner: 'mysql',
          group: 'mysql',
          mode: '0750',
          recursive: true
        )
    end

    it 'creates directory[default :create /var/run/mysql-default]' do
      expect(fedora_20_service_57_single).to create_directory('default :create /var/run/mysql-default')
        .with(
          path: '/var/run/mysql-default',
          owner: 'mysql',
          group: 'mysql',
          mode: '0755',
          recursive: true
        )
    end

    it 'creates directory[default :create /var/log/mysql-default]' do
      expect(fedora_20_service_57_single).to create_directory('default :create /var/log/mysql-default')
        .with(
          path: '/var/log/mysql-default',
          owner: 'mysql',
          group: 'mysql',
          mode: '0750',
          recursive: true
        )
    end

    it 'creates directory[default :create /var/lib/mysql-default]' do
      expect(fedora_20_service_57_single).to create_directory('default :create /var/lib/mysql-default')
        .with(
          path: '/var/lib/mysql-default',
          owner: 'mysql',
          group: 'mysql',
          mode: '0750',
          recursive: true
        )
    end

    it 'creates template[default :create /etc/mysql-default/my.cnf]' do
      expect(fedora_20_service_57_single).to create_template('default :create /etc/mysql-default/my.cnf')
        .with(
          path: '/etc/mysql-default/my.cnf',
          owner: 'mysql',
          group: 'mysql',
          mode: '0600'
        )
    end

    it 'runs bash[default :create initialize mysql database]' do
      expect(fedora_20_service_57_single).to_not run_bash('default :create initialize mysql database')
        .with(
          cwd: '/var/lib/mysql-default'
        )
    end

    it 'runs bash[default :create initial records]' do
      expect(fedora_20_service_57_single).to_not run_bash('default :create initial records')
    end

    it 'creates template[default :start /usr/libexec/mysql-default-wait-ready]' do
      expect(fedora_20_service_57_single).to create_template('default :start /usr/libexec/mysql-default-wait-ready')
        .with(
          path: '/usr/libexec/mysql-default-wait-ready',
          source: 'systemd/mysqld-wait-ready.erb',
          owner: 'root',
          group: 'root',
          mode: '0755',
          cookbook: 'mysql'
        )
    end

    it 'creates template[default :start /usr/lib/systemd/system/mysql-default.service]' do
      expect(fedora_20_service_57_single).to create_template('default :start /usr/lib/systemd/system/mysql-default.service')
        .with(
          path: '/usr/lib/systemd/system/mysql-default.service',
          source: 'systemd/mysqld.service.erb',
          owner: 'root',
          group: 'root',
          mode: '0644',
          cookbook: 'mysql'
        )
    end

    it 'starts service[default :start mysql-default]' do
      expect(fedora_20_service_57_single).to start_service('default :start mysql-default')
        .with(
          service_name: 'mysql-default',
          provider: Chef::Provider::Service::Systemd
        )
    end
  end
end
