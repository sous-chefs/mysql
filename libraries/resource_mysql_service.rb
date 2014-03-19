require 'chef/resource/lwrp_base'
require_relative 'helpers'

include Opscode::Mysql::Helpers

#
class Chef::Resource::MysqlService < Chef::Resource
  def initialize(name = nil, run_context = nil)
    super
    @resource_name = :mysql_service
    @allowed_actions = [:create]
    @action = :create
    
    @service_name = name

    # binding.pry
    @version = MysqlPackageMap.lookup_version(
      node['platform'],
      node['platform_version'],
      node['mysql']['version']
      )

    @package_name = MysqlPackageMap.package_for(
      node['platform'],
      node['platform_version'],
      @version
      )

    @port = '3306'
    @data_dir = '/var/lib/mysql'
  end

  def service_name(arg = nil)
    set_or_return(
      :service_name,
      arg,
      :kind_of => String
      )
  end

  def version(arg = nil)
    set_or_return(
      :version,
      arg,
      :kind_of => String,
      :callbacks => {
        "is not supported for #{node['platform']}-#{node['platform_version']}" => lambda do |mysql_version|
          true unless MysqlPackageMap.package_for(node['platform'], node['platform_version'], mysql_version).nil?
        end
      }
      )
  end

  def package_name(arg = nil)
    set_or_return(
      :package_name,
      arg,
      :kind_of => String
      )
  end

  def data_dir(arg = nil)
    set_or_return(
      :data_dir,
      arg,
      :kind_of => String
      )
  end

  def port(arg = nil)
    set_or_return(
      :port,
      arg,
      :kind_of => String,
      :callbacks => {
        'should be a valid non-system port' => lambda do |p|
          Chef::Resource::MysqlService.validate_port(p)
        end
      }
      )
  end

  private

  def self.validate_port(port)
    port.to_i > 1024 && port.to_i < 65_535
  end
end
