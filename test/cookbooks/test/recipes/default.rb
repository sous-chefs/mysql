# frozen_string_literal: true

include_recipe node['mysql_test']['installation'] == 'package' ? 'test::repository' : 'test::binary'

mysql_service 'primary' do
  install_method 'none' unless node['mysql_test']['installation'] == 'package'
  mysqld_options node['mysql_test']['installation'] == 'package' ? { 'mysqlx' => 0 } : { 'basedir' => '/opt/mysql', 'mysqlx' => 0 }
  port 3307
  initial_root_password "Fixture-only-'quote\\slash!"
  bind_address '127.0.0.1'
  action [:create, :start]
end

mysql_service 'secondary' do
  install_method 'none'
  mysqld_options node['mysql_test']['installation'] == 'package' ? { 'mysqlx' => 0 } : { 'basedir' => '/opt/mysql', 'mysqlx' => 0 }
  run_user 'mysql_secondary'
  run_group 'mysql_secondary'
  port 3308
  initial_root_password "Secondary-'quote\\slash!\nline"
  bind_address '127.0.0.1'
  action [:create, :start]
end

mysql_database 'secondary_application' do
  socket '/run/mysql-secondary/mysqld.sock'
  password "Secondary-'quote\\slash!\nline"
  encoding 'utf8mb4'
  collation 'utf8mb4_0900_ai_ci'
end

mysql_client 'default' do
  only_if { node['mysql_test']['installation'] == 'package' }
end

mysql_database 'application' do
  socket '/run/mysql-primary/mysqld.sock'
  password "Fixture-only-'quote\\slash!"
  encoding 'utf8mb4'
  collation 'utf8mb4_0900_ai_ci'
end

mysql_user 'application' do
  password "Fixture-only-user-'quote\\slash!"
  ctrl_socket '/run/mysql-primary/mysqld.sock'
  ctrl_password "Fixture-only-'quote\\slash!"
  action :create
end

mysql_user 'application grants' do
  username 'application'
  database_name 'application'
  privileges [:select, :insert]
  ctrl_socket '/run/mysql-primary/mysqld.sock'
  ctrl_password "Fixture-only-'quote\\slash!"
  action :grant
end

mysql_config 'primary' do
  config_name 'managed'
  instance 'primary'
  source 'hello.conf.erb'
  cookbook 'test'
end

file '/root/mysql-integration.cnf' do
  content "[client]\nuser=root\npassword=\"Fixture-only-'quote\\\\slash!\"\nsocket=/run/mysql-primary/mysqld.sock\n"
  mode '0600'
  sensitive true
end

mysql_client_config 'primary' do
  include_dir '/root/mysql-clients'
  options('client' => { 'user' => 'root', 'password' => "Fixture-only-'quote\\slash!", 'socket' => '/run/mysql-primary/mysqld.sock' })
end

mysql_client_config 'default-client-options' do
  instance 'primary'
  options('client' => { 'user' => 'root', 'password' => "Fixture-only-'quote\\slash!", 'socket' => '/run/mysql-primary/mysqld.sock' })
  notifies :restart, 'mysql_service[primary]', :immediately
end
