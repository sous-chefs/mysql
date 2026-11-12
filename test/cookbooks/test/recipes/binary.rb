# frozen_string_literal: true

# Generic Oracle binaries test the resource lifecycle independently of vendor repository availability.
# Operators retain control of package repositories and installation.
architecture = node['kernel']['machine']
archive, digest = case architecture
                  when 'x86_64'
                    ['mysql-8.4.13-linux-glibc2.28-x86_64-minimal.tar.xz', '5dfbb764f731df40ef9e4f5d69aed32bdac8ba1af20bd96b7d40a942d83d4ed2']
                  when 'aarch64'
                    ['mysql-8.4.13-linux-glibc2.28-aarch64.tar.xz', '6531bb50f64c986a2abdab6b647cbd553e8740b3e5d3867f5415e33568879fc9']
                  else
                    raise 'The integration fixture requires x86_64 or aarch64'
                  end

if platform_family?('debian')
  apt_update 'default'
  time64 = (platform?('ubuntu') && node['platform_version'].to_f >= 24) || (platform?('debian') && node['platform_version'].to_i >= 13)
  package(time64 ? %w(libaio1t64 libnuma1 libncurses6) : %w(libaio1 libnuma1 libncurses6))
  if time64
    triplet = architecture == 'aarch64' ? 'aarch64-linux-gnu' : 'x86_64-linux-gnu'
    link "/usr/lib/#{triplet}/libaio.so.1" do
      to "/usr/lib/#{triplet}/libaio.so.1t64"
    end
  end
elsif platform_family?('suse')
  package %w(libaio1 libnuma1 libncurses6)
else
  package %w(libaio numactl-libs ncurses-libs)
end

remote_file "/opt/#{archive}" do
  source "https://cdn.mysql.com/Downloads/MySQL-8.4/#{archive}"
  checksum digest
end

archive_file 'mysql-84-integration' do
  path "/opt/#{archive}"
  destination '/opt/mysql'
  strip_components 1
  not_if { ::File.exist?('/opt/mysql/bin/mysqld') }
end

link '/usr/sbin/mysqld' do
  to '/opt/mysql/bin/mysqld'
end
link '/usr/bin/mysql' do
  to '/opt/mysql/bin/mysql'
end
link '/usr/bin/mysqladmin' do
  to '/opt/mysql/bin/mysqladmin'
end
