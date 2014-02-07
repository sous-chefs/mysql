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

# Probably driven from wrapper cookbooks, environments, or roles.
# Keep in this namespace for backwards compat
default['rackspace_mysql']['bind_address']               = node.attribute?('cloud') && node['cloud']['local_ipv4'] ? node['cloud']['local_ipv4'] : node['ipaddress']
default['rackspace_mysql']['port']                       = 3306
default['rackspace_mysql']['nice']                       = 0

# actual configs start here
default['rackspace_mysql']['auto-increment-increment']        = 1
default['rackspace_mysql']['auto-increment-offset']           = 1

default['rackspace_mysql']['allow_remote_root']               = false
default['rackspace_mysql']['remove_anonymous_users']          = false
default['rackspace_mysql']['remove_test_database']            = false
default['rackspace_mysql']['root_network_acl']                = nil
default['rackspace_mysql']['tunable']['character-set-server'] = 'utf8'
default['rackspace_mysql']['tunable']['collation-server']     = 'utf8_general_ci'
default['rackspace_mysql']['tunable']['lower_case_table_names']  = nil
default['rackspace_mysql']['tunable']['back_log']             = '128'
default['rackspace_mysql']['tunable']['key_buffer_size']           = '256M'
default['rackspace_mysql']['tunable']['myisam_sort_buffer_size']   = '8M'
default['rackspace_mysql']['tunable']['myisam_max_sort_file_size'] = '2147483648'
default['rackspace_mysql']['tunable']['myisam_repair_threads']     = '1'
default['rackspace_mysql']['tunable']['myisam-recover']            = 'BACKUP'
default['rackspace_mysql']['tunable']['max_allowed_packet']   = '16M'
default['rackspace_mysql']['tunable']['max_connections']      = '800'
default['rackspace_mysql']['tunable']['max_connect_errors']   = '10'
default['rackspace_mysql']['tunable']['concurrent_insert']    = '2'
default['rackspace_mysql']['tunable']['connect_timeout']      = '10'
default['rackspace_mysql']['tunable']['tmp_table_size']       = '32M'
default['rackspace_mysql']['tunable']['max_heap_table_size']  = node['rackspace_mysql']['tunable']['tmp_table_size']
default['rackspace_mysql']['tunable']['bulk_insert_buffer_size'] = node['rackspace_mysql']['tunable']['tmp_table_size']
default['rackspace_mysql']['tunable']['net_read_timeout']     = '30'
default['rackspace_mysql']['tunable']['net_write_timeout']    = '30'
default['rackspace_mysql']['tunable']['table_cache']          = '128'
default['rackspace_mysql']['tunable']['table_open_cache']     = node['rackspace_mysql']['tunable']['table_cache'] # table_cache is deprecated
                                                                                              # in favor of table_open_cache
default['rackspace_mysql']['tunable']['thread_cache_size']    = 8
default['rackspace_mysql']['tunable']['thread_concurrency']   = 10
default['rackspace_mysql']['tunable']['thread_stack']         = '256K'
default['rackspace_mysql']['tunable']['sort_buffer_size']     = '2M'
default['rackspace_mysql']['tunable']['read_buffer_size']     = '128k'
default['rackspace_mysql']['tunable']['read_rnd_buffer_size'] = '256k'
default['rackspace_mysql']['tunable']['join_buffer_size']     = '128k'
default['rackspace_mysql']['tunable']['wait_timeout']         = '180'
default['rackspace_mysql']['tunable']['open-files-limit']     = '1024'

default['rackspace_mysql']['tunable']['sql_mode'] = nil

default['rackspace_mysql']['tunable']['skip-character-set-client-handshake'] = false
default['rackspace_mysql']['tunable']['skip-name-resolve']                   = false

default['rackspace_mysql']['tunable']['slave_compressed_protocol']       = 0

default['rackspace_mysql']['tunable']['server_id']                       = nil
default['rackspace_mysql']['tunable']['log_bin']                         = nil
default['rackspace_mysql']['tunable']['log_bin_trust_function_creators'] = false

default['rackspace_mysql']['tunable']['relay_log']                       = nil
default['rackspace_mysql']['tunable']['relay_log_index']                 = nil
default['rackspace_mysql']['tunable']['log_slave_updates']               = false

default['rackspace_mysql']['tunable']['replicate_do_db']             = nil
default['rackspace_mysql']['tunable']['replicate_do_table']          = nil
default['rackspace_mysql']['tunable']['replicate_ignore_db']         = nil
default['rackspace_mysql']['tunable']['replicate_ignore_table']      = nil
default['rackspace_mysql']['tunable']['replicate_wild_do_table']     = nil
default['rackspace_mysql']['tunable']['replicate_wild_ignore_table'] = nil

default['rackspace_mysql']['tunable']['sync_binlog']                     = 0
default['rackspace_mysql']['tunable']['skip_slave_start']                = false
default['rackspace_mysql']['tunable']['read_only']                       = false

