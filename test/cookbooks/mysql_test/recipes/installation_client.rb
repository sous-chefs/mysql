mysql_client_installation_package 'default' do
  version node['mysql']['version']
  action :create
end
