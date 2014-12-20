require 'chef/provider/lwrp_base'
require_relative 'helpers'

class Chef
  class Provider
    class MysqlClient < Chef::Provider::LWRPBase
      include MysqlCookbook::Helpers

      use_inline_resources if defined?(use_inline_resources)

      def whyrun_supported?
        true
      end

      action :create do
        # From helpers.rb
        configure_package_repositories

        new_resource.client_package_name.each do |p|
          package "#{new_resource.name} :create #{p}" do
            package_name p
            version new_resource.version if node['platform'] == 'smartos'
            version new_resource.package_version
            action :install
          end
        end
      end

      action :delete do
        new_resource.parsed_packaga_name.each do |p|
          package "#{new_resource.name} :delete #{p}" do
            action :remove
          end
        end
      end
    end
  end
end
