# frozen_string_literal: true

::Chef::DSL::Recipe.include MysqlCookbook::HashedPassword::Helper

include_recipe 'test::yum_repo'

# variables
root_pass = 'arandompassword'

node.default['apparmor']['disable'] = true
include_recipe 'apparmor'

# database to test agianst
mysql_service 'default' do
  version node['mysql_test']['version']
  initial_root_password root_pass
  action %i(create start)
end

wait_for_command = "/usr/bin/mysql -u root -p#{Shellwords.escape(root_pass)} -e 'SELECT 0' >/dev/null 2>&1"
# Wait for server to start up, the sql below may not run properly if it isn't started,
# even if it will start properly eventually.
ruby_block 'wait for server' do
  block do
    require 'English'
    times = 0
    system(wait_for_command)
    until $CHILD_STATUS.exitstatus.zero? || times > 60 # don't wait over 60 seconds
      sleep 1
      times += 1
      system(wait_for_command)
    end
  end
  not_if wait_for_command
end

# Create a schema to test mysql_database :drop against
bash 'create datatrout' do
  code <<-EOF
  echo 'CREATE SCHEMA datatrout;' | /usr/bin/mysql -u root -p#{root_pass};
  touch /tmp/troutmarker
  EOF
  not_if { ::File.exist?('/tmp/troutmarker') }
  action :run
end

# Create a database for testing existing grant operations
bash 'create datasalmon' do
  code <<-EOF
  echo 'CREATE SCHEMA datasalmon;' | /usr/bin/mysql -u root -p#{root_pass};
  touch /tmp/salmonmarker
  EOF
  not_if { ::File.exist?('/tmp/salmonmarker') }
  action :run
end

# Create a user to test mysql_database_user :drop against
bash 'create kermit' do
  code <<-EOF
  echo "CREATE USER 'kermit'@'localhost';" | /usr/bin/mysql -u root -p#{root_pass};
  touch /tmp/kermitmarker
  EOF
  not_if { ::File.exist?('/tmp/kermitmarker') }
  action :run
end

# Create a user to test mysql_database_user password update via :create
bash 'create rowlf' do
  code <<-EOF
  echo "CREATE USER 'rowlf'@'localhost' IDENTIFIED BY 'hunter2';" | /usr/bin/mysql -u root -p#{root_pass};
  touch /tmp/rowlfmarker
  EOF
  not_if { ::File.exist?('/tmp/rowlfmarker') }
  action :run
end

# Create a user to test mysql_database_user password update via :create using a password hash
bash 'create statler' do
  code <<-EOF
  echo "CREATE USER 'statler'@'localhost' IDENTIFIED BY 'hunter2';" | /usr/bin/mysql -u root -p#{root_pass};
  touch /tmp/statlermarker
  EOF
  not_if { ::File.exist?('/tmp/statlermarker') }
  action :run
end

# Create a user to test mysql_database_user password update via :grant
bash 'create rizzo' do
  code <<-EOF
  echo "CREATE USER 'rizzo'@'127.0.0.1' IDENTIFIED BY 'hunter2'; GRANT SELECT ON datasalmon.* TO 'rizzo'@'127.0.0.1';" | /usr/bin/mysql -u root -p#{root_pass};
  touch /tmp/rizzomarker
  EOF
  not_if { ::File.exist?('/tmp/rizzomarker') }
  action :run
end

## Resources we're testing
mysql_database 'databass' do
  action :create
  password root_pass
end

mysql_database 'datatrout' do
  action :drop
  password root_pass
end

mysql_user 'piggy' do
  action :create
  ctrl_password root_pass
end

mysql_user 'kermit' do
  action :drop
  ctrl_password root_pass
end

mysql_user 'rowlf' do
  password '123456' # hashed: *6BB4837EB74329105EE4568DDA7DC67ED2CA2AD9
  ctrl_password root_pass
  action :create
end

mysql_user 'gonzo' do
  password 'abcdef'
  ctrl_password root_pass
  host '10.10.10.%'
  action :create
end

# create gonzo again to ensure the create action is idempotent
mysql_user 'gonzo' do
  password 'abcdef'
  ctrl_password root_pass
  host '10.10.10.%'
  action :create
end

hash = hashed_password('*2027D9391E714343187E07ACB41AE8925F30737E'); # 'l33t'

mysql_user 'statler' do
  password hash
  ctrl_password root_pass
  action :create
end

# test global permissions
mysql_user 'camilla' do
  password 'bokbokbok'
  privileges %i(select repl_client create_tmp_table show_db)
  require_ssl true
  ctrl_password root_pass
  action %i(create grant)
end

mysql_user 'fozzie' do
  database_name 'databass'
  password 'wokkawokka'
  host 'mars'
  privileges %i(select update insert)
  require_ssl true
  ctrl_password root_pass
  action %i(create grant)
end

hash2 = hashed_password('*F798E7C0681068BAE3242AA2297D2360DBBDA62B'); # 'zokkazokka'

mysql_user 'moozie' do
  database_name 'databass'
  password hash2
  ctrl_password root_pass
  host '127.0.0.1'
  privileges %i(select update insert)
  require_ssl false
  action %i(create grant)
end

# test non-default ctrl user
mysql_user 'bunsen' do
  password 'burner'
  host 'localhost'
  ctrl_password root_pass
  privileges [:all]
  grant_option true
  action %i(create grant)
end

# try to create another user with non-default ctrl user
mysql_user 'waldorf' do
  password 'InTheBalcony'
  database_name 'databass'
  ctrl_user 'bunsen'
  ctrl_password 'burner'
  privileges [:select]
  action %i(create grant)
end

# all the grants exist ('Granting privs' should not show up), but the password is different
# and should get updated
mysql_user 'rizzo' do
  database_name 'datasalmon'
  password 'salmon'
  ctrl_password root_pass
  host '127.0.0.1'
  privileges [:select]
  require_ssl false
  action :grant
end

# Should converge normally for all versions
# Checks to insure SHA2 password algo works for mysql 8
# with the host set to localhost
mysql_user 'beaker' do
  password 'meep'
  host 'localhost'
  ctrl_password root_pass
  use_native_auth false
  action :create
end

mysql_database 'flush privileges' do
  database_name 'databass'
  password root_pass
  sql 'flush privileges'
  action :query
end
