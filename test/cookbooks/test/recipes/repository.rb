# frozen_string_literal: true

# Repository setup is caller-owned. These fixtures select Oracle MySQL 8.4 LTS.
if platform_family?('debian')
  apt_update 'default'
  package %w(ca-certificates gnupg)
  apt_repository 'mysql-84' do
    uri "https://repo.mysql.com/apt/#{node['platform']}"
    components ['mysql-8.4-lts']
    key 'https://repo.mysql.com/RPM-GPG-KEY-mysql-2025'
  end
else
  major = platform?('amazon') ? '9' : node['platform_version'].to_i.to_s
  yum_repository 'mysql-84' do
    baseurl "https://repo.mysql.com/yum/mysql-8.4-community/el/#{major}/$basearch/"
    gpgkey 'https://repo.mysql.com/RPM-GPG-KEY-mysql-2025'
    gpgcheck true
  end
end
