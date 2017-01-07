# MySQL Client bin path
def mysql_bin
  case os[:family]
  when 'smartos'
    '/opt/local/bin/mysql'
  when 'solaris'
    '/opt/omni/bin/mysql'
  else
    '/usr/bin/mysql'
  end
end

# MySQL Server binary path
def mysqld_bin(version = nil)
  case os[:family]
  when 'solaris'
    "/opt/mysql#{version.delete('.')}/bin/mysqld"
  when 'smartos'
    '/opt/local/bin/mysqld'
  when 'fedora'
    '/usr/libexec/mysqld'
  when 'centos'
    '/usr/libexec/mysqld'
  else
    '/usr/sbin/mysqld'
  end
end



# Check MySQL Client
#
# @param [String] version expected client version, for example '5.5'
def check_mysql_client(version)
  lib_name = 'libmysqlclient.so'
  version_short = version.delete('.')

  lib_name = "libmysql#{version_short}client.so" if os[:family] == 'suse'

  describe command("#{mysql_bin} --version") do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match(/Distrib #{version}/) }
  end

  describe command('ldconfig -p') do
    its(:stdout) { should match(/#{lib_name}/) }
  end

  describe file('/usr/include/mysql/mysql.h') do
    it { should exist }
  end
end

# Check MySQL server version
# @param [String] version MySQL version
def check_mysql_server(version)
  describe command("#{mysqld_bin} --version") do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match(/Ver #{version}/) }
  end
end

# Check single instance of MySQL
# @param [String] port MySQL port
def check_mysql_server_instance(port = '3306')
  mysql_cmd_1 = <<-EOF
#{mysql_bin} \
  -h 127.0.0.1 \
  -P #{port} \
  -u root \
  -pilikerandompasswords \
  -e "SELECT Host,User FROM mysql.user WHERE User='root' AND Host='127.0.0.1';" \
  --skip-column-names
  EOF

  mysql_cmd_2 = <<-EOF
#{mysql_bin} \
  -h 127.0.0.1 \
  -P #{port} \
  -u root \
  -pilikerandompasswords \
  -e "SELECT Host,User FROM mysql.user WHERE User='root' AND Host='localhost';" \
  --skip-column-names
EOF

  describe command(mysql_cmd_1) do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match(/| 127.0.0.1 | root |/) }
  end

  describe command(mysql_cmd_2) do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match(/| localhost | root |/) }
  end
end

# Check installation of MySQL with two instances on one server
# @param [String] version MySQL version
def check_mysql_server_multi(version)
  check_mysql_server(version)
  check_mysql_server_instance('3307')
  check_mysql_server_instance('3308')
end

# Check single installation of MySQL
def check_mysql_server_single(version)
  check_mysql_server(version)
  check_mysql_server_instance('3306')
end
