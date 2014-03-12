
mysql_service 'default' do
  version '5.5'
  port '3306'
  data_dir '/var/lib/mysql'
  action [:create, :enable]
end
