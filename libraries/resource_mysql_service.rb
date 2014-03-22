require 'chef/resource/lwrp_base'
require_relative 'helpers'

extend Opscode::Mysql::Helpers

# educational comments go here.
# quite a few of them.
class Chef::Resource::MysqlService < Chef::Resource
  extend Opscode::Mysql::Helpers
  # Initialize resource
  def initialize(name = nil, run_context = nil)
    super
    @resource_name = :mysql_service
    @service_name = name

    @allowed_actions = [:create]
    @action = :create

    platform = node['platform']
    platform_family = node['platform_family']
    platform_version = node['platform_version']

    # set default values
    @version = default_version_for(platform, platform_family, platform_version)

    @package_name = package_name_for(platform, platform_family, platform_version, @version)
    @data_dir = default_data_dir_for(platform_family)

    @port = '3306'
  end

  # attribute :service_name, kind_of: String
  def service_name(arg = nil)
    set_or_return(
      :service_name,
      arg,
      :kind_of => String
      )
  end

  # attribute :port, kind_of: String
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

  # attribute :version, kind_of: String
  def version(arg = nil)
    set_or_return(
      :version,
      arg,
      :kind_of => String,
      :callbacks => {
        "is not supported for #{node['platform']}-#{node['platform_version']}" => lambda do |mysql_version|
          true unless package_name_for(
            node['platform'],
            node['platform_family'],
            node['platform_version'],
            arg
            ).nil?
        end
      }
      )
  end

  # attribute :package_name, kind_of: String
  def package_name(arg = nil)
    set_or_return(
      :package_name,
      arg,
      :kind_of => String
      )
  end

  # attribute :data_dir, kind_of: String
  def data_dir(arg = nil)
    set_or_return(
      :data_dir,
      arg,
      :kind_of => String
      )
  end

  private

  def self.validate_port(port)
    port.to_i > 1024 && port.to_i < 65_535
  end
end
