# Before that, we use "native" versions

unless node['mysql'].nil?
  case node['mysql']['version']
  when '5.6'
    include_recipe 'yum-mysql-community::mysql56'
  when '5.7'
    include_recipe 'yum-mysql-community::mysql57'
  when '8.0'
    if node['platform_family'] == 'rhel'
      distro = 'el'
    elsif node['platform_family'] == 'fedora'
      distro = 'fc'
    end
    yum_repository 'mysql80-community' do
      description 'MySQL 8.0 Community Server'
      baseurl "http://repo.mysql.com/yum/mysql-8.0-community/#{distro}/$releasever/$basearch"
      enabled true
      failovermethod 'priority'
      fastestmirror_enabled false
      gpgcheck true
      gpgkey 'http://repo.mysql.com/RPM-GPG-KEY-mysql'
    end
  end
end
