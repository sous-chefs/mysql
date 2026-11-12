# frozen_string_literal: true

mysql_user node['mysql_test']['username'] do
  password node['mysql_test']['native_hash'] ? MysqlCookbook::HashedPassword.new(node['mysql_test']['native_hash']) : 'Explicit-native-fixture-only!'
  use_native_auth true
  ctrl_socket '/var/run/mysqld/mysqld.sock'
end
