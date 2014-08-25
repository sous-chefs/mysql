require 'chef/provider/lwrp_base'

class Chef
  class Provider
    class MysqlClient
      class Rhel < Chef::Provider::MysqlClient
        def packages
          %w(mysql mysql-devel)
        end
      end
    end
  end
end

Chef::Platform.set :platform => :rhel, :resource => :mysql_client, :provider => Chef::Provider::MysqlClient::Rhel
Chef::Platform.set :platform => :amazon, :resource => :mysql_client, :provider => Chef::Provider::MysqlClient::Rhel
Chef::Platform.set :platform => :redhat, :resource => :mysql_client, :provider => Chef::Provider::MysqlClient::Rhel
Chef::Platform.set :platform => :centos, :resource => :mysql_client, :provider => Chef::Provider::MysqlClient::Rhel
Chef::Platform.set :platform => :oracle, :resource => :mysql_client, :provider => Chef::Provider::MysqlClient::Rhel
Chef::Platform.set :platform => :scientific, :resource => :mysql_client, :provider => Chef::Provider::MysqlClient::Rhel
