# frozen_string_literal: true

require 'spec_helper'

describe 'mysql_service' do
  step_into %i(mysql_service mysql_server_installation)
  platform 'almalinux', '9'

  context 'action :create' do
    recipe do
      mysql_service 'default' do
        version '8.0'
        action :create
      end
    end

    it { is_expected.to install_package('mysql-community-server') }
    it { is_expected.to create_group('mysql') }
    it { is_expected.to create_user('mysql') }
    it { is_expected.to stop_service('default stop mysqld') }
    it { is_expected.to create_directory('/etc/mysql') }
    it { is_expected.to create_directory('/etc/mysql/conf.d') }
    it { is_expected.to create_directory('/var/log/mysql') }
    it { is_expected.to create_directory('/var/lib/mysql') }
    it { is_expected.to create_directory('/var/run/mysql') }
    it { is_expected.to create_template('/etc/mysql/my.cnf') }
    it { is_expected.to run_bash('default initial records') }
  end

  context 'action :start' do
    recipe do
      mysql_service 'default' do
        version '8.0'
        action :start
      end
    end

    it { is_expected.to create_directory('/usr/libexec') }
    it { is_expected.to create_template('/usr/libexec/mysql-wait-ready') }
    it { is_expected.to create_template('/etc/systemd/system/mysql.service') }
    it { is_expected.to create_template('/usr/lib/tmpfiles.d/mysql.conf') }
    it { is_expected.to enable_service('mysql') }
    it { is_expected.to start_service('mysql') }
  end

  context 'action :stop' do
    recipe do
      mysql_service 'default' do
        version '8.0'
        action :stop
      end
    end

    it { is_expected.to_not disable_service('mysql') }
    it { is_expected.to_not stop_service('mysql') }
  end

  context 'action :restart' do
    recipe do
      mysql_service 'default' do
        version '8.0'
        action :restart
      end
    end

    it { is_expected.to restart_service('mysql') }
  end

  context 'action :delete' do
    recipe do
      mysql_service 'default' do
        version '8.0'
        action :delete
      end
    end

    it { is_expected.to_not disable_service('default delete stop') }
    it { is_expected.to_not stop_service('default delete stop') }
    it { is_expected.to delete_directory('/etc/mysql') }
    it { is_expected.to delete_directory('/var/run/mysql') }
    it { is_expected.to delete_directory('/var/log/mysql') }
    it { is_expected.to remove_package('mysql-community-server') }
  end

  context 'on ubuntu 24.04' do
    platform 'ubuntu', '24.04'

    recipe do
      mysql_service 'default' do
        version '8.0'
        action :create
      end
    end

    it { is_expected.to install_package('mysql-server-8.0') }
    it { is_expected.to create_group('mysql') }
    it { is_expected.to create_user('mysql') }
    it { is_expected.to create_template('/etc/mysql/my.cnf') }
  end
end