default['rackspace_mysql']['tunable']['log_error']                       = nil
default['rackspace_mysql']['tunable']['log_warnings']                    = false
default['rackspace_mysql']['tunable']['log_queries_not_using_index']     = true
default['rackspace_mysql']['tunable']['log_bin_trust_function_creators'] = false

default['rackspace_mysql']['tunable']['innodb_log_file_size']            = '5M'
default['rackspace_mysql']['tunable']['innodb_buffer_pool_size']         = '128M'
default['rackspace_mysql']['tunable']['innodb_buffer_pool_instances']    = '4'
default['rackspace_mysql']['tunable']['innodb_additional_mem_pool_size'] = '8M'
default['rackspace_mysql']['tunable']['innodb_data_file_path']           = 'ibdata1:10M:autoextend'
default['rackspace_mysql']['tunable']['innodb_flush_method']             = false
default['rackspace_mysql']['tunable']['innodb_log_buffer_size']          = '8M'
default['rackspace_mysql']['tunable']['innodb_write_io_threads']         = '4'
default['rackspace_mysql']['tunable']['innodb_io_capacity']              = '200'
default['rackspace_mysql']['tunable']['innodb_file_per_table']           = true
default['rackspace_mysql']['tunable']['innodb_lock_wait_timeout']        = '60'
if node['cpu'].nil? || node['cpu']['total'].nil?
  default['rackspace_mysql']['tunable']['innodb_thread_concurrency']       = '8'
  default['rackspace_mysql']['tunable']['innodb_commit_concurrency']       = '8'
  default['rackspace_mysql']['tunable']['innodb_read_io_threads']          = '8'
else
  default['rackspace_mysql']['tunable']['innodb_thread_concurrency']       = (node['cpu']['total'].to_i * 2).to_s
  default['rackspace_mysql']['tunable']['innodb_commit_concurrency']       = (node['cpu']['total'].to_i * 2).to_s
  default['rackspace_mysql']['tunable']['innodb_read_io_threads']          = (node['cpu']['total'].to_i * 2).to_s
end
default['rackspace_mysql']['tunable']['innodb_flush_log_at_trx_commit']  = '1'
default['rackspace_mysql']['tunable']['innodb_support_xa']               = true
default['rackspace_mysql']['tunable']['innodb_table_locks']              = true
default['rackspace_mysql']['tunable']['skip-innodb-doublewrite']         = false

default['rackspace_mysql']['tunable']['transaction-isolation'] = nil

default['rackspace_mysql']['tunable']['query_cache_type']    = '0'
default['rackspace_mysql']['tunable']['query_cache_limit']    = '1M'
default['rackspace_mysql']['tunable']['query_cache_size']     = '16M'

default['rackspace_mysql']['tunable']['long_query_time']      = 2
default['rackspace_mysql']['tunable']['expire_logs_days']     = 10
default['rackspace_mysql']['tunable']['max_binlog_size']      = '100M'
default['rackspace_mysql']['tunable']['binlog_cache_size']    = '32K'

default['rackspace_mysql']['tmpdir'] = ['/tmp']

# default['rackspace_mysql']['log_dir'] = node['rackspace_mysql']['data_dir']
default['rackspace_mysql']['log_files_in_group'] = false
default['rackspace_mysql']['innodb_status_file'] = false
default['rackspace_mysql']['tunable']['innodb_change_buffering'] = false
default['rackspace_mysql']['tunable']['innodb_doublewrite'] = false
default['rackspace_mysql']['tunable']['innodb_file_format'] = false

unless node['platform_family'] == 'rhel' && node['platform_version'].to_i < 6
  # older RHEL platforms don't support these options
  default['rackspace_mysql']['tunable']['event_scheduler']  = 0
  default['rackspace_mysql']['tunable']['binlog_format']    = 'statement' if node['rackspace_mysql']['tunable']['log_bin']
end

# security options
# @see http://www.symantec.com/connect/articles/securing-mysql-step-step
# @see http://dev.mysql.com/doc/refman/5.7/en/server-options.html#option_mysqld_chroot
default['rackspace_mysql']['security']['chroot']                  = nil
# @see http://dev.mysql.com/doc/refman/5.7/en/server-options.html#option_mysqld_safe-user-create
default['rackspace_mysql']['security']['safe_user_create']        = nil
# @see http://dev.mysql.com/doc/refman/5.7/en/server-options.html#option_mysqld_secure-auth
default['rackspace_mysql']['security']['secure_auth']             = nil
# @see http://dev.mysql.com/doc/refman/5.7/en/server-options.html#option_mysqld_symbolic-links
default['rackspace_mysql']['security']['skip_symbolic_links']     = nil
# @see http://dev.mysql.com/doc/refman/5.7/en/server-options.html#option_mysqld_secure-file-priv
default['rackspace_mysql']['security']['secure_file_priv']        = nil
# @see http://dev.mysql.com/doc/refman/5.7/en/server-options.html#option_mysqld_skip-show-database
default['rackspace_mysql']['security']['skip_show_database']      = nil
# @see http://dev.mysql.com/doc/refman/5.7/en/server-system-variables.html#sysvar_local_infile
default['rackspace_mysql']['security']['local_infile']            = nil
