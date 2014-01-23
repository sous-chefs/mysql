include_recipe 'rackspace_yum::epel' if platform_family?('rhel')

include_recipe 'rackspace_mysql::client'
