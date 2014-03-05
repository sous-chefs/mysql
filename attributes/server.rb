#
# Cookbook Name:: rackspace_mysql
# Attributes:: server
#
# Copyright 2008-2013, Opscode, Inc.
# Copyright 2014, Rackspace, US Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

default['rackspace_mysql']['allow_remote_root']               = false
default['rackspace_mysql']['remove_anonymous_users']          = false
default['rackspace_mysql']['remove_test_database']            = false
default['rackspace_mysql']['root_network_acl']                = nil


#
# WARNING *** WARNING *** WARNING
# Use of hypens and underscores is inconsistent, and is passing through from upstream
# The key is the configuration file option, and some use - whilst others use _
# http://bugs.mysql.com/bug.php?id=55288
# http://stackoverflow.com/questions/7736395/mysql-configuration-hypen-or-underscore
# http://dev.mysql.com/doc/refman/5.5/en/mysqld-option-tables.html
#

###############################
# [mysqld]
###############################

default['rackspace_mysql']['config']['mysqld']['user']                       = 'mysql'
default['rackspace_mysql']['config']['mysqld']['pid_file']                   = '/var/run/mysqld/mysqld.pid'

# Note that client and mysqld_safe also need socket defined
#default['rackspace_mysql']['config']['mysqld']['socket']
default['rackspace_mysql']['config']['mysqld']['port']                       = 3306
#default['rackspace_mysql']['config']['mysqld']['basedir']
default['rackspace_mysql']['config']['mysqld']['data_dir']                   = '/var/lib/mysql'
default['rackspace_mysql']['config']['mysqld']['tmpdir']                     = ['/tmp']
default['rackspace_mysql']['config']['mysqld']['skip-external-locking']      = true
default['rackspace_mysql']['config']['mysqld']['skip-name-resolve']          = false

# Charset and Collation
default['rackspace_mysql']['config']['mysqld']['character-set-server']        = 'utf8'
default['rackspace_mysql']['config']['mysqld']['collation-server']            = 'utf8_general_ci'

default['rackspace_mysql']['config']['mysqld']['lower_case_table_names']      = nil
default['rackspace_mysql']['config']['mysqld']['event_scheduler']             = nil
default['rackspace_mysql']['config']['mysqld']['skip-character-set-client-handshake'] = false

default['rackspace_mysql']['config']['mysqld']['bind_address']                = node.attribute?('cloud') && node['cloud']['local_ipv4'] ? node['cloud']['local_ipv4'] : node['ipaddress']

#
# Fine Tuning
#
default['rackspace_mysql']['config']['mysqld']['key_buffer_size']             = '256M'
default['rackspace_mysql']['config']['mysqld']['max_allowed_packet']          = '16M'
default['rackspace_mysql']['config']['mysqld']['thread_stack']                = '256K'
default['rackspace_mysql']['config']['mysqld']['thread_cache_size']           = 8
default['rackspace_mysql']['config']['mysqld']['sort_buffer_size']            = '2M'
default['rackspace_mysql']['config']['mysqld']['read_buffer_size']            = '128k'
default['rackspace_mysql']['config']['mysqld']['read_rnd_buffer_size']        = '256k'
default['rackspace_mysql']['config']['mysqld']['join_buffer_size']            = '128k'
default['rackspace_mysql']['config']['mysqld']['auto-increment-increment']    = 1
default['rackspace_mysql']['config']['mysqld']['auto-increment-offset']       = 1

default['rackspace_mysql']['config']['mysqld']['myisam-recover']              = 'BACKUP'
default['rackspace_mysql']['config']['mysqld']['max_connections']             = '800'
default['rackspace_mysql']['config']['mysqld']['max_connect_errors']          = '10'
default['rackspace_mysql']['config']['mysqld']['concurrent_insert']           = '2'
default['rackspace_mysql']['config']['mysqld']['connect_timeout']             = '10'
default['rackspace_mysql']['config']['mysqld']['wait_timeout']                = '180'
default['rackspace_mysql']['config']['mysqld']['net_read_timeout']            = '30'
default['rackspace_mysql']['config']['mysqld']['net_write_timeout']           = '30'
default['rackspace_mysql']['config']['mysqld']['back_log']                    = '128'

default['rackspace_mysql']['config']['mysqld']['table_open_cache']            = '128'
# table_cache is deprecated in favor of table_open_cache
#default['rackspace_mysql']['config']['mysqld']['table_cache']

