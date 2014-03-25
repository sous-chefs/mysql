require 'serverspec'

include Serverspec::Helper::Exec

describe command("mysql -u root -pilikerandompasswords -e 'show databases;'") do
  it { should return_exit_status 0 }
end
