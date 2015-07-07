require 'spec_helper'

describe 'mysql_config_test::default' do
  cached(:centos_58_config_50) do
    ChefSpec::SoloRunner.new(
      platform: 'centos',
      version: '5.8',
      step_into: 'mysql_config'
    ) do |node|
      node.set['mysql']['version'] = '5.0'
    end.converge('mysql_config_test::default')
  end

  # Resource in mysql_config_test::default
  context 'compiling the test recipe' do
    it 'creates mysql_config[hello]' do
      expect(centos_58_config_50).to create_mysql_config('hello')
    end

    it 'creates mysql_config[hello_again]' do
      expect(centos_58_config_50).to create_mysql_config('hello_again')
    end
  end

  # mysql_config resource internal implementation
  context 'stepping into mysql_config[hello] resource' do
    it 'creates group[hello :create mysql]' do
      expect(centos_58_config_50).to create_group('hello :create mysql')
        .with(group_name: 'mysql')
    end

    it 'creates user[hello :create mysql]' do
      expect(centos_58_config_50).to create_user('hello :create mysql')
        .with(username: 'mysql')
    end

    it 'creates directory[hello :create /etc/mysql-default/conf.d]' do
      expect(centos_58_config_50).to create_directory('hello :create /etc/mysql-default/conf.d')
        .with(
          path: '/etc/mysql-default/conf.d',
          owner: 'mysql',
          group: 'mysql',
          mode: '0750',
          recursive: true
        )
    end

    it 'creates template[hello :create /etc/mysql-default/conf.d/hello.cnf]' do
      expect(centos_58_config_50).to create_template('hello :create /etc/mysql-default/conf.d/hello.cnf')
        .with(
          path: '/etc/mysql-default/conf.d/hello.cnf',
          owner: 'mysql',
          group: 'mysql',
          mode: '0640'
        )
    end

    it 'creates group[hello_again :create mysql]' do
      expect(centos_58_config_50).to create_group('hello_again :create mysql')
        .with(group_name: 'mysql')
    end

    it 'creates user[hello_again :create mysql]' do
      expect(centos_58_config_50).to create_user('hello_again :create mysql')
        .with(username: 'mysql')
    end

    it 'creates directory[hello_again :create /etc/mysql-foo/conf.d]' do
      expect(centos_58_config_50).to create_directory('hello_again :create /etc/mysql-foo/conf.d')
        .with(
          path: '/etc/mysql-foo/conf.d',
          owner: 'mysql',
          group: 'mysql',
          mode: '0750',
          recursive: true
        )
    end

    it 'creates template[hello_again :create /etc/mysql-foo/conf.d/hello_again.cnf]' do
      expect(centos_58_config_50).to create_template('hello_again :create /etc/mysql-foo/conf.d/hello_again.cnf')
        .with(
          path: '/etc/mysql-foo/conf.d/hello_again.cnf',
          owner: 'mysql',
          group: 'mysql',
          mode: '0640'
        )
    end
  end
end
