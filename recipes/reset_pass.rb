#
# The goal of this script is to shut down the mysql server,
# restart in safe mode, importing sql file to reset the password,
# then restart in normal mode again.
#
# It's meant to be run on the server node itself, not from a client node.
#

# setup the reset sql to run, this needs to know the password to reset to
template "/tmp/mysql-reset/reset.sql" do
  source "reset.sql"
  mode 0777
  owner "root"
  group "root"
  variables({
    :server_root_password => node[:mysql][:server_root_password]
  })
end

# create reset script
template "/tmp/mysql-reset/reset.sh" do
  source "reset.sh"
  mode 0777
  owner "root"
  group "root"
end

# run the reset script
execute "/tmp/mysql-reset/reset.sh"

# clean out reset scripts
execute "rm -rf /tmp/mysql-reset"
