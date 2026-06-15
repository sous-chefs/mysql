# frozen_string_literal: true

require 'spec_helper'

describe 'mysql_client' do
  step_into :mysql_client
  platform 'almalinux', '9'

  context 'with version 8.0' do
    recipe do
      mysql_client 'default' do
        version '8.0'
        action :create
      end
    end

    it { is_expected.to install_package(%w(mysql-community-client mysql-community-devel)) }
  end

  context 'with version 8.4' do
    recipe do
      mysql_client 'default' do
        version '8.4'
        action :create
      end
    end

    it { is_expected.to install_package(%w(mysql-community-client mysql-community-devel)) }
  end

  context 'action :delete' do
    recipe do
      mysql_client 'default' do
        version '8.0'
        action :delete
      end
    end

    it { is_expected.to remove_package(%w(mysql-community-client mysql-community-devel)) }
  end

  context 'on ubuntu 22.04' do
    platform 'ubuntu', '22.04'

    recipe do
      mysql_client 'default' do
        version '8.0'
        action :create
      end
    end

    it { is_expected.to install_package(['mysql-client-8.0', 'libmysqlclient-dev']) }
  end

  context 'on ubuntu 24.04' do
    platform 'ubuntu', '24.04'

    recipe do
      mysql_client 'default' do
        version '8.0'
        action :create
      end
    end

    it { is_expected.to install_package(['mysql-client-8.0', 'libmysqlclient-dev']) }
  end

  context 'on debian 12' do
    platform 'debian', '12'

    recipe do
      mysql_client 'default' do
        version '8.0'
        action :create
      end
    end

    it { is_expected.to install_package(%w(default-mysql-client libmariadb-dev-compat)) }
  end

  context 'on fedora' do
    platform 'fedora'

    recipe do
      mysql_client 'default' do
        version '8.4'
        action :create
      end
    end

    it { is_expected.to install_package(%w(mysql-community-client mysql-community-devel)) }
  end
end
