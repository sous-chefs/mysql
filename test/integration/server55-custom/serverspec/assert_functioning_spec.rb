require 'serverspec'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

property[:os] = backend.check_os
os = property[:os][:family]

if os =~ /Solaris/
  File.open('/etc/release').each do |l|
    next unless l =~ /OmniOS/
    describe command("/opt/mysql55/bin/mysql -u root -pnondefault -e 'show databases;'") do
      it { should return_exit_status 0 }
    end
  end
else
  describe command("mysql -u root -pnondefault -e 'show databases;'") do
    it { should return_exit_status 0 }
  end
end
