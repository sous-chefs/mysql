# Set a version for modern distros.
# centos-7 and fedora ship MariaDB out of the box.

node.default['mysql']['version'] = '5.6' if node['platform_family'] == 'rhel' && node['platform_version'].to_i == 7
node.default['mysql']['version'] = '5.6' if node['platform_family'] == 'fedora'

# Before that, we use "native" versions

unless node['mysql'].nil?
  case node['mysql']['version']
  when '5.5'
    return if node['platform_family'] == 'rhel' && node['platform_version'].to_i == 5
    include_recipe 'yum-mysql-community::mysql55'
  when '5.6'
    include_recipe 'yum-mysql-community::mysql56'
  when '5.7'
    include_recipe 'yum-mysql-community::mysql57'
  end
end
