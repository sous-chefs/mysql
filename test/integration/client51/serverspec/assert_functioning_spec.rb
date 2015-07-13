require 'serverspec'

set :backend, :exec

puts "os: #{os}"

def mysql_cmd
  return "scl enable mysql51 \"mysql --version\"" if os[:family] == 'redhat' && os[:release] =~ /^5\./
  '/usr/bin/mysql --version'
end

describe command(mysql_cmd) do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/Distrib 5.1/) }
end
