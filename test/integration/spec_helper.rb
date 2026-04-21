# MySQL Client bin path
#
def mysql_bin
  '/usr/bin/mysql'
end

# MySQL Server binary path
#
def mysqld_bin(_version = nil)
  '/usr/sbin/mysqld'
end

# Default socket path (varies by OS)
#
def mysql_socket
  case os[:family]
  when 'redhat', 'fedora'
    '/var/run/mysql/mysqld.sock'
  else
    '/run/mysqld/mysqld.sock'
  end
end

# Check MySQL Client
#
def check_mysql_client(version, allow_mariadb: false)
  # Binary
  describe file(mysql_bin) do
    it { should exist }
  end

  # Version
  version_matcher = if allow_mariadb
                      /Distrib #{Regexp.escape(version)}|Ver #{Regexp.escape(version)}|mariadb/i
                    else
                      /Distrib #{Regexp.escape(version)}|Ver #{Regexp.escape(version)}/
                    end
  describe command("#{mysql_bin} --version") do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match(version_matcher) }
  end

  # Shared lib
  describe command('ldconfig -p') do
    its(:stdout) { should match(/libmysqlclient\.so|libmariadb\.so/) }
  end
end

# Check MySQL server version
#
def check_mysql_server(version, allow_mariadb: false)
  mysqld = mysqld_bin(version)
  version_matcher = if allow_mariadb
                      /Ver #{Regexp.escape(version)}|mariadb/i
                    else
                      /Ver #{Regexp.escape(version)}/
                    end

  # Binary
  describe file(mysqld) do
    it { should exist }
  end

  # Version
  describe command("#{mysqld} --version") do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match(version_matcher) }
  end
end

# Return MySQL query shell command using the permanent option file
#
def mysql_query(query, database = 'mysql')
  "#{mysql_bin} --defaults-extra-file=/etc/mysql/.my.cnf -D #{database} -e \"#{query}\""
end

# Check single instance of MySQL
#
def check_mysql_server_instance
  describe file('/etc/mysql/.root_password') do
    it { should exist }
    its(:mode) { should cmp '0600' }
  end

  describe file('/etc/mysql/.my.cnf') do
    it { should exist }
    its(:mode) { should cmp '0600' }
  end

  describe command(mysql_query("SELECT Host,User FROM mysql.user WHERE User='root' AND Host='localhost';")) do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match(/localhost\s+root/) }
  end
end

# Check smoke workflow defined by test::smoke recipe
#
def check_smoke_workflow
  describe command(mysql_query("SELECT userRank FROM table1 WHERE name='captain'", 'databass')) do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match(/awesome/) }
  end

  describe file('/tmp/databass-backup.sql') do
    it { should exist }
    its(:size) { should > 0 }
    its(:content) { should match(/table1/) }
  end

  check_mysql_server_instance
end
