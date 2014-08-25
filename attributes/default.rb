#
default['mysql']['service_name'] = 'default'

# passwords
default['mysql']['server_root_password'] = 'ilikerandompasswords'
default['mysql']['server_debian_password'] = nil
default['mysql']['server_repl_password'] = nil

# used in grants.sql
default['mysql']['allow_remote_root'] = false
default['mysql']['remove_anonymous_users'] = true
default['mysql']['root_network_acl'] = nil

case node['platform']
when 'smartos'
  default['mysql']['data_dir'] = '/opt/local/lib/mysql'
else
  default['mysql']['data_dir'] = '/var/lib/mysql'
end

# port
default['mysql']['port'] = '3306'

default[:mysql][:tunable][:back_log]             = "128"
default[:mysql][:tunable][:key_buffer]           = "256M"
default[:mysql][:tunable][:max_allowed_packet]   = "16M"
default[:mysql][:tunable][:max_connections]      = "800"
default[:mysql][:tunable][:max_heap_table_size]  = "32M"
default[:mysql][:tunable][:myisam_recover]       = "BACKUP"
default[:mysql][:tunable][:net_read_timeout]     = "30"
default[:mysql][:tunable][:net_write_timeout]    = "30"
default[:mysql][:tunable][:table_cache]          = "128"
default[:mysql][:tunable][:table_open_cache]     = "128"
default[:mysql][:tunable][:thread_cache]         = "128"
default[:mysql][:tunable][:thread_cache_size]    = 8
default[:mysql][:tunable][:thread_concurrency]   = 10
default[:mysql][:tunable][:thread_stack]         = "256K"
default[:mysql][:tunable][:wait_timeout]         = "180"

default[:mysql][:tunable][:query_cache_limit]    = "1M"
default[:mysql][:tunable][:query_cache_size]     = "16M"

default[:mysql][:tunable][:log_slow_queries]     = "/var/log/mysql/slow.log"
default[:mysql][:tunable][:long_query_time]      = 2

default[:mysql][:tunable][:innodb_buffer_pool_size] = "256M"

