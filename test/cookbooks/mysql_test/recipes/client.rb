include_recipe 'yum::epel' if platform_family?('rhel')

include_recipe 'mysql::client'
