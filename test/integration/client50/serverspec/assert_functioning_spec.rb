require 'serverspec'

set :backend, :exec

def mysql_cmd
  '/usr/bin/mysql --version'
end

describe command(mysql_cmd) do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/Distrib 5.0/) }
end
