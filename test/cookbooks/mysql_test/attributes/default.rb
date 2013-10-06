# Must be specified for chef-solo for successful re-converge
override['mysql']['server_root_password'] = 'e;br$il<vOp&Ceth!Hi.en>Roj7'

default['mysql_test']['database'] = 'mysql_test'
default['mysql_test']['username'] = 'test_user'
default['mysql_test']['password'] = 'neshFiapog'

override['mysql']['bind_address'] = 'localhost'
