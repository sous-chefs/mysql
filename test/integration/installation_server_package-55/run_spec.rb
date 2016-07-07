def mysqld_bin
  return '/opt/mysql51/bin/mysqld' if os[:family] =~ /solaris/
  return '/opt/local/bin/mysqld' if os[:family] =~ /smartos/
  return '/usr/libexec/mysqld' if os[:family] =~ /fedora/
  return '/opt/rh/mysql55/root/usr/libexec/mysqld' if os[:family] =~ /centos/ && os[:release] =~ /5\./
  '/usr/sbin/mysqld'
end

def mysqld_cmd
  "#{mysqld_bin} --version"
end

describe command(mysqld_cmd) do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/Ver 5.5/) }
end
