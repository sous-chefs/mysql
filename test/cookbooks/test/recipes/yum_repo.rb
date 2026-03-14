# frozen_string_literal: true

# Configure upstream MySQL repositories where the native distro packages
# do not provide the requested MySQL major version.
return if node['mysql_test'].nil?

if platform_family?('rhel', 'fedora', 'amazon')
  yum_mysql_community_repo 'mysql_repo' do
    version node['mysql_test']['version']
    gpgkey 'https://repo.mysql.com/RPM-GPG-KEY-mysql-2025'
  end
elsif platform?('debian')
  Chef::Log.info('Using Debian distro MySQL/MariaDB packages for smoke tests; skipping Oracle MySQL APT repo setup')
end
