# Installs a .my.cnf file into /root containing the root mysql credentials
default['rackspace_mysql']['install_root_my_cnf'] = false
default['rackspace_mysql']['templates']['user_mycnf'] = 'rackspace_mysql'

# User and password for /root/.my.cnf (dropped off by client.rb)
default['rackspace_mysql']['config']['user_mycnf']['user'] = 'root'
default['rackspace_mysql']['config']['user_mycnf']['pass'] = node['rackspace_mysql']['server_root_password']
