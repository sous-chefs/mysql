require 'shellwords'

apt_update 'update'

# variables
root_pass_master = 'MyPa$$word\Has_"Special\'Chars%!'
root_pass_slave = 'An0th3r_Pa%%w0rd!'
source_data = node['mysql_test']['version'].to_i >= 8 ? '--source-data' : '--master-data'

# We're not able to use apparmor with how this test is setup so disable it for now
node.default['apparmor']['disable'] = true
include_recipe 'apparmor'

# Debug message
Chef::Log.error "\n\n" + '=' * 80 + "\n\nTesting MySQL version '#{node['mysql_test']['version']}'\n\n" + '=' * 80

# master
mysql_service 'master' do
  port '3306'
  version node['mysql_test']['version']
  initial_root_password root_pass_master
  action [:create, :start]
end

mysql_config 'master replication' do
  config_name 'replication'
  instance 'master'
  source 'replication-master.erb'
  variables(server_id: '1', mysql_instance: 'master')
  notifies :restart, 'mysql_service[master]', :immediately
  action :create
end

# MySQL client
mysql_client 'master' do
  action :create
end

# slave-1
mysql_service 'slave-1' do
  port '3307'
  version node['mysql_test']['version']
  initial_root_password root_pass_slave
  action [:create, :start]
end

mysql_config 'replication-slave-1' do
  instance 'slave-1'
  source 'replication-slave.erb'
  variables(server_id: '2', mysql_instance: 'slave-1', port: '3307')
  notifies :restart, 'mysql_service[slave-1]', :immediately
  action :create
end

# slave-2
mysql_service 'slave-2' do
  port '3308'
  version node['mysql_test']['version']
  initial_root_password root_pass_slave
  action [:create, :start]
end

mysql_config 'replication-slave-2' do
  instance 'slave-2'
  source 'replication-slave.erb'
  variables(server_id: '3', mysql_instance: 'slave-2', port: '3308')
  notifies :restart, 'mysql_service[slave-2]', :immediately
  action :create
end

wait_for_command = "/usr/bin/mysql -u root -h 127.0.0.1 -P 3308 -p#{Shellwords.escape(root_pass_slave)} -e 'SELECT 0' >/dev/null 2>&1"
# Wait for slave-2 to start up, the sql below may not run properly if it isn't started,
# even if it will start properly eventually.
# Not worrying about master or slave-1 as starting slave-2 should provide enough buffer
ruby_block 'wait for slave-2' do
  block do
    require 'English'
    times = 0
    system(wait_for_command)
    until $CHILD_STATUS.exitstatus == 0 || times > 60 # don't wait over 60 seconds
      sleep 1
      times += 1
      system(wait_for_command)
    end
  end
  not_if wait_for_command
end

# Create user repl on master
bash 'create replication user' do
  code <<-EOF
  /usr/bin/mysql -u root -h 127.0.0.1 -P 3306 -p#{Shellwords.escape(root_pass_master)} -D mysql -e "CREATE USER 'repl'@'127.0.0.1' IDENTIFIED BY 'REPLICAAATE';"
  /usr/bin/mysql -u root -h 127.0.0.1 -P 3306 -p#{Shellwords.escape(root_pass_master)} -D mysql -e "GRANT REPLICATION SLAVE ON *.* TO 'repl'@'127.0.0.1';"
  EOF
  not_if "/usr/bin/mysql -u root -h 127.0.0.1 -P 3306 -p#{Shellwords.escape(root_pass_master)} -e 'select User,Host from mysql.user' | grep repl"
  action :run
end

# take a dump
bash 'create /root/dump.sql' do
  user 'root'
  code <<-EOF
          mysqldump \
          --defaults-file=/etc/mysql-master/my.cnf \
          -u root \
          --protocol=tcp \
          -p#{Shellwords.escape(root_pass_master)} \
          --skip-lock-tables \
          --single-transaction \
          --flush-logs \
          --hex-blob \
          #{source_data}=2 \
          -A \ > /root/dump.sql;
      EOF
  not_if { ::File.exist?('/root/dump.sql') }
  action :run
end

# stash replication start position on the filesystem
bash 'stash position in /root/position' do
  user 'root'
  code <<-EOF
    head /root/dump.sql -n80 \
    | grep 'MASTER_LOG_POS' \
    | awk '{ print $6 }' \
    | cut -f2 -d '=' \
    | cut -f1 -d';' \
    > /root/position
  EOF
  not_if { ::File.exist?('/root/position') }
  action :run
end

# import dump into slaves
bash 'slave-1 import' do
  user 'root'
  code "/usr/bin/mysql -u root -h 127.0.0.1 -P 3307 -p#{Shellwords.escape(root_pass_slave)} < /root/dump.sql"
  not_if "/usr/bin/mysql -u root -h 127.0.0.1 -P 3307 -p#{Shellwords.escape(root_pass_slave)} -e 'select User,Host from mysql.user' | grep repl"
  action :run
end

bash 'slave-2 import' do
  user 'root'
  code "/usr/bin/mysql -u root -h 127.0.0.1 -P 3308 -p#{Shellwords.escape(root_pass_slave)} < /root/dump.sql"
  not_if "/usr/bin/mysql -u root -h 127.0.0.1 -P 3308 -p#{Shellwords.escape(root_pass_slave)} -e 'select User,Host from mysql.user' | grep repl"
  action :run
end

# start replication on slave-1
ruby_block 'start_slave_1' do
  block { start_slave_1(root_pass_slave) } # libraries/helpers.rb
  not_if "/usr/bin/mysql -u root -h 127.0.0.1 -P 3307 -p#{Shellwords.escape(root_pass_slave)} -e 'SHOW SLAVE STATUS\\G' | grep Slave_IO_State"
  action :run
end

# start replication on slave-2
ruby_block 'start_slave_2' do
  block { start_slave_2(root_pass_slave) } # libraries/helpers.rb
  not_if "/usr/bin/mysql -u root -h 127.0.0.1 -P 3308 -p#{Shellwords.escape(root_pass_slave)} -e 'SHOW SLAVE STATUS\\G' | grep Slave_IO_State"
  action :run
end

# create databass on master
bash 'create databass' do
  code <<-EOF
  /usr/bin/mysql -u root -h 127.0.0.1 -P 3306 -p#{Shellwords.escape(root_pass_master)} -e 'CREATE DATABASE databass';
  /usr/bin/mysql -u root -h 127.0.0.1 -P 3306 -p#{Shellwords.escape(root_pass_master)} -e 'CREATE TABLE databass.table1 (name VARCHAR(20), userRank VARCHAR(20))';
  /usr/bin/mysql -u root -h 127.0.0.1 -P 3306 -p#{Shellwords.escape(root_pass_master)} -e "INSERT INTO databass.table1 (name,userRank) VALUES ('captain','awesome')";
  EOF
  not_if "/usr/bin/mysql -u root -h 127.0.0.1 -P 3306 -p#{Shellwords.escape(root_pass_master)} -e 'show databases' | grep databass"
  action :run
end
