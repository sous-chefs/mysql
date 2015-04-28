# This file is used by ChefSpec for testing template rendering.
# It should not be converged by Test Kitchen, since it will likely
# explode.

mysql_service 'default' do
  version node['mysql']['version']
  socket '/var/run/mysqld/mysqld.sock'
  action [:create, :start]
end
