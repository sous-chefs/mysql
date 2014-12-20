# comments!

mysql_service 'default' do
  version node['mysql']['version']
  action [:create, :start]
end
