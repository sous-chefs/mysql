require 'spec_helper'

describe 'mysql server process' do
  it 'answers on port 3306' do
    expect(port 3306).to be_listening
  end
end


describe command("su -s /bin/sh -c \"mysql --protocol socket -uroot -pilikerandompasswords -e 'show databases;'\" unprivileged") do
  it { should return_exit_status 0 }
end
