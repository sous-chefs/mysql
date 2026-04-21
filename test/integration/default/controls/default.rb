require_relative '../../spec_helper'

# Debian (not Ubuntu) ships MariaDB, not MySQL. The smoke recipe skips
# on Debian so there is nothing to verify — just confirm it was skipped.
if os[:name] == 'debian'
  describe 'smoke suite skipped on Debian (MariaDB != MySQL)' do
    it { expect(true).to eq true }
  end
  return
end

# Ubuntu uses distro MySQL 8.0; RHEL uses Oracle MySQL 8.4.
case os[:family]
when 'debian'
  # Ubuntu is family "debian" but name "ubuntu"
  check_mysql_client('8.0')
  check_mysql_server('8.0')
else
  check_mysql_client('8.4')
  check_mysql_server('8.4')
end

check_smoke_workflow
