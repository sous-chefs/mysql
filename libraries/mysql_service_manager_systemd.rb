# rubocop:disable Style/FrozenStringLiteralComment
module MysqlCookbook
  # rubocop:disable Metrics/ClassLength, Style/Documentation
  class MysqlServiceManagerSystemd < MysqlServiceBase
    resource_name :mysql_service_manager_systemd
    provides :mysql_service_manager_systemd

    provides :mysql_service_manager, os: 'linux' do |_node|
      Chef::Platform::ServiceHelpers.service_resource_providers.include?(:systemd)
    end

    action :create do
      # from base
      create_system_user
      stop_system_service
      create_config
      configure_apparmor
      initialize_database
    end

    # rubocop:disable Metrics/BlockLength
    action :start do
      # Needed for Debian / Ubuntu
      directory '/usr/libexec' do
        owner 'root'
        group 'root'
        mode '0755'
        action :create
      end

      # this script is called by the main systemd unit file, and
      # spins around until the service is actually up and running.
      template "/usr/libexec/#{mysql_name}-wait-ready" do
        path "/usr/libexec/#{mysql_name}-wait-ready"
        source 'systemd/mysqld-wait-ready.erb'
        owner 'root'
        group 'root'
        mode '0755'
        variables(socket_file: socket_file)
        cookbook 'mysql'
        action :create
      end

      # Use an override.conf so that we override the values we care about and
      # let the package do the heavy lifting
      # this stops us from breaking during upgrades as we have done before
      template '/etc/systemd/system/mysqld.service.d/override.conf' do
        path '/etc/systemd/system/mysqld.service.d/override.conf'
        source 'systemd/mysqld.service.erb'
        owner 'root'
        group 'root'
        mode '0644'
        variables(config: new_resource)
        cookbook 'mysql'
        notifies :run, "execute[#{new_resource.instance} systemctl daemon-reload]", :immediately
        action :nothing
      end

      # avoid 'Unit file changed on disk' warning
      execute "#{new_resource.instance} systemctl daemon-reload" do
        command '/bin/systemctl daemon-reload'
        action :nothing
      end

      # tmpfiles.d config so the service survives reboot
      template "/usr/lib/tmpfiles.d/#{mysql_name}.conf" do
        path "/usr/lib/tmpfiles.d/#{mysql_name}.conf"
        source 'tmpfiles.d.conf.erb'
        owner 'root'
        group 'root'
        mode '0644'
        variables(
          run_dir: run_dir,
          run_user: new_resource.run_user,
          run_group: new_resource.run_group
        )
        cookbook 'mysql'
        action :create
      end

      # service management resource
      service mysql_name.to_s do
        service_name mysql_name
        provider Chef::Provider::Service::Systemd
        supports restart: true, status: true
        action %i[enable start]
      end
    end
    # rubocop:enable Metrics/BlockLength

    action :stop do
      # service management resource
      service mysql_name.to_s do
        service_name mysql_name
        provider Chef::Provider::Service::Systemd
        supports status: true
        action %i[disable stop]
        only_if { ::File.exist?("/usr/lib/systemd/system/#{mysql_name}.service") }
      end
    end

    action :restart do
      # service management resource
      service mysql_name.to_s do
        service_name mysql_name
        provider Chef::Provider::Service::Systemd
        supports restart: true
        action :restart
      end
    end

    action :reload do
      # service management resource
      service mysql_name.to_s do
        service_name mysql_name
        provider Chef::Provider::Service::Systemd
        action :reload
      end
    end

    action_class do
      def stop_system_service
        # service management resource
        service 'mysql' do
          service_name system_service_name
          provider Chef::Provider::Service::Systemd
          supports status: true
          action %i[disable stop]
        end
      end

      def delete_stop_service
        # service management resource
        service mysql_name.to_s do
          service_name mysql_name
          provider Chef::Provider::Service::Systemd
          supports status: true
          action %i[disable stop]
          only_if { ::File.exist?("/usr/lib/systemd/system/#{mysql_name}.service") }
        end
      end
    end
  end
  # rubocop:enable Metrics/ClassLength, Style/Documentation
end
# rubocop:enable Style/FrozenStringLiteralComment
