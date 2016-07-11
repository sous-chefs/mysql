if %w(debian ubuntu centos suse fedora).include? os[:family]
  describe directory('/etc/mysql-default') do
    its('mode') { should eq 00755 }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
  end

  describe directory('/etc/mysql-default/conf.d') do
    its('mode') { should eq 00750 }
    its('owner') { should eq 'mysql' }
    its('group') { should eq 'mysql' }
  end

  describe file('/etc/mysql-default/conf.d/hello.cnf') do
    its('mode') { should eq 00640 }
    its('owner') { should eq 'mysql' }
    its('group') { should eq 'mysql' }
  end

  describe directory('/etc/mysql-foo') do
    its('mode') { should eq 00755 }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
  end

  describe directory('/etc/mysql-foo/conf.d') do
    its('mode') { should eq 00750 }
    its('owner') { should eq 'mysql' }
    its('group') { should eq 'mysql' }
  end

  describe file('/etc/mysql-foo/conf.d/hello_again.cnf') do
    its('mode') { should eq 00640 }
    its('owner') { should eq 'mysql' }
    its('group') { should eq 'mysql' }
  end
end
