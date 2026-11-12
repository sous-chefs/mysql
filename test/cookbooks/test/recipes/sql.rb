# frozen_string_literal: true

# Optional local real-server test fixture. Only names supplied by the test runner are managed.
database = node['mysql_test']['database']
username = node['mysql_test']['username']
password = "SQL-fixture-'quote\\slash!"

mysql_database database do
  socket '/var/run/mysqld/mysqld.sock'
  encoding 'utf8mb4'
  collation 'utf8mb4_0900_ai_ci'
end

mysql_user username do
  password password
  ctrl_socket '/var/run/mysqld/mysqld.sock'
end

mysql_user "#{username} grants" do
  username username
  database_name database
  privileges [:select, :insert]
  ctrl_socket '/var/run/mysqld/mysqld.sock'
  action :grant
end

mysql_user "#{username} revoke unused privilege" do
  username username
  database_name database
  privileges [:delete]
  ctrl_socket '/var/run/mysqld/mysqld.sock'
  action :revoke
end