default['rackspace_mysql']['config']['mysqld']['tmp_table_size']              = '32M'
default['rackspace_mysql']['config']['mysqld']['max_heap_table_size']         = node['rackspace_mysql']['config']['mysqld']['tmp_table_size']
default['rackspace_mysql']['config']['mysqld']['bulk_insert_buffer_size']     = node['rackspace_mysql']['config']['mysqld']['tmp_table_size']
default['rackspace_mysql']['config']['mysqld']['open-files-limit']            = '1024'

# Default Table Settings
default['rackspace_mysql']['config']['mysqld']['sql_mode']                    = nil

#
# Query Cache Configuration
#
default['rackspace_mysql']['config']['mysqld']['query_cache_type']            = '0'
default['rackspace_mysql']['config']['mysqld']['query_cache_limit']           = '1M'
default['rackspace_mysql']['config']['mysqld']['query_cache_size']            = '16M'

#
# Logging
#
default['rackspace_mysql']['config']['mysqld']['log_error']                   = nil
default['rackspace_mysql']['config']['mysqld']['log_warnings']                = false

default['rackspace_mysql']['config']['mysqld']['long_query_time']             = 2


#
# Replication
#
default['rackspace_mysql']['config']['mysqld']['server_id']                   = nil
default['rackspace_mysql']['config']['mysqld']['log_bin']                     = nil
default['rackspace_mysql']['config']['mysqld']['log_bin_trust_function_creators'] = false

default['rackspace_mysql']['config']['mysqld']['expire_logs_days']            = 10
default['rackspace_mysql']['config']['mysqld']['max_binlog_size']             = '100M'
default['rackspace_mysql']['config']['mysqld']['binlog_cache_size']           = '32K'
default['rackspace_mysql']['config']['mysqld']['sync_binlog']                 = 0

default['rackspace_mysql']['config']['mysqld']['relay_log']                   = nil
default['rackspace_mysql']['config']['mysqld']['relay_log_index']             = nil
default['rackspace_mysql']['config']['mysqld']['replicate_do_db']             = nil
default['rackspace_mysql']['config']['mysqld']['replicate_do_table']          = nil
default['rackspace_mysql']['config']['mysqld']['replicate_ignore_db']         = nil
default['rackspace_mysql']['config']['mysqld']['replicate_ignore_table']      = nil
default['rackspace_mysql']['config']['mysqld']['replicate_wild_do_table']     = nil
default['rackspace_mysql']['config']['mysqld']['replicate_wild_ignore_table'] = nil
default['rackspace_mysql']['config']['mysqld']['skip_slave_start']            = false
default['rackspace_mysql']['config']['mysqld']['read_only']                   = false
default['rackspace_mysql']['config']['mysqld']['transaction-isolation']       = nil
default['rackspace_mysql']['config']['mysqld']['slave_compressed_protocol']   = 0

#
# InnoDB
# 

# The following options are only used on MySQL >= 5.5
default['rackspace_mysql']['config']['mysqld']['innodb_write_io_threads']         = '4'
default['rackspace_mysql']['config']['mysqld']['innodb_io_capacity']              = '200'
# innodb_read_io_threads: set in the CPU conditional below
default['rackspace_mysql']['config']['mysqld']['innodb_buffer_pool_instances']    = '4'

# The following options are always set
default['rackspace_mysql']['config']['mysqld']['innodb_log_group_home_dir'] = 
default['rackspace_mysql']['config']['mysqld']['innodb_table_locks']              = true
default['rackspace_mysql']['config']['mysqld']['innodb_lock_wait_timeout']        = '60'
# innodb_thread_concurrency: set in the CPU conditional below
# innodb_innodb_commit_concurrency: set in the CPU conditional below
default['rackspace_mysql']['config']['mysqld']['innodb_support_xa']               = true
default['rackspace_mysql']['config']['mysqld']['innodb_buffer_pool_size']         = '128M'
default['rackspace_mysql']['config']['mysqld']['innodb_log_file_size']            = '5M'
default['rackspace_mysql']['config']['mysqld']['innodb_additional_mem_pool_size'] = '8M'
default['rackspace_mysql']['config']['mysqld']['innodb_data_file_path']           = 'ibdata1:10M:autoextend'
default['rackspace_mysql']['config']['mysqld']['innodb_flush_log_at_trx_commit']  = '1'

# The following options are optional
default['rackspace_mysql']['config']['mysqld']['innodb_log_files_in_group']       = false
default['rackspace_mysql']['config']['mysqld']['innodb_status_file']              = false
default['rackspace_mysql']['config']['mysqld']['innodb_file_per_table']           = true
default['rackspace_mysql']['config']['mysqld']['skip-innodb-doublewrite']         = false
default['rackspace_mysql']['config']['mysqld']['innodb_flush_method']             = false
default['rackspace_mysql']['config']['mysqld']['innodb_log_buffer_size']          = '8M'
default['rackspace_mysql']['config']['mysqld']['innodb_change_buffering']         = false
default['rackspace_mysql']['config']['mysqld']['innodb_doublewrite']              = false
default['rackspace_mysql']['config']['mysqld']['innodb_file_format']              = false
default['rackspace_mysql']['config']['mysqld']['innodb_data_home_dir']            = node['rackspace_mysql']['config']['mysqld']['data_dir']

