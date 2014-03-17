require 'chef/resource/lwrp_base'
require_relative 'helpers'

include Opscode::Mysql::Helpers
#
class Chef::Resource::MysqlService < Chef::Resource::LWRPBase
  self.resource_name = 'mysql_service'
  
  actions :create
  default_action :create

  attribute :service_name, :name_attribute => true, :kind_of => String

#  binding.pry
  attribute :version, :kind_of => String, :default => '5.5'
  # attribute :version, :kind_of => String,
  # :default => MysqlPackageMap.lookup_version(
  #   node['platform'],
  #   node['platform_version'],
  #   node['mysql']['version']
  #   ),
  # :callbacks => {
  #   "is not supported for #{node['platform']}-#{node['platform_version']}" => lambda do |mysql_version|
  #     true unless MysqlPackageMap.package_for(node['platform'], node['platform_version'], mysql_version).nil?
  #   end
  # }

  attribute :package_name, :kind_of => String, :default => 'mysql-55'
  # attribute :package_name, :kind_of => String,
  # :default => MysqlPackageMap.package_for(
  #   node['platform'],
  #   node['platform_version'],
  #   @version
  #   )

  attribute :data_dir, :kind_of => String, :default => '/var/lib/mysql'
  attribute :port, :kind_of => String, :default => '3306'
end
