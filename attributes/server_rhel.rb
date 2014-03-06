# Cookbook Name:: rackspace_mysql
# Attributes:: server_rhel
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

case node['platform_family']
when 'rhel'
  # Probably driven from wrapper cookbooks, environments, or roles.
  # Keep in this namespace for backwards compat
  default['rackspace_mysql']['data_dir'] = '/var/lib/mysql'

  # switching logic to account for differences in platform native
  # package versions
  case node['platform_version'].to_i
  when 6
    default['rackspace_mysql']['server']['packages'] = ['mysql-server']
  
    default['rackspace_mysql']['config']['mysqld']['slow_query_log']['value']       = 1
    default['rackspace_mysql']['config']['mysqld']['slow_query_log_file']['value']  = '/var/log/mysql/slow.log'
  else
    fail "Unsupported RHEL version #{node['platform_version']}"
  end

  
  # Platformisms.. filesystem locations and such.
  # These are parsed by the recipe
  default['rackspace_mysql']['server']['directories']['run_dir']      = '/var/run/mysqld'
  default['rackspace_mysql']['server']['directories']['log_dir']      = '/var/lib/mysql'
  default['rackspace_mysql']['server']['directories']['slow_log_dir'] = '/var/log/mysql'
  default['rackspace_mysql']['server']['directories']['confd_dir']    = '/etc/mysql/conf.d'

  default['rackspace_mysql']['server']['mysqladmin_bin']  = '/usr/bin/mysqladmin'
  default['rackspace_mysql']['server']['mysql_bin']       = '/usr/bin/mysql'

  # Config changes
  # These are parsed by the template
  default['rackspace_mysql']['config']['mysqld']['datadir']['value'] = node['rackspace_mysql']['data_dir']
  default['rackspace_mysql']['config']['mysqld']['innodb_log_group_home_dir']['value'] = node['rackspace_mysql']['server']['directories']['log_dir']
  
  default['rackspace_mysql']['config']['mysqld']['pid-file']['value'] = '/var/run/mysqld/mysqld.pid'
  default['rackspace_mysql']['config']['mysqld']['socket']['value']   = '/var/lib/mysql/mysql.sock'
  default['rackspace_mysql']['config']['mysqld']['skip-bdb']['value'] = true

  # RHEL/CentOS mysql package does not support this option.
  default['rackspace_mysql']['config']['mysqld']['innodb_adaptive_flushing']['comment'] = 'Unsupported on RHEL'
  default['rackspace_mysql']['config']['mysqld']['old_passwords']['value']              = 0

  default['rackspace_mysql']['config']['includes']['value'] = node['rackspace_mysql']['server']['directories']['confd_dir']
end
