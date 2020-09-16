apt_update 'update'

def configure_package_repositories
  # we need to enable the yum-mysql-community repository to get packages
  return unless platform_family?('rhel', 'fedora')
  case node['mysql_test']['version']
  when '5.6'
    include_recipe 'yum-mysql-community::mysql56'
  when '5.7'
    include_recipe 'yum-mysql-community::mysql57'
  end
end

configure_package_repositories

mysql_server_installation_package 'default' do
  version node['mysql_test']['version']
  action :install
end
