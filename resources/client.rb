# frozen_string_literal: true

provides :mysql_client
provides :mysql_client_installation
provides :mysql_client_installation_package
unified_mode true

use '_partial/_base'

property :package_name, [String, Array], default: lazy { default_client_package_name }, desired_state: false
property :package_options, [String, nil], desired_state: false
property :package_version, [String, nil], desired_state: false

action :create do
  package new_resource.package_name do
    version new_resource.package_version if new_resource.package_version
    options new_resource.package_options if new_resource.package_options
    action :install
  end
end

action :delete do
  package new_resource.package_name do
    action :remove
  end
end
