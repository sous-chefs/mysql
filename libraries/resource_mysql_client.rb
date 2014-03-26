require 'chef/resource/lwrp_base'

class Chef::Resource::MysqlClient < Chef::Resource::LWRPBase
  actions  :create, :delete
  default_action :create
end
