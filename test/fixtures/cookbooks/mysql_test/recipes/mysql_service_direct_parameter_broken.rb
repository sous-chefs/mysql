# test direct parameter passing of invalid inputs

mysql_service 'direct_paramster_broken' do
  version 'YUNOGIVECORRECTVERSION'
  port '65534'
  data_dir 'noslashes'
  action :create
end
