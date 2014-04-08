#
mysql_service node['mysql']['service_name'] do
  version node['mysql']['version']
  port node['mysql']['port']
  data_dir node['mysql']['data_dir']
  template_source node['mysql']['template_source']
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
