require 'chef/mixin/shell_out'
require 'shellwords'
include Chef::Mixin::ShellOut

def start_slave_1
  query = ' CHANGE MASTER TO'
  query << " MASTER_HOST='127.0.0.1',"
  query << " MASTER_USER='repl',"
  query << " MASTER_PASSWORD='REPLICAAATE',"
  query << ' MASTER_PORT=3306,'
  query << " MASTER_LOG_POS=#{::File.open('/root/position').read.chomp};"
  query << ' START SLAVE;'
  shell_out("echo \"#{query}\" | /usr/bin/mysql -u root -h 127.0.0.1 -P3307 -p#{Shellwords.escape('MyPa$$wordHasSpecialChars!')}")
end

def start_slave_2
  query = ' CHANGE MASTER TO'
  query << " MASTER_HOST='127.0.0.1',"
  query << " MASTER_USER='repl',"
  query << " MASTER_PASSWORD='REPLICAAATE',"
  query << ' MASTER_PORT=3306,'
  query << " MASTER_LOG_POS=#{::File.open('/root/position').read.chomp};"
  query << ' START SLAVE;'
  shell_out("echo \"#{query}\" | /usr/bin/mysql -u root -h 127.0.0.1 -P3308 -p#{Shellwords.escape('MyPa$$wordHasSpecialChars!')}")
end
