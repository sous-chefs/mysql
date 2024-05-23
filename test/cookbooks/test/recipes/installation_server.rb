apt_update 'update'

mysql_server_installation_package 'default' do
  version node['mysql_test']['version']
  action :install
end
