# frozen_string_literal: true

require 'spec_helper'

describe 'mysql_server_installation' do
  step_into :mysql_server_installation
  platform 'almalinux', '9'

  context 'action :install with version 8.0' do
    recipe do
      mysql_server_installation 'default' do
        version '8.0'
        action :install
      end
    end

    it { is_expected.to install_package('mysql-community-server') }
  end

  context 'action :install with version 8.4' do
    recipe do
      mysql_server_installation 'default' do
        version '8.4'
        action :install
      end
    end

    it { is_expected.to install_package('mysql-community-server') }
  end

  context 'action :delete' do
    recipe do
      mysql_server_installation 'default' do
        version '8.0'
        action :delete
      end
    end

    it { is_expected.to remove_package('mysql-community-server') }
  end

  context 'on ubuntu 24.04' do
    platform 'ubuntu', '24.04'

    recipe do
      mysql_server_installation 'default' do
        version '8.0'
        action :install
      end
    end

    it { is_expected.to install_package('mysql-server-8.0') }
  end

  context 'on debian 12' do
    platform 'debian', '12'

    recipe do
      mysql_server_installation 'default' do
        version '8.0'
        action :install
      end
    end

    it { is_expected.to install_package('mysql-community-server') }
  end

  context 'on fedora' do
    platform 'fedora'

    recipe do
      mysql_server_installation 'default' do
        version '8.4'
        action :install
      end
    end

    it { is_expected.to install_package('mysql-community-server') }
  end
end
