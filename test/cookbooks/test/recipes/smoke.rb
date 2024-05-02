require 'shellwords'

apt_update 'update'

# variables
root_pass_primary = 'MyPa$$word\Has_"Special\'Chars%!'
root_pass_replica = 'An0th3r_Pa%%w0rd!'
source_data = node['mysql_test']['version'].to_i >= 8 ? '--source-data' : '--primary-data'

# We're not able to use apparmor with how this test is setup so disable it for now
node.default['apparmor']['disable'] = true
include_recipe 'apparmor'

# Debug message
Chef::Log.error "\n\n" + '=' * 80 + "\n\nTesting MySQL version '#{node['mysql_test']['version']}'\n\n" + '=' * 80

# primary
mysql_service 'primary' do
  port '3306'
  version node['mysql_test']['version']
  initial_root_password root_pass_primary
  action [:create, :start]
end

mysql_config 'primary replication' do
  config_name 'replication'
  instance 'primary'
  source 'replication-primary.erb'
  variables(server_id: '1', mysql_instance: 'primary')
  notifies :restart, 'mysql_service[primary]', :immediately
  action :create
end

# MySQL client
mysql_client 'primary' do
  action :create
end

# replica-1
mysql_service 'replica-1' do
  port '3307'
  version node['mysql_test']['version']
  initial_root_password root_pass_replica
  action [:create, :start]
end

mysql_config 'replication-replica-1' do
  instance 'replica-1'
  source 'replication-replica.erb'
  variables(server_id: '2', mysql_instance: 'replica-1')
  notifies :restart, 'mysql_service[replica-1]', :immediately
  action :create
end

# replica-2
mysql_service 'replica-2' do
  port '3308'
  version node['mysql_test']['version']
  initial_root_password root_pass_replica
  action [:create, :start]
end

mysql_config 'replication-replica-2' do
  instance 'replica-2'
  source 'replication-replica.erb'
  variables(server_id: '3', mysql_instance: 'replica-2')
  notifies :restart, 'mysql_service[replica-2]', :immediately
  action :create
end

wait_for_command = "/usr/bin/mysql -u root -h 127.0.0.1 -P 3308 -p#{Shellwords.escape(root_pass_replica)} -e 'SELECT 0' >/dev/null 2>&1"
# Wait for replica-2 to start up, the sql below may not run properly if it isn't started,
# even if it will start properly eventually.
# Not worrying about primary or replica-1 as starting replica-2 should provide enough buffer
ruby_block 'wait for replica-2' do
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

# Create user repl on primary
bash 'create replication user' do
  code <<-EOF
  /usr/bin/mysql -u root -h 127.0.0.1 -P 3306 -p#{Shellwords.escape(root_pass_primary)} -D mysql -e "CREATE USER 'repl'@'127.0.0.1' IDENTIFIED BY 'REPLICAAATE';"
  /usr/bin/mysql -u root -h 127.0.0.1 -P 3306 -p#{Shellwords.escape(root_pass_primary)} -D mysql -e "GRANT REPLICATION replica ON *.* TO 'repl'@'127.0.0.1';"
  EOF
  not_if "/usr/bin/mysql -u root -h 127.0.0.1 -P 3306 -p#{Shellwords.escape(root_pass_primary)} -e 'select User,Host from mysql.user' | grep repl"
  action :run
end

# take a dump
bash 'create /root/dump.sql' do
  user 'root'
  code <<-EOF
          mysqldump \
          --defaults-file=/etc/mysql-primary/my.cnf \
          -u root \
          --protocol=tcp \
          -p#{Shellwords.escape(root_pass_primary)} \
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
    | grep 'primary_LOG_POS' \
    | awk '{ print $6 }' \
    | cut -f2 -d '=' \
    | cut -f1 -d';' \
    > /root/position
  EOF
  not_if { ::File.exist?('/root/position') }
  action :run
end

# import dump into replicas
bash 'replica-1 import' do
  user 'root'
  code "/usr/bin/mysql -u root -h 127.0.0.1 -P 3307 -p#{Shellwords.escape(root_pass_replica)} < /root/dump.sql"
  not_if "/usr/bin/mysql -u root -h 127.0.0.1 -P 3307 -p#{Shellwords.escape(root_pass_replica)} -e 'select User,Host from mysql.user' | grep repl"
  action :run
end

bash 'replica-2 import' do
  user 'root'
  code "/usr/bin/mysql -u root -h 127.0.0.1 -P 3308 -p#{Shellwords.escape(root_pass_replica)} < /root/dump.sql"
  not_if "/usr/bin/mysql -u root -h 127.0.0.1 -P 3308 -p#{Shellwords.escape(root_pass_replica)} -e 'select User,Host from mysql.user' | grep repl"
  action :run
end

# start replication on replica-1
ruby_block 'start_replica_1' do
  block { start_replica_1(root_pass_replica) } # libraries/helpers.rb
  not_if "/usr/bin/mysql -u root -h 127.0.0.1 -P 3307 -p#{Shellwords.escape(root_pass_replica)} -e 'SHOW replica STATUS\\G' | grep replica_IO_State"
  action :run
end

# start replication on replica-2
ruby_block 'start_replica_2' do
  block { start_replica_2(root_pass_replica) } # libraries/helpers.rb
  not_if "/usr/bin/mysql -u root -h 127.0.0.1 -P 3308 -p#{Shellwords.escape(root_pass_replica)} -e 'SHOW replica STATUS\\G' | grep replica_IO_State"
  action :run
end

# create databass on primary
bash 'create databass' do
  code <<-EOF
  /usr/bin/mysql -u root -h 127.0.0.1 -P 3306 -p#{Shellwords.escape(root_pass_primary)} -e 'CREATE DATABASE databass';
  /usr/bin/mysql -u root -h 127.0.0.1 -P 3306 -p#{Shellwords.escape(root_pass_primary)} -e 'CREATE TABLE databass.table1 (name VARCHAR(20), userRank VARCHAR(20))';
  /usr/bin/mysql -u root -h 127.0.0.1 -P 3306 -p#{Shellwords.escape(root_pass_primary)} -e "INSERT INTO databass.table1 (name,userRank) VALUES ('captain','awesome')";
  EOF
  not_if "/usr/bin/mysql -u root -h 127.0.0.1 -P 3306 -p#{Shellwords.escape(root_pass_primary)} -e 'show databases' | grep databass"
  action :run
end
