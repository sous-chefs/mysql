require 'chef/provider'

class Chef::Provider::MysqlService < Chef::Provider::LWRPBase
  @anvar = 'anstring'
  def action_create
  end
end
