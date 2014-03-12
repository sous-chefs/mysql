require 'chef/resource/lwrp_base'

#
class Chef::Resource::MysqlService < Chef::Resource::LWRPBase
  self.resource_name = 'mysql_service'

  actions :create, :enable

  attribute :name, :kind_of => String, :required => true
  attribute :version, :kind_of => String
  attribute :port, :kind_of => String
  attribute :data_dir, :kind_of => String
end
