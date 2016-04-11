# start a simple single instance with default values
mysql_service 'default' do
  version node['mysql']['version']
  action [:create, :start]
end