# Conditional/dynamic arguments
if node['cpu'].nil? || node['cpu']['total'].nil?
  default['rackspace_mysql']['config']['mysqld']['innodb_thread_concurrency']     = '8'
  default['rackspace_mysql']['config']['mysqld']['innodb_commit_concurrency']     = '8'
  default['rackspace_mysql']['config']['mysqld']['innodb_read_io_threads']        = '8'
else
  default['rackspace_mysql']['config']['mysqld']['innodb_thread_concurrency']     = (node['cpu']['total'].to_i * 2).to_s
  default['rackspace_mysql']['config']['mysqld']['innodb_commit_concurrency']     = (node['cpu']['total'].to_i * 2).to_s
  default['rackspace_mysql']['config']['mysqld']['innodb_read_io_threads']        = (node['cpu']['total'].to_i * 2).to_s
end

#
# Federated
#
default['rackspace_mysql']['config']['mysqld']['skip-federated']

#
# Security
#

# security options
# @see http://www.symantec.com/connect/articles/securing-mysql-step-step
# @see http://dev.mysql.com/doc/refman/5.7/en/server-options.html#option_mysqld_chroot
default['rackspace_mysql']['config']['mysqld']['chroot']                  = nil
# @see http://dev.mysql.com/doc/refman/5.7/en/server-options.html#option_mysqld_safe-user-create
default['rackspace_mysql']['config']['mysqld']['safe_user_create']        = nil
# @see http://dev.mysql.com/doc/refman/5.7/en/server-options.html#option_mysqld_secure-auth
default['rackspace_mysql']['config']['mysqld']['secure_auth']             = nil
# @see http://dev.mysql.com/doc/refman/5.7/en/server-options.html#option_mysqld_symbolic-links
default['rackspace_mysql']['config']['mysqld']['skip_symbolic_links']     = nil
# @see http://dev.mysql.com/doc/refman/5.7/en/server-options.html#option_mysqld_secure-file-priv
default['rackspace_mysql']['config']['mysqld']['secure_file_priv']        = nil
# @see http://dev.mysql.com/doc/refman/5.7/en/server-system-variables.html#sysvar_local_infile
default['rackspace_mysql']['config']['mysqld']['local_infile']            = nil
# @see http://dev.mysql.com/doc/refman/5.7/en/server-options.html#option_mysqld_skip-show-database
default['rackspace_mysql']['config']['mysqld']['skip_show_database']      = nil

#
# BerkeleyDB
#
default['rackspace_mysql']['config']['mysqld']['skip-bdb']


###############################
# [mysqldump]
###############################
default['rackspace_mysql']['config']['mysqldump']['max_allowed_packet']        = node['rackspace_mysql']['config']['mysqld']['max_allowed_packet']


###############################
# [mysql]
###############################
default['rackspace_mysql']['config']['mysql']['no-auto-rehash']        = false


###############################
# [myisamchk]
###############################
default['rackspace_mysql']['config']['myisamchk']['max_allowed_packet']        = node['rackspace_mysql']['config']['mysqld']['max_allowed_packet']
default['rackspace_mysql']['config']['myisamchk']['myisam_sort_buffer_size']   = '8M'
default['rackspace_mysql']['config']['myisamchk']['myisam_max_sort_file_size'] = '2147483648'
default['rackspace_mysql']['config']['myisamchk']['myisam_repair_threads']     = '1'
default['rackspace_mysql']['config']['myisamchk']['myisam-recover']            = node['rackspace_mysql']['config']['mysqld']['myisam-recover']

###############################
# [client]
###############################
#default['rackspace_mysql']['config']['client']['socket']
default['rackspace_mysql']['config']['client']['port']                       = node['rackspace_mysql']['config']['mysqld']['port']

###############################
# [mysqld_safe]
###############################
#default['rackspace_mysql']['config']['mysqld_safe']['socket']
default['rackspace_mysql']['config']['mysqld_safe']['nice']                 = 0


unless node['platform_family'] == 'rhel' && node['platform_version'].to_i < 6
  # older RHEL platforms don't support these options
  default['rackspace_mysql']['tunable']['event_scheduler']  = 0
  default['rackspace_mysql']['tunable']['binlog_format']    = 'statement' if node['rackspace_mysql']['tunable']['log_bin']
end

