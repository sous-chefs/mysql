require 'shellwords'

# variables
root_pass = 'MyPa$$wordHasSpecialChars!'

# master
mysql_service 'master' do
  port '3306'
  initial_root_password root_pass
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

# slave-1
mysql_service 'slave-1' do
  port '3307'
  initial_root_password root_pass
  action [:create, :start]
end

mysql_config 'replication-slave-1' do
  instance 'slave-1'
  source 'replication-slave.erb'
  variables(server_id: '2', mysql_instance: 'slave-1')
  notifies :restart, 'mysql_service[slave-1]', :immediately
  action :create
end

# slave-2
mysql_service 'slave-2' do
  port '3308'
  initial_root_password root_pass
  action [:create, :start]
end

mysql_config 'replication-slave-2' do
  instance 'slave-2'
  source 'replication-slave.erb'
  variables(server_id: '3', mysql_instance: 'slave-2')
  notifies :restart, 'mysql_service[slave-2]', :immediately
  action :create
end

# Create user repl on master
bash 'create replication user' do
  code <<-EOF
  /usr/bin/mysql -u root -h 127.0.0.1 -P 3306 -p#{Shellwords.escape(root_pass)} -D mysql -e "CREATE USER 'repl'@'127.0.0.1' IDENTIFIED BY 'REPLICAAATE';"
  /usr/bin/mysql -u root -h 127.0.0.1 -P 3306 -p#{Shellwords.escape(root_pass)} -D mysql -e "GRANT REPLICATION SLAVE ON *.* TO 'repl'@'127.0.0.1';"
  EOF
  not_if "/usr/bin/mysql -u root -h 127.0.0.1 -P 3306 -p#{Shellwords.escape(root_pass)} -e 'select User,Host from mysql.user' | grep repl"
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
    -p#{Shellwords.escape(root_pass)} \
    --skip-lock-tables \
    --single-transaction \
    --flush-logs \
    --hex-blob \
    --master-data=2 \
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
  code "/usr/bin/mysql -u root -h 127.0.0.1 -P 3307 -p#{Shellwords.escape(root_pass)} < /root/dump.sql"
  not_if "/usr/bin/mysql -u root -h 127.0.0.1 -P 3307 -p#{Shellwords.escape(root_pass)} -e 'select User,Host from mysql.user' | grep repl"
  action :run
end

bash 'slave-2 import' do
  user 'root'
  code "/usr/bin/mysql -u root -h 127.0.0.1 -P 3308 -p#{Shellwords.escape(root_pass)} < /root/dump.sql"
  not_if "/usr/bin/mysql -u root -h 127.0.0.1 -P 3308 -p#{Shellwords.escape(root_pass)} -e 'select User,Host from mysql.user' | grep repl"
  action :run
end

# start replication on slave-1
ruby_block 'start_slave_1' do
  block { start_slave_1 } # libraries/helpers.rb
  not_if "/usr/bin/mysql -u root -h 127.0.0.1 -P 3307 -p#{Shellwords.escape(root_pass)} -e 'SHOW SLAVE STATUS\G' | grep Slave_IO_State"
  action :run
end

# start replication on slave-2
ruby_block 'start_slave_2' do
  block { start_slave_2 } # libraries/helpers.rb
  not_if "/usr/bin/mysql -u root -h 127.0.0.1 -P 3308 -p#{Shellwords.escape(root_pass)} -e 'SHOW SLAVE STATUS\G' | grep Slave_IO_State"
  action :run
end

# create databass on master
bash 'create databass' do
  code <<-EOF
  echo 'CREATE DATABASE databass;' | /usr/bin/mysql -u root -h 127.0.0.1 -P 3306 -p#{Shellwords.escape(root_pass)};
  echo 'CREATE TABLE databass.table1 (name VARCHAR(20), rank VARCHAR(20));' | /usr/bin/mysql -u root -h 127.0.0.1 -P 3306 -p#{Shellwords.escape(root_pass)};
  echo "INSERT INTO databass.table1 (name,rank) VALUES('captain','awesome');" | /usr/bin/mysql -u root -h 127.0.0.1 -P 3306 -p#{Shellwords.escape(root_pass)};
  EOF
  not_if "/usr/bin/mysql -u root -h 127.0.0.1 -P 3306 -p#{Shellwords.escape(root_pass)} -e 'show databases' | grep databass"
  action :run
end
