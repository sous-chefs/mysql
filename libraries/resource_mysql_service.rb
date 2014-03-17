require 'chef/resource/lwrp_base'
require_relative 'helpers'

include Opscode::Mysql::Helpers

#
class Chef::Resource::MysqlService < Chef::Resource::LWRPBase
  actions :create
  default_action :create

  attribute :service_name, :name_attribute => true, :kind_of => String, :default => 'default'

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

  attribute :package_name, :kind_of => String, :default => 'mysql-server'
  # attribute :package_name, :kind_of => String,
  # :default => MysqlPackageMap.package_for(
  #   node['platform'],
  #   node['platform_version'],
  #   @version
  #   )

  attribute :date_dir, :kind_of => String, :default => '/var/lib/mysql'

  attribute :port, :kind_of => String, :default => '3306'
  # attribute :port, :kind_of => String, :default => '3306',
  # :callbacks => {
  #   'should be a valid non-system port' => lambda do |p|
  #     Chef::Resource::MysqlService.validate_port(p)
  #   end
  # }

  private

  def self.validate_port(port)
    port.to_i > 1024 && port.to_i < 65_535
  end
end
