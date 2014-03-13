# chef says wat

mysql_service 'default' do
  version '5.5'
  port node['mysql']['port']
  data_dir node['mysql']['data_dir']
  action :create
end
