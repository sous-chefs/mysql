require 'chef/platform/provider_priority_map'
require_relative 'provider_mysql_service_systemd'
require_relative 'provider_mysql_service_sysvinit'
require_relative 'provider_mysql_service_upstart'

if defined? Chef::Platform::ProviderPriorityMap
  Chef::Platform::ProviderPriorityMap.instance.priority(
    :mysql_service,
    [Chef::Provider::MysqlServiceSystemd, Chef::Provider::MysqlServiceUpstart, Chef::Provider::MysqlServiceSysvinit],
    os: 'linux'
  )
end
