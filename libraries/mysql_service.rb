module MysqlCookbook
  require_relative 'mysql_service_base'
  class MysqlService < MysqlServiceBase
    resource_name :mysql_service
    provides :mysql_service

    # installation type and service_manager
    property :install_method, %w(package auto none), default: 'auto', desired_state: false
    property :service_manager, %w(sysvinit upstart systemd auto), default: 'auto', desired_state: false

    # mysql_server_installation
    property :version, String, default: '8.0', desired_state: false
    property :major_version, String, default: lazy { major_from_full(version) }, desired_state: false
    property :package_name, String, default: lazy { default_package_name }, desired_state: false
    property :package_options, [String, nil], desired_state: false
    property :package_version, [String, nil], desired_state: false

    ################
    # Helper Methods
    ################

    def copy_properties_to(to, *properties)
      properties = self.class.properties.keys if properties.empty?
      properties.each do |p|
        # If the property is set on from, and exists on to, set the
        # property on to
        if to.class.properties.include?(p) && property_is_set?(p)
          to.send(p, send(p))
        end
      end
    end

    action_class do
      def installation(&block)
        case new_resource.install_method
        when 'auto'
          install = mysql_server_installation(new_resource.name, &block)
        when 'package'
          install = mysql_server_installation_package(new_resource.name, &block)
        when 'none'
          Chef::Log.info('Skipping MySQL installation. Assuming it was handled previously.')
          return
        end
        copy_properties_to(install)
        install
      end

      def svc_manager(&block)
        case new_resource.service_manager
        when 'auto'
          svc = mysql_service_manager(new_resource.name, &block)
        when 'sysvinit'
          svc = mysql_service_manager_sysvinit(new_resource.name, &block)
        when 'upstart'
          svc = mysql_service_manager_upstart(new_resource.name, &block)
        when 'systemd'
          svc = mysql_service_manager_systemd(new_resource.name, &block)
        end
        copy_properties_to(svc)
        svc
      end
    end

    #########
    # Actions
    #########

    action :create do
      installation do
        action :install
      end

      svc_manager do
        action :create
      end
    end

    action :start do
      svc_manager do
        action :start
      end
    end

    action :delete do
      svc_manager do
        action :delete
      end

      installation do
        action :delete
      end
    end

    action :restart do
      svc_manager do
        action :restart
      end
    end

    action :stop do
      svc_manager do
        action :stop
      end
    end
  end
end
