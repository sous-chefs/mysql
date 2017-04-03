apt_update 'update' if platform_family?('debian')

mysql_client_installation_package 'default' do
  version node['mysql']['version']
  action :create
end
