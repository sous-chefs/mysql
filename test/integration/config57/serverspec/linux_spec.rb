require 'serverspec'

set :backend, :exec

puts "os: #{os}"

if %w(debian ubuntu redhat suse fedora).include? os[:family]
  describe file('/etc/mysql-default') do
    it { should be_directory }
    it { should be_mode 755 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
  end

  describe file('/etc/mysql-default/conf.d') do
    it { should be_directory }
    it { should be_mode 750 }
    it { should be_owned_by 'mysql' }
    it { should be_grouped_into 'mysql' }
  end

  describe file('/etc/mysql-default/conf.d/hello.cnf') do
    it { should be_file }
    it { should be_mode 640 }
    it { should be_owned_by 'mysql' }
    it { should be_grouped_into 'mysql' }
  end

  describe file('/etc/mysql-foo') do
    it { should be_directory }
    it { should be_mode 755 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
  end

  describe file('/etc/mysql-foo/conf.d') do
    it { should be_directory }
    it { should be_mode 750 }
    it { should be_owned_by 'mysql' }
    it { should be_grouped_into 'mysql' }
  end

  describe file('/etc/mysql-foo/conf.d/hello_again.cnf') do
    it { should be_file }
    it { should be_mode 640 }
    it { should be_owned_by 'mysql' }
    it { should be_grouped_into 'mysql' }
  end
end
