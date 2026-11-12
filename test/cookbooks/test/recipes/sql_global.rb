# frozen_string_literal: true

username = node['mysql_test']['username']
mysql_user username do
  password 'Global-privilege-fixture-only!'
  ctrl_socket '/var/run/mysqld/mysqld.sock'
end
mysql_user "#{username} global grants" do
  username username
  privileges [:all]
  grant_option true
  ctrl_socket '/var/run/mysqld/mysqld.sock'
  action :grant
end
