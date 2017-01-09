# A fully secure / special-charactersy root password:
# MyPa$$wordHas_"Special\'Chars%!

require_relative '../spec_helper'

# Extract version
version = File.basename(Dir.pwd).gsub(/\D/, '').chars.join('.')
# Client version
check_mysql_client(version)
# Server version
check_mysql_server(version)
# Master slave
check_master_slave
