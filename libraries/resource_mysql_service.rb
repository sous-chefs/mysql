require 'chef/resource/lwrp_base'

#
class Chef::Resource::MysqlService < Chef::Resource::LWRPBase
  self.resource_name = 'mysql_service'

  actions :create
  default_action :create

  attribute :service_name, :name_attribute => true, :kind_of => String
  attribute :version, :kind_of => String, :default => nil
  attribute :port, :kind_of => String, :default => '3306'
  attribute :data_dir, :kind_of => String, :default => '/var/lib/mysql'
end
