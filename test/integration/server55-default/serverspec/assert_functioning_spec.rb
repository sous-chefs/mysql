require 'serverspec'

set :backend, :exec

describe command("mysql -u root -pilikerandompasswords -e 'show databases;'") do
  its(:exit_status) { should eq 0 }
end
