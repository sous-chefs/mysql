#
mysql_service node['mysql']['service_name'] do
  version node['mysql']['version']
  port node['mysql']['port']
  data_dir node['mysql']['data_dir']
  template_source node['mysql']['template_source']
  action :create
end
