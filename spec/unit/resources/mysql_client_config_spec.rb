# frozen_string_literal: true

require 'spec_helper'

describe 'mysql_client_config' do
  step_into :mysql_client_config

  context 'action :create' do
    platform 'ubuntu', '24.04'

    recipe do
      mysql_client_config 'my_client_settings' do
        options(
          'client' => {
            'port' => '3306',
            'socket' => '/var/run/mysql/mysqld.sock'
          },
          'mysql' => {
            'prompt' => 'mysql> '
          }
        )
      end
    end

    it 'creates the include directory' do
      is_expected.to create_directory('/etc/mysql/conf.d').with(
        owner: 'root',
        group: 'root',
        mode: '0755'
      )
    end

    it 'creates the template' do
      is_expected.to create_template('/etc/mysql/conf.d/my_client_settings.cnf').with(
        owner: 'root',
        group: 'root',
        mode: '0644'
      )
    end
  end

  context 'action :delete' do
    platform 'ubuntu', '24.04'

    recipe do
      mysql_client_config 'my_client_settings' do
        options({})
        action :delete
      end
    end

    it 'deletes the file' do
      is_expected.to delete_file('/etc/mysql/conf.d/my_client_settings.cnf')
    end
  end
end
