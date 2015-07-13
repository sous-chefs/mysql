require 'serverspec'

set :backend, :exec

puts "os: #{os}"

def mysql_cmd
  return "scl enable mysql55 \"mysql --version\"" if os[:family] == 'redhat' && os[:release] =~ /^5\./
  return '/opt/local/bin/mysql --version' if os[:family] == 'smartos'
  return '/opt/omni/bin/mysql --version' if os[:family] == 'solaris'
  '/usr/bin/mysql --version'
end

describe command(mysql_cmd) do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/Distrib 5.5/) }
end
