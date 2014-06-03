require 'chef/provider/lwrp_base'

class Chef
  class Provider
    class MysqlClient
      class Fedora < Chef::Provider::MysqlClient
        def packages
          %w(community-mysql community-mysql-devel)
        end
      end
    end
  end
end

Chef::Platform.set :platform => :fedora, :resource => :mysql_client, :provider => Chef::Provider::MysqlClient::Fedora
