class Chef
  class Provider
    class MysqlService
      class Upstart < Chef::Provider::MysqlService
        action :start do
          template "#{new_resource.name} :start /etc/init/#{mysql_name}.conf" do
            path "/etc/init/#{mysql_name}.conf"
            source 'upstart/mysqld.erb'
            owner 'root'
            group 'root'
            mode '0644'
            variables(
              mysql_name: mysql_name,
              defaults_file: defaults_file,
              socket_file: socket_file
              )
            cookbook 'mysql'
            action :create
          end

          service "#{new_resource.name} :start #{mysql_name}" do
            service_name mysql_name
            provider Chef::Provider::Service::Upstart
            supports status: true
            action [:start]
          end
        end

        action :stop do
          service "#{new_resource.name} :stop #{mysql_name}" do
            service_name mysql_name
            provider Chef::Provider::Service::Upstart
            supports restart: true, status: true
            action [:stop]
          end
        end

        action :restart do
          service "#{new_resource.name} :restart #{mysql_name}" do
            service_name mysql_name
            provider Chef::Provider::Service::Upstart
            supports restart: true
            action :restart
          end
        end

        action :reload do
          service "#{new_resource.name} :reload #{mysql_name}" do
            service_name mysql_name
            provider Chef::Provider::Service::Upstart
            action :reload
          end
        end

        def create_stop_system_service
          service "#{new_resource.name} :create #{system_service_name}" do
            service_name system_service_name
            provider Chef::Provider::Service::Upstart
            supports status: true
            action [:stop, :disable]
          end
        end

        def delete_stop_service
          service "#{new_resource.name} :delete #{mysql_name}" do
            service_name mysql_name
            provider Chef::Provider::Service::Upstart
            action [:disable, :stop]
            only_if { ::File.exist?("#{etc_dir}/init/#{mysql_name}") }
          end
        end
      end
    end
  end
end
