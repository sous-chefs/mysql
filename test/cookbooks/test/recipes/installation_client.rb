# frozen_string_literal: true

apt_update 'update'

mysql_client_installation_package 'default' do
  version node['mysql_test']['version']
  action :create
end
