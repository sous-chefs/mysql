# frozen_string_literal: true

require 'spec_helper'

describe 'mysql_config' do
  step_into :mysql_config

  platform 'ubuntu', '24.04'

  context 'action :create on ubuntu 24.04' do
    recipe do
      mysql_config 'tuning' do
        instance 'default'
        source 'my.cnf.erb'
        cookbook 'mysql'
        variables(foo: 'bar')
        action :create
      end
    end

    it { is_expected.to create_group('mysql') }
    it { is_expected.to create_user('mysql') }
    it { is_expected.to create_directory('/etc/mysql/conf.d') }
    it { is_expected.to create_template('/etc/mysql/conf.d/tuning.cnf') }
  end

  context 'action :delete on ubuntu 24.04' do
    recipe do
      mysql_config 'tuning' do
        instance 'default'
        action :delete
      end
    end

    it { is_expected.to delete_file('/etc/mysql/conf.d/tuning.cnf') }
  end
end
