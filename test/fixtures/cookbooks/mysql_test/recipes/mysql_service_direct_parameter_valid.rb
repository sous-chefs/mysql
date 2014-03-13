# test direct parameter passing of valid parameter type/regex

mysql_service 'direct_parameter_valid' do
  version '4.2'
  port '1337'
  data_dir '/garbage'
  action :create
end
