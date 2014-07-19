require 'chef/provider/lwrp_base'

class Chef
  class Provider
    class MysqlClient
      class Ubuntu < Chef::Provider::MysqlClient
        use_inline_resources if defined?(use_inline_resources)
        def whyrun_supported?
          true
        end
        action :create do
          converge_by 'ubuntu pattern' do
            package "mysql-client-#{node["mysql"]["version"]}" do
              action :install
            end
            package "libmysqlclient-dev" do
              action :install
            end
          end
        end

        action :delete do
          converge_by 'ubuntu pattern' do
            package "mysql-client-#{node["mysql"]["version"]}" do
              action :remove
            end
            package "libmysqlclient-dev" do
              action :remove
            end
          end
        end
      end
    end
  end
end

Chef::Platform.set :platform => :ubuntu, :resource => :mysql_client, :provider => Chef::Provider::MysqlClient::Ubuntu
