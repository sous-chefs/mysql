require 'chef/resource/lwrp_base'
require_relative 'helpers'

class Chef
  class Resource
    class MysqlClient < Chef::Resource::LWRPBase
      self.resource_name = :mysql_client
      actions :create, :delete
      default_action :create

      attribute :client_name, kind_of: String, name_attribute: true, required: true
      attribute :package_name, kind_of: String, default: nil
      attribute :package_version, kind_of: String, default: nil
      attribute :version, kind_of: String, default: nil # mysql_version
    end

    include MysqlCookbook::Helpers

    def client_package_name
      return package_name if package_name
      client_package
    end
  end
end
