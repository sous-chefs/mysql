# frozen_string_literal: true

control 'mysql-instance' do
  impact 1.0
  if file('/opt/mysql-package/mysqld').exist?
    describe command('cmp /usr/sbin/mysqld /opt/mysql-package/mysqld') do
      its('exit_status') { should eq 0 }
    end
    describe command('systemctl show mysql-primary --property=ExecStart --value') do
      its('stdout') { should include('/opt/mysql-package/mysqld') }
    end
  end
  describe file('/etc/mysql-primary/conf.d/default-client-options.cnf') do
    its('owner') { should eq 'root' }
    its('mode') { should cmp '0600' }
  end
  describe command('mysql --defaults-file=/etc/mysql-primary/conf.d/default-client-options.cnf --batch --skip-column-names -e "SELECT CURRENT_USER()"') do
    its('exit_status') { should eq 0 }
    its('stdout') { should eq "root@localhost\n" }
  end
  describe file('/root/mysql-clients/primary.cnf') do
    its('owner') { should eq 'root' }
    its('mode') { should cmp '0600' }
  end
  describe command('mysql --defaults-file=/root/mysql-clients/primary.cnf --batch --skip-column-names -e "SELECT CURRENT_USER()"') do
    its('exit_status') { should eq 0 }
    its('stdout') { should eq "root@localhost\n" }
  end
  describe service('mysql-primary') do
    it { should be_enabled }
    it { should be_running }
  end
  describe service('mysql-secondary') do
    it { should be_enabled }
    it { should be_running }
  end
  describe file('/var/lib/mysql-secondary/mysql.ibd') do
    it { should exist }
    its('owner') { should eq 'mysql_secondary' }
  end
  describe file('/var/lib/chef/mysql-bootstrap/mysql-secondary.json') do
    it { should_not exist }
  end
  describe file('/etc/mysql-primary/my.cnf') do
    its('owner') { should eq 'mysql' }
    its('mode') { should cmp '0600' }
    its('content') { should include('3307') }
  end
  describe file('/etc/mysql-primary/conf.d/managed.cnf') do
    its('mode') { should cmp '0640' }
    its('content') { should include('# hello there') }
  end
  describe file('/var/lib/mysql-primary/mysql.ibd') do
    it { should exist }
    its('owner') { should eq 'mysql' }
  end
  describe file('/var/lib/chef/mysql-bootstrap/mysql-primary.json') do
    it { should_not exist }
  end
  describe file('/var/lib/chef/mysql-bootstrap') do
    its('owner') { should eq 'root' }
    its('mode') { should cmp '0700' }
  end
  describe command('mysql --defaults-file=/root/mysql-integration.cnf --batch --skip-column-names -e "SELECT VERSION()"') do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/^8\.4\./) }
  end
  describe command('mysql --defaults-file=/root/mysql-integration.cnf --batch --skip-column-names -e "SELECT DEFAULT_CHARACTER_SET_NAME FROM information_schema.SCHEMATA WHERE SCHEMA_NAME=\'application\'"') do
    its('exit_status') { should eq 0 }
    its('stdout') { should eq "utf8mb4\n" }
  end
  describe command('mysql --defaults-file=/root/mysql-integration.cnf --batch --skip-column-names -e "SELECT plugin FROM mysql.user WHERE User=\'application\' AND Host=\'localhost\'"') do
    its('exit_status') { should eq 0 }
    its('stdout') { should eq "caching_sha2_password\n" }
  end
  describe command('mysql --defaults-file=/root/mysql-integration.cnf --batch --skip-column-names -e "SELECT PRIVILEGE_TYPE FROM information_schema.SCHEMA_PRIVILEGES WHERE GRANTEE=\'\\\'application\\\'@\\\'localhost\\\'\' AND TABLE_SCHEMA=\'application\' ORDER BY PRIVILEGE_TYPE"') do
    its('exit_status') { should eq 0 }
    its('stdout') { should eq "INSERT\nSELECT\n" }
  end
end
