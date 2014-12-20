# comments!

mysql_client 'default' do
  version node['mysql']['version']
  action [:create]
end
