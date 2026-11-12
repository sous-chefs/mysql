# frozen_string_literal: true

mysql_user node['mysql_test']['username'] do
  ctrl_socket '/var/run/mysqld/mysqld.sock'
  action :drop
end

mysql_database node['mysql_test']['database'] do
  socket '/var/run/mysqld/mysqld.sock'
  action :drop
end
