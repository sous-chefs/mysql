node.set['build_essential']['compiletime'] = true
include_recipe "build-essential"

mysql_gem = chef_gem "mysql" do
  action :nothing
end

ruby_block "install the mysql chef_gem at run time" do
  block do
    mysql_gem.run_action(:install)
  end
end
