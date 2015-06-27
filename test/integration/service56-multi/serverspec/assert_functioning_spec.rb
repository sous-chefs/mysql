require 'serverspec'

set :backend, :exec

puts "os: #{os}"

def mysql_bin
  return '/opt/mysql56/bin/mysql' if os[:family] =~ /solaris/
  return '/opt/local/bin/mysql' if os[:family] =~ /smartos/
  '/usr/bin/mysql'
end

def mysqld_bin
  return '/opt/mysql51/bin/mysqld' if os[:family] =~ /solaris/
  return '/opt/local/bin/mysqld' if os[:family] =~ /smartos/
  '/usr/sbin/mysqld'
end

def instance_1_cmd_1
  <<-EOF
  #{mysql_bin} \
  -h 127.0.0.1 \
  -P 3307 \
  -u root \
  -pilikerandompasswords \
  -e "SELECT Host,User FROM mysql.user WHERE User='root' AND Host='127.0.0.1';" \
  --skip-column-names
  EOF
end

def instance_1_cmd_2
  <<-EOF
  #{mysql_bin} \
  -h 127.0.0.1 \
  -P 3307 \
  -u root \
  -pilikerandompasswords \
  -e "SELECT Host,User FROM mysql.user WHERE User='root' AND Host='localhost';" \
  --skip-column-names
  EOF
end

def instance_2_cmd_1
  <<-EOF
  #{mysql_bin} \
  -h 127.0.0.1 \
  -P 3308 \
  -u root \
  -pstring\\ with\\ spaces \
  -e "SELECT Host,User FROM mysql.user WHERE User='root' AND Host='127.0.0.1';" \
  --skip-column-names
  EOF
end

def instance_2_cmd_2
  <<-EOF
  #{mysql_bin} \
  -h 127.0.0.1 \
  -P 3308 \
  -u root \
  -pstring\\ with\\ spaces \
  -e "SELECT Host,User FROM mysql.user WHERE User='root' AND Host='localhost';" \
  --skip-column-names
  EOF
end

def mysqld_cmd
  "#{mysqld_bin} --version"
end

describe command(instance_1_cmd_1) do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/| 127.0.0.1 | root |/) }
end

describe command(instance_1_cmd_2) do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/| localhost | root |/) }
end

describe command(instance_2_cmd_1) do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/| 127.0.0.1 | root |/) }
end

describe command(instance_2_cmd_2) do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/| localhost | root |/) }
end

describe command(mysqld_cmd) do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/Ver 5.6/) }
end
