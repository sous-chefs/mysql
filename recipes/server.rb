mysql_service node['mysql']['service_name'] do
  port node['mysql']['port']
  data_dir node['mysql']['data_dir']
end
