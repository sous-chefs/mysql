require 'serverspec'

set :backend, :exec

puts "os: #{os}"

def mysql_bin
  return '/opt/mysql50/bin/mysql' if os[:family] =~ /solaris/
  '/usr/bin/mysql'
end

def mysqld_bin
  return '/opt/mysql51/bin/mysqld' if os[:family] =~ /solaris/
  return '/opt/local/bin/mysqld' if os[:family] =~ /smartos/
  return '/usr/libexec/mysqld' if os[:family] =~ /fedora/
  return '/usr/libexec/mysqld' if os[:family] =~ /redhat/
  '/usr/sbin/mysqld'
end

def instance_1_cmd
  <<-EOF
  #{mysql_bin} \
  -h 127.0.0.1 \
  -P 3307 \
  -u root \
  -pilikerandompasswords \
  -e "SELECT Host,User FROM mysql.user WHERE User='root' AND Host='%';" \
  --skip-column-names
  EOF
end

def instance_2_cmd
  <<-EOF
  #{mysql_bin} \
  -h 127.0.0.1 \
  -P 3308 \
  -u root \
  -pstring\\ with\\ spaces \
  -e "SELECT Host,User FROM mysql.user WHERE User='root' AND Host='%';" \
  --skip-column-names
  EOF
end

def mysqld_cmd
  "#{mysqld_bin} --version"
end

describe command(instance_1_cmd) do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/| % | root |/) }
end

describe command(instance_2_cmd) do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/| % | root |/) }
end

describe command(mysqld_cmd) do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/Ver 5.0/) }
end
