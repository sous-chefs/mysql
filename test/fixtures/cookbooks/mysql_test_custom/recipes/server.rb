#
mysql_service node['mysql']['service_name'] do
  version node['mysql']['version']
  port node['mysql']['port']
  data_dir node['mysql']['data_dir']
  template_source node['mysql']['template_source']
  allow_remote_root node['mysql']['allow_remote_root']
  remove_anonymous_users node['mysql']['remove_anonymous_users']
  remove_test_database node['mysql']['remove_test_database']
  root_network_acl node['mysql']['root_network_acl']
  server_root_password node['mysql']['server_root_password']
  server_debian_password node['mysql']['server_debian_password']
  server_repl_password node['mysql']['server_repl_password']
  action :create
end

log 'notify restart' do
  level :info
  notifies :restart, "mysql_service[#{node['mysql']['service_name']}]"
end

log 'notify reload' do
  level :info
  notifies :reload, "mysql_service[#{node['mysql']['service_name']}]"
end
