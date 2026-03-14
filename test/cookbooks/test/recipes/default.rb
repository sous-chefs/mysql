# frozen_string_literal: true

# Debian (not Ubuntu) ships MariaDB as its default-mysql-server package.
# This cookbook's initialisation flow uses mysqld --initialize which is
# MySQL-specific and incompatible with MariaDB. Oracle's MySQL APT repo
# only publishes amd64, so there is no arm64 MySQL package for Debian.
# Skip the entire smoke suite on Debian until MariaDB support is added.
if platform?('debian')
  log 'Skipping smoke suite on Debian — distro packages provide MariaDB, not MySQL.' do
    level :warn
  end
  return
end

apt_update 'update' if platform_family?('debian')

include_recipe 'test::yum_repo'

selinux_state 'disabled' do
  action :disabled
  only_if { platform_family?('rhel', 'fedora', 'amazon') && ::File.exist?('/usr/sbin/getenforce') }
end

password_file = '/etc/mysql/.root_password'
backup_file = '/tmp/databass-backup.sql'
database_name = 'databass'

node.default['apparmor']['disable'] = true
include_recipe 'apparmor'

# Debian/Ubuntu use distro packages (MariaDB on Debian, MySQL 8.0 on Ubuntu)
# because Oracle's MySQL APT repo only publishes amd64 — no arm64.
if platform?('debian')
  server_pkg = 'default-mysql-server'
  client_pkgs = %w(default-mysql-client libmariadb-dev-compat)
elsif platform?('ubuntu')
  server_pkg = 'mysql-server'
  client_pkgs = %w(mysql-client libmysqlclient-dev)
end

mysql_service 'default' do
  port '3306'
  version node['mysql_test']['version']
  package_name server_pkg if server_pkg
  action %i(create start)
end

mysql_client 'default' do
  package_name client_pkgs if client_pkgs
  action :create
end

# When the cookbook's init_records_script ran, .root_password already exists.
# Wait for MySQL to be ready using the captured password.
ruby_block 'wait for mysql (cookbook-initialized)' do
  block do
    require 'English'
    pass = ::File.read(password_file).strip
    sock = %w(/var/run/mysql/mysqld.sock /run/mysqld/mysqld.sock).find { |s| ::File.exist?(s) }
    opt = '/tmp/mysql_wait.cnf'
    ::File.write(opt, "[client]\nuser=root\npassword=\"#{pass}\"\n")
    ::File.chmod(0o600, opt)
    wait_cmd = "/usr/bin/mysql --defaults-extra-file=#{opt} -S #{sock} -e 'SELECT 0' >/dev/null 2>&1"
    times = 0
    system(wait_cmd)
    until $CHILD_STATUS.exitstatus.zero? || times > 60
      sleep 1
      times += 1
      system(wait_cmd)
    end
    ::File.delete(opt) if ::File.exist?(opt)
  end
  only_if { ::File.exist?(password_file) }
end

# When using distro packages (Ubuntu/Debian), the package postinst
# initializes MySQL with no root password. The cookbook's init_records_script
# is skipped (db_initialized? is true) so .root_password doesn't exist.
# Handle this by waiting for MySQL, then setting and capturing a password.
ruby_block 'capture distro-initialized root password' do
  block do
    require 'English'
    require 'securerandom'
    sock = %w(/var/run/mysql/mysqld.sock /run/mysqld/mysqld.sock).find { |s| ::File.exist?(s) }
    # Wait for MySQL to be ready (no password needed for distro init)
    wait_cmd = "/usr/bin/mysql -u root -S #{sock} -e 'SELECT 0' >/dev/null 2>&1"
    times = 0
    system(wait_cmd)
    until $CHILD_STATUS.exitstatus.zero? || times > 60
      sleep 1
      times += 1
      system(wait_cmd)
    end
    # Set a random root password and save it
    pass = SecureRandom.hex(12)
    system("/usr/bin/mysql -u root -S #{sock} -e \"ALTER USER 'root'@'localhost' IDENTIFIED BY '#{pass}';\"")
    ::File.write(password_file, pass)
    ::File.chmod(0o600, password_file)
  end
  not_if { ::File.exist?(password_file) }
end

# Create a permanent option file for InSpec verification and subsequent commands
# We use the new mysql_client_config resource to demonstrate and test its functionality
ruby_block 'read password for client config' do
  block do
    node.run_state['mysql_root_password'] = ::File.read(password_file).strip
    node.run_state['mysql_socket'] = %w(/var/run/mysql/mysqld.sock /run/mysqld/mysqld.sock).find { |s| ::File.exist?(s) }
  end
  only_if { ::File.exist?(password_file) }
end

mysql_client_config 'client_integration_test' do
  config_name 'client_integration_test'
  options lazy {
    {
      'client' => {
        'user' => 'root',
        'password' => "\"#{node.run_state['mysql_root_password']}\"",
        'socket' => node.run_state['mysql_socket'],
      },
    }
  }
  mode '0600'
  # We write to the global /etc/my.cnf.d or /etc/mysql/conf.d so the client picks it up by default
  include_dir platform_family?('debian') ? '/etc/mysql/conf.d' : '/etc/my.cnf.d'
  not_if { node.run_state['mysql_root_password'].nil? }
end

# Create a symlink to .my.cnf for InSpec tests that hardcode that path
link '/etc/mysql/.my.cnf' do
  to platform_family?('debian') ? '/etc/mysql/conf.d/client_integration_test.cnf' : '/etc/my.cnf.d/client_integration_test.cnf'
  only_if { ::File.exist?(password_file) }
end

mysql_database database_name do
  action :create
  password lazy { ::File.read(password_file).strip }
end

bash "seed #{database_name}.table1" do
  code <<-EOF
    /usr/bin/mysql --defaults-extra-file=/etc/mysql/.my.cnf -D #{database_name} -e "CREATE TABLE IF NOT EXISTS table1 (name VARCHAR(20) PRIMARY KEY, userRank VARCHAR(20));"
    /usr/bin/mysql --defaults-extra-file=/etc/mysql/.my.cnf -D #{database_name} -e "INSERT INTO table1 (name,userRank) VALUES ('captain','awesome') ON DUPLICATE KEY UPDATE userRank = VALUES(userRank);"
  EOF
  action :run
end

bash "create #{database_name} backup" do
  code "/usr/bin/mysqldump --defaults-extra-file=/etc/mysql/.my.cnf #{database_name} > #{backup_file}"
  not_if { ::File.exist?(backup_file) && !::File.zero?(backup_file) }
  action :run
end

bash "verify #{database_name} backup content" do
  code "grep -E 'INSERT INTO `table1`|CREATE TABLE `table1`' #{backup_file}"
  action :run
end
