# frozen_string_literal: true

# Run the installed package's unmodified binary at a fixture-local path. Hosted Ubuntu
# runners load a host /usr/sbin/mysqld AppArmor profile which is unrelated to this container.
mysql_server_installation 'fixture-package'

directory '/opt/mysql-package' do
  owner 'root'
  group 'root'
  mode '0755'
end

execute 'copy the installed MySQL binary into the test instance' do
  command ['/usr/bin/install', '-o', 'root', '-g', 'root', '-m', '0755', '/usr/sbin/mysqld', '/opt/mysql-package/mysqld']
  not_if { ::File.exist?('/opt/mysql-package/mysqld') && FileUtils.compare_file('/usr/sbin/mysqld', '/opt/mysql-package/mysqld') }
end
