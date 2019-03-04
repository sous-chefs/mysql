module MysqlCookbook
  class MysqlServerInstallationPackage < MysqlBase
    # Resource properties
    resource_name :mysql_server_installation_package
    provides :mysql_server_installation, os: 'linux'

    property :package_name, String, default: lazy { default_server_package_name }, desired_state: false
    property :package_options, [String, nil], desired_state: false
    property :package_version, [String, nil], default: nil, desired_state: false

    # helper methods
    require_relative 'helpers'
    include MysqlCookbook::HelpersBase

    # Actions
    action :install do
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
        notifies :install, 'package[perl-Sys-Hostname-Long]', :immediately if platform_family?('suse')
        notifies :run, 'execute[Initial DB setup script]', :immediately if platform_family?('suse')
        action :install
      end

      package 'perl-Sys-Hostname-Long' do
        action :nothing
      end

      execute 'Initial DB setup script' do
        environment 'INSTANCE' => new_resource.name
        command '/usr/lib/mysql/mysql-systemd-helper install'
        action :nothing
      end
    end

    action :delete do
      package new_resource.package_name do
        action :remove
      end
    end
  end
end
