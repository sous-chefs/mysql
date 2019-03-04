module MysqlCookbook
  class MysqlClientInstallationPackage < MysqlBase
    # helper methods
    require_relative 'helpers'
    include MysqlCookbook::HelpersBase

    # Resource properties
    resource_name :mysql_client_installation_package
    provides :mysql_client_installation, os: 'linux'
    provides :mysql_client, os: 'linux'

    property :package_name, [String, Array], default: lazy { default_client_package_name }, desired_state: false
    property :package_options, [String, nil], desired_state: false
    property :package_version, [String, nil], default: nil, desired_state: false

    # Actions
    action :create do
      if requires_upstream_repository
        if node['platform'] == 'ubuntu'
          apt_repository 'mysql-community-server' do
            uri          'http://repo.mysql.com/apt/ubuntu/'
            distribution ubuntu_codename
            components   ["mysql-#{major_version}"]
            keyserver    'pgp.mit.edu'
            key          'A4A9406876FCBD3C456770C88C718D3B5072E1F5'
            #trusted      true # Because apparently pgp.mit.edu is the least reliable key server on earth
            deb_src      true
          end

          apt_repository 'mysql-tools' do
            uri          'http://repo.mysql.com/apt/ubuntu/'
            distribution ubuntu_codename
            components   ['mysql-tools']
            keyserver    'pgp.mit.edu'
            key          'A4A9406876FCBD3C456770C88C718D3B5072E1F5'
            #trusted      true # Because apparently pgp.mit.edu is the least reliable key server on earth
          end
        end
      end

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
  end
end
