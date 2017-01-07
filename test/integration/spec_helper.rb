# Check MySQL Client
#
# @param [String] version expected client version, for example '5.5'
def check_client(version)
  case os[:family]
    when 'centos'
      mysql_cmd = "scl enable mysql#{version.delete('.')} \"mysql --version\"" if os[:release] =~ /^5\./
    when 'smartos'
      mysql_cmd = '/opt/local/bin/mysql --version'
    when  'solaris'
      mysql_cmd = '/opt/omni/bin/mysql --version'
    else
      mysql_cmd = '/usr/bin/mysql --version'
  end

  describe command(mysql_cmd) do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match(/Distrib #{version}/) }
  end

  describe command('ldconfig -p') do
    its(:stdout) { should match /libmysqlclient.so/}
  end

  describe file('/usr/include/mysql/mysql.h') do
    it { should exist }
  end
end