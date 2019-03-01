module MysqlCookbook
  class MysqlBase < Chef::Resource
    require_relative 'helpers'

    # All resources are composites
    def whyrun_supported?
      true
    end

    ################
    # Type Constants
    ################

    Boolean = property_type(
      is: [true, false],
      default: false
    ) unless defined?(Boolean)

    ###################
    # Common Properties
    ###################
    property :run_group, String, default: 'mysql', desired_state: false
    property :run_user, String, default: 'mysql', desired_state: false
    property :version, String, default: lazy { default_major_version }, desired_state: false
    property :include_dir, String, default: lazy { default_include_dir }, desired_state: false
    property :major_version, String, default: lazy { major_from_full(version) }, desired_state: false

    action_class

    def enable_upstream_repository
      #raise "Got to enable_upstream_repository with node platform: #{node['platform']}"
      if node['platform'] == 'ubuntu'
        apt_repository 'mysql-community-server' do
          uri          'http://repo.mysql.com/apt/ubuntu/'
          distribution ubuntu_codename
          components   ["mysql-#{major_version}", 'mysql-tools']
        end

        apt_repository 'mysql-community-server-src' do
          uri          'http://repo.mysql.com/apt/ubuntu/'
          distribution ubuntu_codename
          components   ["mysql-#{major_version}"]
          deb_src      true
        end
      end
    end
  end
end
